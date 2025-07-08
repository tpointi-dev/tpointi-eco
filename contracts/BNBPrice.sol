// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@pancakeswap/v3-core/contracts/interfaces/IPancakeV3Factory.sol";
import "@pancakeswap/v3-core/contracts/interfaces/IPancakeV3Pool.sol";
import "@pancakeswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

contract BNBPrice{
    uint public lastPriceStatic;
    address public bnb;
    address public usd;
    address payable public owner;
    address[] public poolsUSD;
    mapping( address => bool ) public eqMode; //   averageBnbToUsd ? averageUsdToBnb
    mapping(address => uint256) public lastPrice;
    uint internal tax; // default 60e12
    uint public countReceive;
    event callAverage(address caller , uint tickPrice);


    constructor(){
        owner = payable(msg.sender);
        bnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        usd = 0x55d398326f99059fF775485246999027B3197955;
        tax = 1;  // default 60e12
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    // 0x0BFbCF9fa4f9C56B0F40a671Ad40E0805A091865 100 500 10000
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
            ) ;
    }


    function bnbToUsd(uint8 index) external view  returns (uint price){
        (,int24 tick,,,,,) = IPancakeV3Pool(poolsUSD[index]).slot0();
        price = OracleLibrary.getQuoteAtTick(
            tick, 1e18, bnb, usd
            );
    }
    
    
    function _average(bool _mode) internal view returns (uint256 average) {
        uint256 prices;
        uint8 validCount;

        for (uint8 i = 0; i < poolsUSD.length; i++) {
            (, int24 tick,,,,,) = IPancakeV3Pool(poolsUSD[i]).slot0();
            uint256 price = OracleLibrary.getQuoteAtTick(
                tick,
                1e18,
                _mode ? usd : bnb,
                _mode ? bnb : usd
            );

            if (price > 0) {
                prices += price;
                validCount++;
            }
        }

        require(validCount > 0, "No price found");
        average = prices / validCount;
    }

    function setBnbAddress(address _bnb) public onlyOwner{
        bnb = _bnb;
    }

    function setUsdAddress(address _usd) public onlyOwner{
        usd = _usd;
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


    function claimTax() external onlyOwner {
        require(address(this).balance >= 0, "Not enough balance");
        owner.transfer(address(this).balance);
    }


    receive() external payable {
        require(msg.value >= tax , "Value Low");
        uint256 price = _average(eqMode[msg.sender]);
        lastPrice[msg.sender] = price;
        lastPriceStatic = price;
        countReceive++;
    }

    function viewAverage() external view returns (uint256) {
        require(lastPrice[msg.sender] > 0, "No stored price");
        return lastPrice[msg.sender];
    }

    function viewAverageStatic() external view returns(uint){
        require(lastPriceStatic > 0, "No stored price");
        return lastPriceStatic;
    }

    function setTax(uint _tax) public onlyOwner {
        tax = _tax;
    }
}
