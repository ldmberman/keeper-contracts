# Analysis results for OceanAuth.json

## Exception state

- Type: Informational
- Contract: Unknown
- Function name: `fallback`
- PC address: 1113

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: OceanAuth.json:50

### Code

```
accessControlRequests[id].status == AccessStatus.Committed
```

## Message call to external contract

- Type: Informational
- Contract: Unknown
- Function name: `fallback`
- PC address: 1352

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanAuth.json:180

### Code

```
market.refundPayment(id)
```

## Exception state

- Type: Informational
- Contract: Unknown
- Function name: `_function_0x640f3255`
- PC address: 3331

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: OceanAuth.json:50

### Code

```
accessControlRequests[id].status == AccessStatus.Committed
```

## Exception state

- Type: Informational
- Contract: Unknown
- Function name: `_function_0x740568ca`
- PC address: 3653

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: OceanAuth.json:204

### Code

```
accessControlRequests[id].status == AccessStatus.Requested
```

## Unchecked CALL return value

- Type: Informational
- Contract: Unknown
- Function name: `_function_0x8677ebe8`
- PC address: 3944

### Description

The return value of an external call is not checked. Note that execution continue even if the called contract throws.
In file: OceanAuth.json:168

### Code

```
ecrecover(msgHash, v, r, s)
```

# Analysis result for SafeMath

No issues found.
# Analysis result for BasicToken

No issues found.
# Analysis result for StandardToken

No issues found.
# Analysis results for EIP20.json

## Integer Overflow 

- Type: Warning
- Contract: Unknown
- Function name: `fallback`
- PC address: 723

### Description

A possible integer overflow exists in the function `fallback`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: EIP20.json:20

### Code

```
string public name
```

## Integer Overflow 

- Type: Warning
- Contract: Unknown
- Function name: `_function_0x23b872dd`
- PC address: 1054

### Description

A possible integer overflow exists in the function `_function_0x23b872dd`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: EIP20.json:48

### Code

```
balances[_to] += _value
```

# Analysis results for OceanMarket.json

## Integer Overflow 

- Type: Warning
- Contract: Unknown
- Function name: `_function_0xf7d59935`
- PC address: 216

### Description

A possible integer overflow exists in the function `_function_0xf7d59935`.
The addition or multiplication may result in a value higher than the maximum representable integer.
In file: OceanMarket.json:134

### Code

```
tion generateId(string contents) public pure returns (bytes32) {
        // Generate the hash of input bytes
        return bytes32(keccak256(abi.encodePacked(contents)));
    }

  
```

## Exception state

- Type: Informational
- Contract: Unknown
- Function name: `_function_0x48e68950`
- PC address: 956

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: OceanMarket.json:117

### Code

```
ments[_paymentId].state == PaymentState.Locked || 
```

## Message call to external contract

- Type: Informational
- Contract: Unknown
- Function name: `_function_0x49d32de1`
- PC address: 1238

### Description

This contract executes a message call to to another contract. Make sure that the called contract is trusted and does not execute user-supplied code.
In file: OceanMarket.json:91

### Code

```
en.transferFrom(msg.sender, address(this), _amount), 'T
```

## Exception state

- Type: Informational
- Contract: Unknown
- Function name: `_function_0x7aa1ed58`
- PC address: 1755

### Description

A reachable exception (opcode 0xfe) has been detected. This can be caused by type errors, division by zero, out-of-bounds array access, or assert violations. This is acceptable in most situations. Note however that `assert()` should only be used to check invariants. Use `require()` for regular input checking.
In file: OceanMarket.json:49

### Code

```
mPayments[_paymentId].state == PaymentState.Locked
```

# Analysis result for Ownable

No issues found.
# Analysis result for OceanToken

No issues found.
