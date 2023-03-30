// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "../lib/forge-std/src/Test.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {SwapHelper} from "../src/uniswapHelper/pUNISWAP.sol";
import {ISwapRouter} from "../lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract SwapTester is Test {
    uint256 ethFork;
    address daiToken = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address wethToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    SwapHelper public swapper;

    function setUp() public {
        ethFork = vm.createFork("https://eth.llamarpc.com");
        vm.selectFork(ethFork);
        swapper = new SwapHelper(ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564));
    }

    // function testTransferDAI() public {
    //     address drake = makeAddr("drake");
    //     address rich = 0x075e72a5eDf65F0A5f44699c7654C1a76941Ddc8;
    //     vm.prank(rich);
    //     IERC20(daiToken).transfer(drake,1000000);
    //     assertEq(IERC20(daiToken).balanceOf(drake),1000000);
    // }

    function testSwap() public {
        address drake = makeAddr("drake");
        address rich = 0x075e72a5eDf65F0A5f44699c7654C1a76941Ddc8;

        uint256 i_weth_rich = IERC20(wethToken).balanceOf(rich);
        uint256 i_weth_drake = IERC20(wethToken).balanceOf(drake);

        uint256 i_dai_rich = IERC20(daiToken).balanceOf(rich);
        uint256 i_dai_drake = IERC20(daiToken).balanceOf(drake);

        vm.startPrank(rich);
        // approve swapper contract DAI and WETH tokens by the Swapper
        IERC20(daiToken).approve(address(swapper), type(uint256).max);
        IERC20(wethToken).approve(address(swapper), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(rich);
        // DAI TO WETH
        uint256 out_dai = swapper.swapFixedOutput(2 * 10 ** 18, 4000 * 10 ** 18);
        vm.stopPrank();

        assertEq(IERC20(wethToken).balanceOf(rich) - i_weth_rich, 2 * 10 ** 18);
        assertEq(i_dai_rich - IERC20(daiToken).balanceOf(rich), out_dai);

        vm.startPrank(rich);
        IERC20(wethToken).transfer(drake, 2 * 10 ** 18);
        vm.stopPrank();

        assertEq(IERC20(wethToken).balanceOf(drake), 2 * 10 ** 18);
    }
}
