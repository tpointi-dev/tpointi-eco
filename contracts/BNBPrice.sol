// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@pancakeswap/v3-core/contracts/interfaces/IPancakeV3Factory.sol";
import "@pancakeswap/v3-core/contracts/interfaces/IPancakeV3Pool.sol";
import "@pancakeswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

// Main network bnb : 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c ( wraped )
// Main network usd : 0x55d398326f99059fF775485246999027B3197955 ( Binance-Peg BSC-USD )
// Main network factory : 0x0BFbCF9fa4f9C56B0F40a671Ad40E0805A091865
// 100000000000000


contract BNBPrice{
    address public bnb;
    address public usd;
    address payable public owner;
    mapping( address => bool ) private eqMode; //   averageBnbToUsd ? averageUsdToBnb
    address[] public poolsUSD;
    event callAverage(address caller , uint tickPrice);

    constructor(address _bnb, address _usd){
        owner = payable(msg.sender);
        bnb = _bnb;
        usd = _usd;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    function addPoolUSD(address _factory, uint24 _fee) external onlyOwner {
        address pool = IPancakeV3Factory(_factory).getPool(
            usd,
            bnb,
            _fee
        );
        require(pool != address(0) , "Pool Not Found");
        poolsUSD.push(pool);
    }

    function removePoolUSD(uint8 index) external onlyOwner{
        poolsUSD[index] = poolsUSD[poolsUSD.length - 1];
        poolsUSD.pop();
    }

    function usdToBnb(uint8 index) external view  returns (uint price){
        (,int24 tick,,,,,) = IPancakeV3Pool(poolsUSD[index]).slot0();
        price = OracleLibrary.getQuoteAtTick(
            tick, 1e18, usd, bnb
            );
        
    }


    function bnbToUsd(uint8 index) external view  returns (uint price){
        (,int24 tick,,,,,) = IPancakeV3Pool(poolsUSD[index]).slot0();
        price = OracleLibrary.getQuoteAtTick(
            tick, 1e18, bnb, usd
            );
        
    }
    
    
    function _average( bool _mode ) internal view returns (uint average) {
        uint prices;
        uint8 truePoolsLenght;
        for (uint8 i = 0; i < poolsUSD.length ; i ++ )
        {
            (,int24 tick,,,,,) = IPancakeV3Pool(poolsUSD[i]).slot0();
            uint price = OracleLibrary.getQuoteAtTick(
                tick, 
                1e18, 
                _mode ? usd : bnb , 
                _mode ? bnb : usd
            );
            if (price != 0) {
                prices += price;
                truePoolsLenght++;
            }
        }
        require(prices != 0 , "No price founded");
        average = prices/truePoolsLenght;
        return average;
    }

    function setBnbAddress(address _bnb) public onlyOwner{
        bnb = _bnb;
    }

    function setUsdAddress(address _usd) public onlyOwner{
        usd = _usd;
    }



    function getAverage() external payable returns (uint256 , string memory) {
        require(msg.value == 100000000000000, "Send more BNB"); //=> 0.0001 bnb 
        uint result = _average(eqMode[msg.sender]);
        emit callAverage(msg.sender, msg.value);

        return (result , eqMode[msg.sender] ? "USDTBNB" : "BNBUSDT");
    }


    
    function setEqMode() public {
        eqMode[msg.sender] = !eqMode[msg.sender];
    }

    function poolsLenght() public view returns(uint){
    uint count = poolsUSD.length;
    return count;
    }

    function getEqMode() public view returns( string memory) {
        string memory em = eqMode[msg.sender] ?  "USDT to BNB" : "BNB to USDT";
        return em;
    }

    function changeOwner(address payable _newOwner) public onlyOwner {
        owner = _newOwner ; 
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function toOwner() public onlyOwner {
        require(address(this).balance >= 1000000000000000 , "LowBalance");
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
}

