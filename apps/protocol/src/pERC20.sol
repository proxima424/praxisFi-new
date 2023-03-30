// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// DEPENDENCIES
import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract pERC20 is ERC20, Ownable {
    // ABOUT OPENZEPPELIN ERC20
    // functions revert* instead returning `false` on failure.
    // Need to define a supply mechanism using
    // internal functions _mint and _burn

    // To be deployed by the factory contract
    // To set itself as the Owner
    // Minting, Burning will be done only by pFACTORY.sol
    constructor() ERC20("Praxis ETH3XUP", "ETH3XUP") {}

    function mint(address recepient, uint256 amount) external onlyOwner {
        _mint(recepient, amount);
    }

    function burn(address recepient, uint256 amount) external onlyOwner {
        _burn(recepient, amount);
    }
}
