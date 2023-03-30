// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "../lib/forge-std/src/Test.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";

contract SwapTester is Test {

    uint256 ethFork;
    address daiToken = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    function setUp() public {
        ethFork = vm.createFork("https://eth.llamarpc.com");
        vm.selectFork(ethFork);
    }

    function testTransferDAI() public {
        address drake = makeAddr("drake");
        address rich = 0x075e72a5eDf65F0A5f44699c7654C1a76941Ddc8;
        vm.prank(rich);
        IERC20(daiToken).transfer(drake,1000000);
        assertEq(IERC20(daiToken).balanceOf(drake),1000000);
    }


}
