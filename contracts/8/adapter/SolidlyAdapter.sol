// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interfaces/IAdapter.sol";
import "../interfaces/ISolidly.sol";
import "../interfaces/IERC20.sol";

contract SolidlyAdapter is IAdapter {

    // fromToken == token0
    function sellBase(
        address to,
        address pool,
        bytes memory
    ) external override {
        address baseToken = IPair(pool).token0();
        (uint256 _reserve0, uint256 _reserve1,) = IPair(pool).getReserves();
        require(
            _reserve0 > 0 && _reserve1 > 0,
            "Solidly: INSUFFICIENT_LIQUIDITY"
        );

        uint256 balance0 = IERC20(baseToken).balanceOf(pool);
        uint256 sellBaseAmount = balance0 - _reserve0;
        uint256 receiveQuoteAmount = IPair(pool).getAmountOut(sellBaseAmount, baseToken);

        IPair(pool).swap(0, receiveQuoteAmount, to, new bytes(0));
    }

    // fromToken == token1
    function sellQuote(
        address to,
        address pool,
        bytes memory
    ) external override {
        address quoteToken = IPair(pool).token1();
        (uint256 _reserve0, uint256 _reserve1,) = IPair(pool).getReserves();

        require(
            _reserve0 > 0 && _reserve1 > 0,
            "Solidly: INSUFFICIENT_LIQUIDITY"
        );

        uint256 balance1 = IERC20(quoteToken).balanceOf(pool);
        uint256 sellQuoteAmount = balance1 - _reserve1;
        uint256 receiveBaseAmount = IPair(pool).getAmountOut(sellQuoteAmount, quoteToken);

        IPair(pool).swap(receiveBaseAmount, 0, to, new bytes(0));
    }

}