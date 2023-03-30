// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// DEPENDENCIES, imports

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {IPool} from "../lib/aave-v3-core/contracts/interfaces/IPool.sol";
import {SwapHelper} from "./uniswapHelper/pUNISWAP.sol";
import {ISwapRouter} from "../lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {FlashLoanSimpleReceiverBase} from "../lib/aave-v3-core/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";

/// @author proxima424 <https://github.com/proxima424>
/// Contract is Ownable to provide the onlyOwner modifier
/// for initialization functions like Deploying pERC20

abstract contract pFACTORY is Ownable, FlashLoanSimpleReceiverBase {
    // STEPS IN A NUTSHELL
    // 1->
    // 2->
    // 3->
    // 4->
    // 5->

    /*//////////////////////////////////////////////////////////////
                        CONTRACT ADDRESSES
    //////////////////////////////////////////////////////////////*/

    // aave pool
    address public immutable aavePool;

    // ETH3XUP onlyOwner ERC20
    address public ETH3XUP;

    // deposit token address
    address public immutable depositToken;

    // borrow token address
    address public immutable borrowToken;

    // swapping messiah
    SwapHelper public uniswap_swapper;

    /*//////////////////////////////////////////////////////////////
                              ERRORS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                              EVENTS
    //////////////////////////////////////////////////////////////*/
    event MintedETH3XUP(address indexed owner, uint256 mintedTokens);

    // STORAGE VARIABLES

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
                            INITIALIZATIONS
    //////////////////////////////////////////////////////////////*/

    constructor(address _depositToken, address _borrowToken, address _aavePool, address _swapRouter) {
        depositToken = _depositToken;
        borrowToken = _borrowToken;
        aavePool = _aavePool;
        uniswap_swapper = new SwapHelper(ISwapRouter(_swapRouter));
    }

    /*//////////////////////////////////////////////////////////////
                        ADMIN ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function deployERC20() external onlyOwner {}
    function deLeverage() external onlyOwner {}
    function reLeverage() external onlyOwner {}
    function getLeverage() public {}

    /*//////////////////////////////////////////////////////////////
                            STATELESS FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    // Get contract's deposit token balance
    function get_depositToken_holding() public returns (uint256) {
        return IERC20(depositToken).balanceOf(address(this));
    }

    // Get contract's borrow token balance
    function get_borrowToken_holding() public returns (uint256) {
        return IERC20(borrowToken).balanceOf(address(this));
    }

    /*//////////////////////////////////////////////////////////////
                        AAVE HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    // Give Allowance damn
    function give_Allowances() external onlyOwner {
        IERC20(aavePool).approve(depositToken, type(uint256).max);
        IERC20(aavePool).approve(borrowToken, type(uint256).max);
    }

    // DEPOSIT IN AAVE
    function supply_depositToken(uint256 amount) internal {
        IPool(aavePool).supply(depositToken, amount, address(this), 0);
    }

    // BORROW FROM AAVE
    function borrow_borrowToken(uint256 amount) internal {
        IPool(aavePool).borrow(borrowToken, amount, 1, 0, address(this));
    }

    // COLLATERAL POSITION
    function aavePosition_depositToken() public returns (uint256) {
        (uint256 a,,,,,) = IPool(aavePool).getUserAccountData(address(this));
        return a;
    }

    // BORROW POSITION
    function aavePosition_borrowToken() public returns (uint256) {
        (, uint256 a,,,,) = IPool(aavePool).getUserAccountData(address(this));
    }

    // COLLATERAL AND BORROW POSITION
    function aavePosition_full() public returns (uint256 a, uint256 b) {
        (a, b,,,,) = IPool(aavePool).getUserAccountData(address(this));
    }

    /*//////////////////////////////////////////////////////////////
                           FLASHLOAN
                              AND
                              THE
                            M-A-I-N
                            C-O-R-E
                          FUNCTIONALITY
    //////////////////////////////////////////////////////////////*/

    // Internal Flashloan Requesting Function
    function requestFlashloan() internal {
        
    }

    function executeOperation(address asset, uint256 amount, uint256 premium, address initiator, bytes calldata params)
        external
        override
        returns (bool)
    {}
}
