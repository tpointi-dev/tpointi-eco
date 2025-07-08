// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IBNBPrice.sol";

contract TPTPreSale {
    address payable public priceContract;
    address public  owner;
    bool internal locked;
    uint8 public thisStep;
    mapping(uint8 => uint) public tptPrice;
    uint internal getPriceTax;
    uint internal minRequire;
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
        getPriceTax = 1; // def to 60e12
        minRequire = 10; // def to 5e16

    }

    


    fallback() external payable  {
        require( msg.value >=  minRequire , "Send more BNB to buy TPT");
        require( msg.data.length >= 32 , "Invalid data length");
        if ( abi.decode(msg.data, (bool)) ){
            require( msg.value ==  5e16 , "send just 0.05 bnb");
        }
        (bool sent, ) = priceContract.call{value: getPriceTax}("");
        require(sent, "Transfer failed");
        // (bool success, bytes memory data) = priceContract.staticcall(
        //     abi.encodeWithSignature("viewAverage(address)", msg.sender)
        // );
        // require(success, "Failed to get price");
        buyTPT( 
            abi.decode(msg.data, (bool)) 
            // ,abi.decode(data, (uint256)) 
             );
    }


    receive() external payable { 
        require( msg.value >=  minRequire , "Send more BNB to buy TPT");
        (bool sent, ) = priceContract.call{value: getPriceTax}("");
        require(sent, "Transfer failed");
        // (bool success, bytes memory data) = priceContract.staticcall(
        //     abi.encodeWithSignature("viewAverage(address)", msg.sender)
        // );
        // require(success, "Failed to get price");
        buyTPT( 
            false 
            //  , abi.decode(data, (uint256)) 
             );
    }


    function setPriceMode() public onlyOwner{
        IBNBPrice(priceContract).setEqMode();
    }

    function getPriceMode() public onlyOwner view returns(string memory) {
        
        return IBNBPrice(priceContract).getEqModeString();
    }



    uint public tptptp;
    // 1 5000000000000
    // 2 10000000000000



    // 1515552247497953 usdbnb 16d    value : 151555224749795300
    // offer ? 13196508 : 6598254
    function buyTPT( bool _useOffer ) internal pauseable reentrancy {
        uint usdBnbPrice = IBNBPrice(priceContract).viewAverage();
        

        if (userId[msg.sender] == 0) {
            totalUsers++;
            userId[msg.sender] = totalUsers;

            UserInfo storage userInfo = users[totalUsers];
            userInfo.walletAddress = msg.sender;
            userInfo.tptBalance = 0;
            userInfo.hasOffer = true;


            // Save User
            // users[totalUsers] = userInfo;
            // users[totalUsers].purchaseList.push(Purchase(block.timestamp, msg.value, 0 , thisStep));
        }
        uint tptAmount;
        if(_useOffer){
            tptAmount = (((msg.value*1e18) / usdBnbPrice ) / tptPrice[thisStep]  ) * 2;
        }else{
            tptAmount = ((msg.value*1e18) / usdBnbPrice) / tptPrice[thisStep] ;
        }
        users[totalUsers].tptBalance = tptAmount;
    }

    function setThisStep(uint8 _step) public onlyOwner {
        thisStep = _step;
    }

    function setTPTPrice(uint8 _step , uint _price) public onlyOwner {
        tptPrice[_step] = _price;
    }

    function getThisStepPrice() public view returns (uint256) {
        return tptPrice[thisStep];
    }

    


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



    

    function setBNBPriceAddress(address payable _priceContract) public onlyOwner{
        priceContract = _priceContract ;
    }


    // function getPrice() external payable returns (uint256) {

    //     (bool sent, ) = priceContract.call{value: 60e12}("");
    //     require(sent, "Transfer to price contract failed");

    //     (bool success, bytes memory data) = priceContract.staticcall(
    //         abi.encodeWithSignature("viewAverage(address)", msg.sender)
    //     );
    //     require(success, "Failed to get price");

    //     return abi.decode(data, (uint256));
    // }

    // function getUsdBnbPrice() public payable returns ( uint _lastPrice){
    //     _lastPrice = IBNBPrice(priceContract).viewAverage(); // 1e14 => getPriceTax
    // }

}
