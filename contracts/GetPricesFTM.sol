// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IHelp.sol";

interface IFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract GetPricesFTM  {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // WFTM token address
    IERC20 private constant WFTM = IERC20(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83);
    // BUSD token address
    IERC20 private constant USDC = IERC20(0x04068DA6C83AFCFA0e13ba15A6696662335D5B75);    
    // Lp FTM_BUSD_POOL token address
    address private constant Swap_USD_POOL = 0x0000000000000000000;

    // Returns the price of bnb in usd
    function bnbPriceInUSD() public view returns(uint) {
        uint _usdc = USDC.balanceOf(Swap_USD_POOL).mul(1e18);
        uint _wftm = WFTM.balanceOf(Swap_USD_POOL).mul(1e6);
        return _busd.mul(1e18).div(_wbnb);
    }

    // Returns the price of a token in FTM
    function tokenPriceInFTM(address _token, IFactory factory) public view returns(uint) {
        address pair = factory.getPair(_token, address(WFTM));
        uint decimal = uint(ERC20(_token).decimals());
        return WFTM.balanceOf(pair).mul(10**decimal).div(IERC20(_token).balanceOf(pair));
    }

    // Returns the price of a token in FTM
    function priceInFTM(address _token, address pair) public view returns(uint) {
        return WFTM.balanceOf(pair).mul(1e18).div(IERC20(_token).balanceOf(pair));
    }    

    // Returns the price of a token in usd
    function tokenPriceInUSD(address _token, IFactory factory) public view returns(uint) {
        uint _priceInFTM = tokenPriceInFTM(_token, factory);
        uint priceFTM = bnbPriceInUSD();
        return priceFTM.mul(_priceInFTM);
    }  

}