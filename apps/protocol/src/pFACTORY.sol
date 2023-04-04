// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// pERC20
import {pERC20} from "../src/pERC20.sol";

// openzeppelins
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";

// aave
import {IPool} from "../lib/aave-v3-core/contracts/interfaces/IPool.sol";
import {FlashLoanSimpleReceiverBase} from "../lib/aave-v3-core/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";

// uniswap
import {SwapHelper} from "./uniswapHelper/pUNISWAP.sol";
import {ISwapRouter} from "../lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";


/// @author proxima424 <https://github.com/proxima424>
/// Contract is Ownable to provide the onlyOwner modifier
/// for initialization functions like Deploying pERC20

abstract contract pFACTORY is Ownable, FlashLoanSimpleReceiverBase {
    // MINTING STEPS IN A NUTSHELL
    // 1-> Deposits X WETH
    // 2-> Take flashloan for 2X WETH
    // 3-> Deposit 3X WETH in AAVE
    // 4-> Borrow 2X* from AAVE
    // 5->

    /*//////////////////////////////////////////////////////////////
                        CONTRACT ADDRESSES
    //////////////////////////////////////////////////////////////*/

    // aave pool
    address public immutable aavePool;

    // ETH3XUP onlyOwner ERC20
    address public ETH3XUP;
    pERC20 public p_ETH3XUP;

    // deposit token address
    address public immutable depositToken;

    // borrow token address
    // need to be a stablecoin
    address public immutable borrowToken;

    // swapping messiah
    SwapHelper public uniswap_swapper;

    // Chainlink Price Denomination
    uint256 chainlink_decimals = 8;

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
    function deployERC20() external onlyOwner {
        p_ETH3XUP = new pERC20();
        ETH3XUP = address(p_ETH3XUP);
    }
    function deLeverage() external onlyOwner {}
    function reLeverage() external onlyOwner {}
    function getLeverage() public {
         
    }

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

    /// @param _amount WETH amount in 10**18 denomination
    function praxisFinance_deposit(uint256 _amount) external {
        require(_amount != 0 );
        IERC20(depositToken).transferFrom(msg.sender,address(this),_amount);
        uint256 curr_ethPrice = get_currentEthPrice();
        bytes memory request_params = abi.encode(_amount,msg.sender,curr_ethPrice);
        requestFlashloan(depositToken,2*(_amount),request_params);
    }

    // Internal Flashloan Requesting Function
    function requestFlashloan(address _token, uint256 _amount, bytes memory _params) internal {
        address receiverAddress = address(this);
        address asset = _token;
        uint256 amount = _amount;
        // encode params here
        bytes memory params = _params;
        uint16 referralCode = 0;

        IPool(AAVE_POOL_POLYGON).flashLoanSimple(
            receiverAddress, asset, amount, params, referralCode
        );
    }

    /// @param asset Deposit Token Address
    /// @param amount 2*X WETH
    /// @param premium
    /// @param params
    function executeOperation(address asset, uint256 amount, uint256 premium, address initiator, bytes calldata params)
        external
        override
        returns (bool)
    {
        // Get X amount from params
        ( uint256 depositAmount, address recepient, uint256 curr_ethPrice ) = abi.decode(params,(uint256,address,uint256));

        // We now have 3X WETH
        // Deposit these 3X in AAVE
        supply_depositToken(3*depositAmount);

        // ( Borrow 2*depositAmount*USDC Amount ) USDC
        uint256 borrowAmount = 2*depositAmount*curr_ethPrice*100;
        borrowAmount = borrowAmount * 98;

        borrow_borrowToken(borrowAmount);

        // Swap USDC to WETH
        // swapFixedAmount ( kya chahiye, kitne doge )
        uniswap_swapper.swapFixedOutput(2*depositAmount, borrowAmount);

        // Now the contract will return funds to the Flashloan

        // calculate tokens to mint and fucking mint them to address recepient
        // In 10**18 denomination
        uint256 tokensToMint = calculate_tokensToMint(depositAmount, curr_ethPrice);

        IERC20(ETH3XUP).mint(recepient,tokensToMint);

    }

    function get_currentEthPrice() internal returns(uint256){}

    // Calculate tokens to mint
    // Based on input Eth Tokens
    // INVARIANT
    function calculate_tokensToMint(uint256 amountInEth, uint256 curr_ethPrice ) public returns(uint256){
        // Contract State before TX = Contract State after TX

        uint256 tSupply = IERC20(ETH3XUP).totalSupply(); // in 10**18 denomination

        uint256 curr_price = curr_ethPrice / (10**chainlink_decimals);

        uint256 weth_position = aavePosition_depositToken(); // in 10**8 denomination
        uint256 usdc_position = aavePosition_borrowToken(); // in 10**8 denomination

        weth_position = weth_position * 10**10;
        usdc_position = usdc_position * 10**10;

        uint256 prev_ETH3XUP_price = ( weth_position - usdc_position ) / tSupply;

        uint256 curr_ETH3XUP_price = ( weth_position + 3*amountInEth ) - ( usdc_position + 2*amountInEth*curr_price );

        uint256 tokensToMint =  ( curr_ETH3XUP_price ) / prev_ETH3XUP_price ;

        tokensToMint -= tSupply;
    }
}
