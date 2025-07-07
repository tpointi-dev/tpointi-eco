// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TPTPreSale {
    // Controllers
    address public owner;
    bool internal locked;
    
    // Pricing
    address public immutable bnb;
    address public immutable usd;
    uint8 public thisStep;
    mapping(uint8 => uint) public tptPrice;




    // User Details
    // 
    // 
    // Total Users
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

    // Unic Id for users
    mapping(address => uint256) public userId;
    // Unic user for each id
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
    


    constructor(address _bnb , address _usd ) {
        owner = msg.sender;
        thisStep = 0;


        // Wraped bnb : 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
        bnb = _bnb;
        // Wraped usd : 0x55d398326f99059fF775485246999027B3197955
        usd = _usd;
    }


    // Purchase tpt
    function buyTPT( bool _useOffer ) internal pauseable reentrancy {
        uint256 tptAmount = _useOffer ? msg.value * 1e18 / tptPrice[thisStep] : (msg.value * 1e18 / tptPrice[thisStep]) * 2 ;

        if (userId[msg.sender] == 0) {


            
            totalUsers++;
            userId[msg.sender] = totalUsers;



            UserInfo storage userInfo = users[totalUsers];
            userInfo.walletAddress = msg.sender;
            userInfo.tptBalance = 0;
            userInfo.hasOffer = true;
            // Save User
            users[totalUsers] = userInfo;



            // users[totalUsers].purchaseList.push(Purchase(block.timestamp, msg.value, 0 , thisStep));
        }
        





        users[totalUsers].tptBalance = tptAmount;
    }


    function withdrawAll(address payable _to) external onlyOwner {
        require(_to != address(0), "Invalid address");
        _to.transfer(address(this).balance);
    }

    function getPurchaseCount(address _userAddress) external view returns (uint256) {
        return users[userId[_userAddress]].purchaseList.length;
    }

    function getPurchase(address _userAddress, uint index) external view returns (uint256 timestamp, uint256 bnbAmount, uint256 tptAmount) {
        Purchase memory p = users[userId[_userAddress]].purchaseList[index];
        return (p.timestamp, p.bnbAmount, p.tptAmount);
    }

    // آیدی یک کاربر خاص
    function getUserId(address user) external view returns (uint256) {
        return userId[user];
    }

    // آدرس کاربر بر اساس آیدی
    function getUserAddress(uint256 id) external view returns (address) {
        return users[id].walletAddress;
    }



    function getUserTPTBalance(address _userAddress) external view returns (uint256) {
        return users[userId[_userAddress]].tptBalance;
    }



    function grantPointsById(address _userAddress, uint256 _value) external onlyOwner {
        
        require(userId[_userAddress] != 0, "Invalid user ID");
        users[userId[_userAddress]].tptBalance += _value; 
    }




    function buyTPTWithOffer() public {}



    function activeOffer() public {


    }



    fallback() external payable  {
        require( msg.value > 0, "Send BNB to buy TPT");
        require( msg.data.length >= 32 , "Invalid data length");
        buyTPT( abi.decode(msg.data, (bool)) );


        // emit OfferReceived(msg.sender, offer);
    }

    receive() external payable { 
        require( msg.value > 0, "Send BNB to buy TPT");
        buyTPT( false );
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
}
