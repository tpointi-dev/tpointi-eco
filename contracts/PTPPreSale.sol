// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IBNBPrice.sol";

contract TPTPreSale {
    address payable public priceContract;

    // Controllers
    address public owner;
    bool internal locked;
    
    // Pricing
    uint8 public thisStep;
    mapping(uint8 => uint) public tptPrice;

    // User Details
    uint256 public totalUsers;

    struct Purchase {
        uint256 timestamp;
        uint256 bnbAmount;
        uint256 tptAmount;
        uint8 step;
    }

    struct UserInfo {
        address walletAddress;
        uint256 tptBalance;
        bool hasOffer;
        Purchase[] purchaseList;
    }

    mapping(address => uint256) public userId;
    mapping(uint256 => UserInfo) public users;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier pauseable(){
        require(thisStep != 0, "Contract Paused");
        _;
    }

    modifier reentrancy{
        require(locked != true,"No Reentrancy,pls wait");
        locked = true;
        _;
        locked = false;
    }

    constructor( address payable _priceContract ) {
        owner = msg.sender;
        thisStep = 0;
        priceContract = _priceContract;
    }


    fallback() external payable  {
        buyTPT( abi.decode(msg.data, (bool)) );
    }

    
    receive() external payable { 
        buyTPT( false );
    }

    function getPrice() external payable returns (uint256) {
        require(msg.value >= 1e14, "Insufficient BNB");

        // پرداخت BNB به کانترکت A
        (bool sent, ) = priceContract.call{value: msg.value}("");
        require(sent, "Transfer to price contract failed");

        // خواندن قیمت از کانترکت A
        (bool success, bytes memory data) = priceContract.staticcall(
            abi.encodeWithSignature("viewAverage(address)", msg.sender)
        );
        require(success, "Failed to get price");

        return abi.decode(data, (uint256));
    }

    // 100000000000000
    // function getUsdBnbPrice() public payable returns ( uint usdBnb, bool mode){
    //     (usdBnb, mode) = iBNBPrice.getAverage{value : 1e14}(); // 1e14 => getPriceTax
        
    // }


    // function calcAmount(bool _useOffer) public payable returns(uint){
    //     (uint usdBnb ,) = getPrice();
    //     uint tptAmount = _useOffer 
    //         ? ((msg.value / usdBnb ) / tptPrice[thisStep]  ) * 2
    //         : (msg.value / usdBnb) / tptPrice[thisStep] 
    //         ;
    //     return tptAmount;
    // }




    // Purchase tpt
    // function buyTPT( bool _useOffer ) internal pauseable reentrancy {
    //     require( msg.value >= 5*1e16 , "Send more BNB to buy TPT");
    //     require( msg.data.length >= 32 , "Invalid data length");

    //     uint tptAmount = calcAmount( _useOffer );

        

    //     if (userId[msg.sender] == 0) {
    //         totalUsers++;
    //         userId[msg.sender] = totalUsers;

    //         UserInfo storage userInfo = users[totalUsers];
    //         userInfo.walletAddress = msg.sender;
    //         userInfo.tptBalance = 0;
    //         userInfo.hasOffer = true;
    //         // Save User
    //         users[totalUsers] = userInfo;
    //         // users[totalUsers].purchaseList.push(Purchase(block.timestamp, msg.value, 0 , thisStep));
    //     }
        

    //     users[totalUsers].tptBalance = tptAmount;
    // }


    // function withdrawAll(address payable _to) external onlyOwner {
    //     require(_to != address(0), "Invalid address");
    //     _to.transfer(address(this).balance);
    // }

    // function getPurchaseCount(address _userAddress) external view returns (uint256) {
    //     return users[userId[_userAddress]].purchaseList.length;
    // }

    // function getPurchase(address _userAddress, uint index) external view returns (uint256 timestamp, uint256 bnbAmount, uint256 tptAmount) {
    //     Purchase memory p = users[userId[_userAddress]].purchaseList[index];
    //     return (p.timestamp, p.bnbAmount, p.tptAmount);
    // }

    // function getUserId(address user) external view returns (uint256) {
    //     return userId[user];
    // }

    // function getUserAddress(uint256 id) external view returns (address) {
    //     return users[id].walletAddress;
    // }



    // function getUserTPTBalance(address _userAddress) external view returns (uint256) {
    //     return users[userId[_userAddress]].tptBalance;
    // }



    // function grantPointsById(address _userAddress, uint256 _value) external onlyOwner {
        
    //     require(userId[_userAddress] != 0, "Invalid user ID");
    //     users[userId[_userAddress]].tptBalance += _value; 
    // }



    // function setThisStep(uint8 _step) public onlyOwner {
    //     thisStep = _step;
    // }

    // function setTPTPrice(uint8 _step , uint _price) public onlyOwner {
    //     tptPrice[_step] = _price;
    // }

    // function getThisStepPrice() public view returns (uint256) {
    //     return tptPrice[thisStep];
    // }

    // function setIBNBPrice(address _bnbprice) public onlyOwner{
    //     iBNBPrice = IBNBPrice(_bnbprice);
    // }

    // function setIBNBPriceMode() public onlyOwner{
    //     iBNBPrice.setEqMode();
    // }


}
