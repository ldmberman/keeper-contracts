pragma solidity ^0.4.24;

/**
@title Ocean-Fitchain Break-in Contract
@author  Ahmed Ali
*/

contract Fitchain {

    // Proof of Training
    struct Proof {
        bytes32 msg;    // hash of PoT
        bytes32 [] sigs; // signatures
        address [] validators; //  public key
    }

    struct Model {
        uint256 k; // number of validators
        address consumer;
        address mlProvider;
        address dataProvider;
        bytes32 result; // result key on ipfs
        bytes32 service;    // service agreement ID
        bytes32 proof;// proof of training
    }

    // condition id in ocean and model ID in Fitchain
    mapping (bytes32 => Model) models;
    mapping (bytes32 => Proof) proofs;

    event InvokeFitchainPoT(bytes32 modelId, address consumer, address mlProvider, address dataProvider, bytes32 mlAsset, bytes32 dataAsset);
    event PublishResult(bytes32 condition, bytes32 service, bytes32 result);

    function invoke(bytes32 condition, uint256 k, bytes32 service, address consumer, address mlProvider, address dataProvider, bytes32 mlAsset, bytes32 dataAsset) public {
        // TODO: check condition ID (model ID) is exist from service agreement
        Model memory m = Model(k, consumer, mlProvider, dataProvider, bytes32(0), service, bytes32(0));
        models[condition] = m;
        emit InvokeFitchainPoT(condition, consumer, mlProvider, dataProvider, mlAsset, dataAsset);
    }

    function getProof(bytes32 modelId, bytes32 msg, bytes32 [] sigs, address [] validators, bytes32 result) public {
        // TODO: 1. verify Proof of training
        // TODO: 2. fulfill condition in service agreement
        // TODO: 3. publish result hash on ipfs
        emit PublishResult(modelId, models[modelId].service, result);
    }


}
