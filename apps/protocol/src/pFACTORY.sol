// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// DEPENDENCIES, imports

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {IPool} from "../lib/aave-v3-core/contracts/interfaces/IPool.sol";

/// @author proxima424 <https://github.com/proxima424>
/// Contract is Ownable to provide the onlyOwner modifier
/// for initialization functions like Deploying pERC20

contract pFACTORY is Ownable {
    // STEPS IN A NUTSHELL
    // 1->
    // 2->
    // 3->
    // 4->
    // 5->

    // INITIALIZE CONTRACT ADDRESSES

    address public immutable aavePool;

    // To be set via calling deployERC20()
    address public ETH3XUP;

    address public immutable depositToken;

    address public immutable borrowToken;

    // ERRORS

    // EVENTS
    event MintedETH3XUP(address indexed owner, uint256 mintedTokens);

    // STORAGE VARIABLES

    // CONSTRUCTOR INITIALIZATIONS
    constructor(address _depositToken, address _borrowToken, address _aavePool) {
        depositToken = _depositToken;
        borrowToken = _borrowToken;
        aavePool = _aavePool;
    }

    // Deploys ERC20 ETH3XUP token
    function deployERC20() public onlyOwner {}

    /*//////////////////////////////////////////////////////////////
                            STATELESS FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    // Get contract's deposit token balance
    function get_depositTokenBalance() public returns (uint256) {
        return IERC20(depositToken).balanceOf(address(this));
    }

    // Get contract's borrow token balance
    function get_borrowTokenBalance() public returns (uint256) {
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

    // CORE FUNCTIONS
}
