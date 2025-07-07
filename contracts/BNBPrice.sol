// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@pancakeswap/v3-core/contracts/interfaces/IPancakeV3Factory.sol";
import "@pancakeswap/v3-core/contracts/interfaces/IPancakeV3Pool.sol";
import "@pancakeswap/v3-periphery/contracts/libraries/OracleLibrary.sol";


contract BNBPrice{
    address public bnb;
    address public usd;
    address public owner;

    address[] public poolsUSD;

    constructor(address _bnb, address _usd){
        owner = msg.sender;
        // Main network bnb : 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c (wraped)
        // Test network bnb : 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
        
        bnb = _bnb;
        // Main network usd : 0x9e5AAC1Ba1a2e6aEd6b32689DFcF62A509Ca96f3 (USDT)
        // Main network usd : 0x55d398326f99059fF775485246999027B3197955 (Binance-Peg BSC-USD)
        // Test network usd : 0x55d398326f99059fF775485246999027B3197955
        usd = _usd;
    }

    modifier onlyOwner{
        require(msg.sender==owner);
        _;
    }

    function addPoolUSD(address _factory, uint24 _fee) external onlyOwner {
        address pool = IPancakeV3Factory(_factory).getPool(
            usd,
            bnb,
            _fee
        );
        require(pool != address(0));
        poolsUSD.push(pool);
    }

    function removePoolUSD(uint8 index) external onlyOwner{
        poolsUSD[index] = poolsUSD[poolsUSD.length - 1];
        poolsUSD.pop();
    }

    function checkPriceUSD(uint8 index) external view  returns (uint price){
        (,int24 tick,,,,,) = IPancakeV3Pool(poolsUSD[index]).slot0();
        price = OracleLibrary.getQuoteAtTick(
            tick, 1e18, usd, bnb
            );
        
    }
    
    function averageUSDbnb() public view returns (uint average) {
        uint prices;
        for (uint8 i = 0; i < poolsUSD.length ; i ++ )
        {
            (,int24 tick,,,,,) = IPancakeV3Pool(poolsUSD[i]).slot0();
            uint price = OracleLibrary.getQuoteAtTick(
                tick, 1e18, usd, bnb
            );
            prices = prices+price;
        }
        average = prices/poolsUSD.length;
        return average;
    }

    function setBnbAddress(address _bnb) public onlyOwner{
        bnb = _bnb;
    }



    function setUsdAddress(address _usd) public onlyOwner{
        usd = _usd;
    }
}

