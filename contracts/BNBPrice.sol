// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@pancakeswap/v3-core/contracts/interfaces/IPancakeV3Factory.sol";
import "@pancakeswap/v3-core/contracts/interfaces/IPancakeV3Pool.sol";
import "@pancakeswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

contract BNBPrice{
    address public bnb;
    address public usd;
    address payable public owner;
    mapping( address => bool ) public eqMode; //   averageBnbToUsd ? averageUsdToBnb
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



    function getAverage() external payable returns (uint256 , bool) {
        require(msg.value >= 438e11, "BNB Need");
        uint result = _average(eqMode[msg.sender]);
        emit callAverage(msg.sender, msg.value);

        return (result , eqMode[msg.sender]);
    }

    
    function setEqMode() public {
        eqMode[msg.sender] = !eqMode[msg.sender];
    }


    function getEqMode() public view returns (bool){
        return eqMode[msg.sender];
    }

    function poolsLenght() public view returns(uint){
    uint count = poolsUSD.length;
    return count;
    }

    function getEqModeString() public view returns( string memory) {
        string memory em = eqMode[msg.sender] ?  "USDTBNB" : "BNBUSDT";
        return em;
    }

    function changeOwner(address payable _newOwner) public onlyOwner {
        owner = _newOwner ; 
    }
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    function claimTax(address payable _to , uint _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Not enough balance");
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Transfer failed");
    }
    receive() external payable { }
}
