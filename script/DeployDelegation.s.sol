
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Delegate, Delegation} from "../src/Delegation.sol";

contract DeployDelegation is Script {

    Delegate delegate;
    Delegation delegation;

    address public ownerOfDelegateContract = makeAddr("ownerOfDelegate");
    address public ownerOfDelegationContract = makeAddr("ownerOfDelegation");

    function run() external returns(Delegate, Delegation) {
        vm.startBroadcast(ownerOfDelegationContract);
        delegate = new Delegate(ownerOfDelegateContract);
        delegation = new Delegation(address(delegate));
        vm.stopBroadcast();
        return (delegate, delegation);
    }

}