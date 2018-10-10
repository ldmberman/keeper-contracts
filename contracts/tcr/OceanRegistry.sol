pragma solidity 0.4.25;

import '../plcrvoting/PLCRVoting.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract OceanRegistry is Ownable {

    using SafeMath for uint;

    // ------
    // EVENTS
    // ------

    event _Application(bytes32 indexed listingHash, uint deposit, uint appEndDate, string data, address indexed applicant);
    event _Challenge(bytes32 indexed listingHash, uint challengeID, string data, uint commitEndDate, uint revealEndDate, address indexed challenger);
    event _Deposit(bytes32 indexed listingHash, uint added, uint newTotal, address indexed owner);
    event _Withdrawal(bytes32 indexed listingHash, uint withdrew, uint newTotal, address indexed owner);
    event _ApplicationWhitelisted(bytes32 indexed listingHash);
    event _ApplicationRemoved(bytes32 indexed listingHash);
    event _ListingRemoved(bytes32 indexed listingHash);
    event _ListingWithdrawn(bytes32 indexed listingHash);
    event _TouchAndRemoved(bytes32 indexed listingHash);
    event _ChallengeFailed(bytes32 indexed listingHash, uint indexed challengeID, uint rewardPool, uint totalTokens);
    event _ChallengeSucceeded(bytes32 indexed listingHash, uint indexed challengeID, uint rewardPool, uint totalTokens);
    event _RewardClaimed(uint indexed challengeID, uint reward, address indexed voter);

    enum ListingType {Asset, Service}
    struct Listing {
        uint applicationExpiry; // Expiration date of apply stage
        bool whitelisted;       // Indicates registry status
        address owner;          // Owner of Listing
        uint unstakedDeposit;   // Number of tokens in the listing not locked in a challenge
        uint challengeID;       // Corresponds to a PollID in PLCRVoting
        ListingType objType;    // object type of challenge
    }

    struct Challenge {
        uint rewardPool;        // (remaining) Pool of tokens to be distributed to winning voters
        address challenger;     // Owner of Challenge
        bool resolved;          // Indication of if challenge is resolved
        uint stake;             // Number of tokens at stake for either party during challenge
        uint totalTokens;       // (remaining) Number of tokens used in voting by the winning side
        mapping(address => bool) tokenClaims; // Indicates whether a voter has claimed a reward yet
    }

    // Maps challengeIDs to associated challenge data
    mapping(uint => Challenge) private challenges;

    // Maps listingHashes to associated listingHash data
    mapping(bytes32 => Listing) private listings;

    // Global Variables
    OceanMarket private market;
    OceanToken private token;
    PLCRVoting private voting;

    // general reference of Voting Parameters
    uint minDeposit;        // minimum deposits
    uint applyStageLength;  // time period for application to accept challenges
    uint commitStageLength; // time period for committing votes
    uint revealStageLength; // time period for revealing votes
    uint dispensationPct;   // percentage of slashed tokens for distribution
    uint voteQuorum;        // percentage of majority votes to win

    // ------------
    // CONSTRUCTOR:
    // ------------

    /**
    @dev Contructor         Sets the addresses for token, voting, and parameterizer
    @param _tokenAddr       Address of the TCR's intrinsic ERC20 token
    @param _plcrAddr        Address of a PLCR voting contract for the provided token
    */
    constructor(
        address _tokenAddr,
        address _plcrAddr
    ) public {
        require(_tokenAddr != 0 && address(token) == 0, 'Token contract address is invalid.');
        require(_plcrAddr != 0 && address(voting) == 0, 'Voting contract address is invalid.');

        token = OceanToken(_tokenAddr);
        voting = PLCRVoting(_plcrAddr);

        // default settings of parameters
        minDeposit = 10 * 10 ** 18;
        applyStageLength = 1 hours;
        commitStageLength = 1 hours;
        revealStageLength = 1 hours;
        dispensationPct = 50;
        voteQuorum = 50;
    }

      /**
     * @dev create instance of deployed OceanMarket contract
     * @return valid Boolean indication of contract address is updated
     */
    bool oneTime = true;
    function setMarketInstance(address _market) public returns (bool) {
        require(_market != address(0) && address(market) == address(0) && oneTime, 'Marketplace contract address is invalid.');
        market = OceanMarket(_market);
        oneTime = false;
        return true;
    }

      /**
     @dev                Allows owner to update parameters of voting.
     @param _mDeposit    minimum deposits
     @param _applyTime  time period for application to accept challenges
     @param _commitTime time period for committing votes
     @param _revealTime time period for revealing votes
     @param _dispPct percentage of slashed tokens for distribution
     @param _voteQ percentage of majority votes to win
     */
    function updateParameters(uint _mDeposit, uint _applyTime, uint _commitTime, uint _revealTime, uint _dispPct, uint _voteQ) public onlyOwner() {
        if (_dispPct > 100 || _voteQ > 100)
            return;

        minDeposit = _mDeposit;
        applyStageLength = _applyTime;
        commitStageLength = _commitTime;
        revealStageLength = _revealTime;
        dispensationPct = _dispPct;
        voteQuorum = _voteQ;
    }
      /**
     @dev                Allows owner to query current parameters of voting.
     */
    function getParameters() public view onlyOwner() returns (uint, uint, uint, uint, uint, uint) {
        return (minDeposit, applyStageLength, commitStageLength, revealStageLength, dispensationPct, voteQuorum);
    }

    // --------------------
    // PUBLISHER INTERFACE:
    // --------------------

    /**
    @dev                Allows a user to start an application. Takes tokens from user and sets
                        apply stage end time.
    @param _listingHash The hash of a potential listing a user is applying to add to the registry
    @param _amount      The number of ERC20 tokens a user is willing to potentially stake
    @param _type        the type of listing: 0 - asset, 1 - asset, ...
    @param _data        Extra data relevant to the application. Think IPFS hashes.
    */
    function apply(bytes32 _listingHash, uint _amount, uint _type, string _data) external {
        require(!isWhitelisted(_listingHash), 'already whitelisted');
        require(!appWasMade(_listingHash), 'listing already added');
        require(_amount >= minDeposit, 'min stake size is 10');

        // Sets owner
        Listing storage listing = listings[_listingHash];
        listing.owner = msg.sender;

        // Sets apply stage end time
        /* solium-disable-next-line security/no-block-members */
        listing.applicationExpiry = block.timestamp.add(applyStageLength);
        listing.unstakedDeposit = _amount;
        // set listing type
        listing.objType = ListingType(_type);

        // Transfers tokens from user to Registry contract
        require(token.transferFrom(listing.owner, this, _amount), 'tokens not transferred');

        emit _Application(_listingHash, _amount, listing.applicationExpiry, _data, msg.sender);
    }

    /**
    @dev                Allows the owner of a listingHash to increase their unstaked deposit.
    @param _listingHash A listingHash msg.sender is the owner of
    @param _amount      The number of ERC20 tokens to increase a user's unstaked deposit
    */
    function deposit(bytes32 _listingHash, uint _amount) external {
        Listing storage listing = listings[_listingHash];

        require(listing.owner == msg.sender, 'caller needs ot be listing owner');

        listing.unstakedDeposit.add(_amount);
        require(token.transferFrom(msg.sender, this, _amount), 'tokens not transferred');

        emit _Deposit(_listingHash, _amount, listing.unstakedDeposit, msg.sender);
    }

    /**
    @dev                Allows the owner of a listingHash to decrease their unstaked deposit.
    @param _listingHash A listingHash msg.sender is the owner of.
    @param _amount      The number of ERC20 tokens to withdraw from the unstaked deposit.
    */
    function withdraw(bytes32 _listingHash, uint _amount) external {
        Listing storage listing = listings[_listingHash];

        require(listing.owner == msg.sender, 'caller needs ot be listing owner');
        require(_amount <= listing.unstakedDeposit, 'withdraw amount to high');
        require(listing.unstakedDeposit.sub(_amount) >= minDeposit, 'withdraw would go below min deposit');
        //parameterizer.get('minDeposit'));

        listing.unstakedDeposit -= _amount;
        require(token.transfer(msg.sender, _amount), 'tokens not transferred');

        emit _Withdrawal(_listingHash, _amount, listing.unstakedDeposit, msg.sender);
    }

    /**
    @dev                Allows the owner of a listingHash to remove the listingHash from the whitelist
                        Returns all tokens to the owner of the listingHash
    @param _listingHash A listingHash msg.sender is the owner of.
    */
    function exit(bytes32 _listingHash) external {
        Listing storage listing = listings[_listingHash];

        require(msg.sender == listing.owner, 'caller needs ot be listing owner');
        require(isWhitelisted(_listingHash), 'not whitelisted');

        // Cannot exit during ongoing challenge
        require(listing.challengeID == 0 || challenges[listing.challengeID].resolved, 'challenge not yet resolved');

        // Remove listingHash & return tokens
        resetListing(_listingHash);
        emit _ListingWithdrawn(_listingHash);
    }

    // -----------------------
    // TOKEN HOLDER INTERFACE:
    // -----------------------

    /**
    @dev                Starts a poll for a listingHash which is either in the apply stage or
                        already in the whitelist. Tokens are taken from the challenger and the
                        applicant's deposits are locked.
    @param _listingHash The listingHash being challenged, whether listed or in application
    @param _data        Extra data relevant to the challenge. Think IPFS hashes.
    */
    function challenge(bytes32 _listingHash, string _data) external returns (uint challengeID) {
        Listing storage listing = listings[_listingHash];

        // Listing must be in apply stage or already on the whitelist
        require(appWasMade(_listingHash) || listing.whitelisted, 'not whitelisted');
        // Prevent multiple challenges
        require(listing.challengeID == 0 || challenges[listing.challengeID].resolved, 'challenge not yet resolved');

        if (listing.unstakedDeposit < minDeposit) {
            // Not enough tokens, listingHash auto-delisted
            resetListing(_listingHash);
            emit _TouchAndRemoved(_listingHash);
            return 0;
        }

        // Starts poll
        uint pollID = voting.startPoll(
            voteQuorum,
            commitStageLength,
            revealStageLength
        );

        uint oneHundred = 100;
        challenges[pollID] = Challenge({
            // set tx.origin to trace the original caller in dispute contract
            challenger : tx.origin,
            rewardPool: ((oneHundred.sub(dispensationPct)).mul(minDeposit)).div(100),
            stake : minDeposit,
            resolved : false,
            totalTokens : 0
            });

        // Updates listingHash to store most recent challenge
        listing.challengeID = pollID;

        // Locks tokens for listingHash during challenge
        listing.unstakedDeposit -= minDeposit;

        // Takes tokens from challenger
        require(token.transferFrom(tx.origin, this, minDeposit), 'tokens not transferred');

        (uint commitEndDate, uint revealEndDate, , , ,) = voting.pollMap(pollID);

        emit _Challenge(_listingHash, pollID, _data, commitEndDate, revealEndDate, tx.origin);
        return pollID;
    }

    /**
    @dev                Updates a listingHash's status from 'application' to 'listing' or resolves
                        a challenge if one exists.
    @param _listingHash The listingHash whose status is being updated
    */
    function updateStatus(bytes32 _listingHash) public {
        if (canBeWhitelisted(_listingHash)) {
            whitelistApplication(_listingHash);
        } else if (challengeCanBeResolved(_listingHash)) {
            resolveChallenge(_listingHash);
        } else {
            revert('status cannot be updated');
        }
    }

    // ----------------
    // TOKEN FUNCTIONS:
    // ----------------

    /**
    @dev                Called by a voter to claim their reward for each completed vote. Someone
                        must call updateStatus() before this can be called.
    @param _challengeID The PLCR pollID of the challenge a reward is being claimed for
    @param _salt        The salt of a voter's commit hash in the given poll
    */
    function claimReward(uint _challengeID, uint _salt) public {
        // Ensures the voter has not already claimed tokens and challenge results have been processed
        require(challenges[_challengeID].tokenClaims[msg.sender] == false, 'tokens already claimed');
        require(challenges[_challengeID].resolved == true, 'challenge not resolved');

        uint voterTokens = voting.getNumPassingTokens(msg.sender, _challengeID, _salt);
        uint reward = voterReward(msg.sender, _challengeID, _salt);

        // Subtracts the voter's information to preserve the participation ratios
        // of other voters compared to the remaining pool of rewards
        challenges[_challengeID].totalTokens -= voterTokens;
        challenges[_challengeID].rewardPool -= reward;

        // Ensures a voter cannot claim tokens again
        challenges[_challengeID].tokenClaims[msg.sender] = true;

        require(token.transfer(msg.sender, reward), 'tokens not transferred');

        emit _RewardClaimed(_challengeID, reward, msg.sender);
    }

    // --------
    // GETTERS:
    // --------

    /**
    @dev                Calculates the provided voter's token reward for the given poll.
    @param _voter       The address of the voter whose reward balance is to be returned
    @param _challengeID The pollID of the challenge a reward balance is being queried for
    @param _salt        The salt of the voter's commit hash in the given poll
    @return             The uint indicating the voter's reward
    */
    function voterReward(address _voter, uint _challengeID, uint _salt)
    public view returns (uint) {
        uint totalTokens = challenges[_challengeID].totalTokens;
        uint rewardPool = challenges[_challengeID].rewardPool;
        uint voterTokens = voting.getNumPassingTokens(_voter, _challengeID, _salt);
        return voterTokens.mul(rewardPool).div(totalTokens);
    }

    /**
    @dev                Determines whether the given listingHash be whitelisted.
    @param _listingHash The listingHash whose status is to be examined
    */
    function canBeWhitelisted(bytes32 _listingHash) public view returns (bool) {
        uint challengeID = listings[_listingHash].challengeID;

        // Ensures that the application was made,
        // the application period has ended,
        // the listingHash can be whitelisted,
        // and either: the challengeID == 0, or the challenge has been resolved.
        if (
        /* solium-disable-next-line security/no-block-members */
            appWasMade(_listingHash) && listings[_listingHash].applicationExpiry < block.timestamp && !isWhitelisted(_listingHash) && (challengeID == 0 || challenges[challengeID].resolved == true)
        ) {
            return true;
        }

        return false;
    }

    /**
    @dev                Returns true if the provided listingHash is whitelisted
    @param _listingHash The listingHash whose status is to be examined
    */
    function isWhitelisted(bytes32 _listingHash) public view returns (bool whitelisted) {
        return listings[_listingHash].whitelisted;
    }

    /**
    @dev                Returns true if apply was called for this listingHash
    @param _listingHash The listingHash whose status is to be examined
    */
    function appWasMade(bytes32 _listingHash) public view returns (bool exists) {
        return listings[_listingHash].applicationExpiry > 0;
    }

    /**
    @dev                Returns true if the application/listingHash has an unresolved challenge
    @param _listingHash The listingHash whose status is to be examined
    */
    function challengeExists(bytes32 _listingHash) public view returns (bool) {
        uint challengeID = listings[_listingHash].challengeID;

        return (listings[_listingHash].challengeID > 0 && !challenges[challengeID].resolved);
    }

    /**
    @dev                Determines whether voting has concluded in a challenge for a given
                        listingHash. Throws if no challenge exists.
    @param _listingHash A listingHash with an unresolved challenge
    */
    function challengeCanBeResolved(bytes32 _listingHash) public view returns (bool) {
        uint challengeID = listings[_listingHash].challengeID;

        require(challengeExists(_listingHash), 'challenge does not exist');

        return voting.pollEnded(challengeID);
    }

    /**
    @dev                Determines the number of tokens awarded to the winning party in a challenge.
    @param _challengeID The challengeID to determine a reward for
    */
    function determineReward(uint _challengeID) public view returns (uint) {
        require(!challenges[_challengeID].resolved && voting.pollEnded(_challengeID), 'challenge not resolved or poll not ended yet');

        // Edge case, nobody voted, give all tokens to the challenger.
        if (voting.getTotalNumberOfTokensForWinningOption(_challengeID) == 0) {
            return 2 * challenges[_challengeID].stake;
        }

        return (2 * challenges[_challengeID].stake) - challenges[_challengeID].rewardPool;
    }

    /**
    @dev                Getter for Challenge tokenClaims mappings
    @param _challengeID The challengeID to query
    @param _voter       The voter whose claim status to query for the provided challengeID
    */
    function tokenClaims(uint _challengeID, address _voter) public view returns (bool) {
        return challenges[_challengeID].tokenClaims[_voter];
    }

    // ----------------
    // PRIVATE FUNCTIONS:
    // ----------------

    /**
    @dev                Determines the winner in a challenge. Rewards the winner tokens and
                        either whitelists or de-whitelists the listingHash.
    @param _listingHash A listingHash with a challenge that is to be resolved
    */
    function resolveChallenge(bytes32 _listingHash) private {
        uint challengeID = listings[_listingHash].challengeID;

        // Calculates the winner's reward,
        // which is: (winner's full stake) + (dispensationPct * loser's stake)
        uint reward = determineReward(challengeID);

        // Sets flag on challenge being processed
        challenges[challengeID].resolved = true;

        // Stores the total tokens used for voting by the winning side for reward purposes
        challenges[challengeID].totalTokens = voting.getTotalNumberOfTokensForWinningOption(challengeID);

        // Case: challenge failed
        if (voting.isPassed(challengeID)) {
            whitelistApplication(_listingHash);
            // Unlock stake so that it can be retrieved by the applicant
            listings[_listingHash].unstakedDeposit += reward;

            emit _ChallengeFailed(_listingHash, challengeID, challenges[challengeID].rewardPool, challenges[challengeID].totalTokens);
        }
        // Case: challenge succeeded or nobody voted
        else {
            resetListing(_listingHash);
            // Transfer the reward to the challenger
            require(token.transfer(challenges[challengeID].challenger, reward), 'tokens not transferred');

            emit _ChallengeSucceeded(_listingHash, challengeID, challenges[challengeID].rewardPool, challenges[challengeID].totalTokens);
        }
    }

    /**
    @dev                Called by updateStatus() if the applicationExpiry date passed without a
                        challenge being made. Called by resolveChallenge() if an
                        application/listing beat a challenge.
    @param _listingHash The listingHash of an application/listingHash to be whitelisted
    */
    function whitelistApplication(bytes32 _listingHash) private {
        if (!listings[_listingHash].whitelisted) {
            emit _ApplicationWhitelisted(_listingHash);
        }
        listings[_listingHash].whitelisted = true;
    }

    /**
    @dev                Updates a Asset or Actor status in Marketplace when 'exit' or 'updateStatus'
    @param _listingHash The Id of asset or actor whose status is being updated
    */
    function changeListingStatus(bytes32 _listingHash) public {
        Listing storage listing = listings[_listingHash];
        // change asset status according to voting result
        if(listing.objType == ListingType.Asset){
            market.deactivateAsset(_listingHash);
        }
    }

    /**
    @dev                Deletes a listingHash from the whitelist and transfers tokens back to owner
    @param _listingHash The listing hash to delete
    */
    function resetListing(bytes32 _listingHash) private {
        Listing storage listing = listings[_listingHash];

        // Emit events before deleting listing to check whether is whitelisted
        if (listing.whitelisted) {
            emit _ListingRemoved(_listingHash);
        } else {
            emit _ApplicationRemoved(_listingHash);
        }

        // update asset or actor status to be disabled
        listings[_listingHash].whitelisted = false;
        changeListingStatus(_listingHash);

        // Deleting listing to prevent reentry
        address owner = listing.owner;
        uint unstakedDeposit = listing.unstakedDeposit;
        delete listings[_listingHash];

        // Transfers any remaining balance back to the owner
        if (unstakedDeposit > 0) {
            require(token.transfer(owner, unstakedDeposit), 'tokens not transferred');
        }
    }
}
