// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TPTPreSale {

    address public owner;
    
    uint256 public tptPrice;

    struct Purchase {
        uint256 timestamp;
        uint256 bnbAmount;
        uint256 tptAmount;
    }

    struct UserInfo {
        uint256 id;
        address wallet;
        uint256 tptBalance;
        bool hasOffer;
        bool usedOffer;
    }


    // Purchas List of every user
    mapping(address => Purchase[]) public purchases;


    // Unic Id for users
    mapping(address => uint256) public userId;
    // Unic user for id
    mapping(uint256 => address) public userAddressById;

    

    // Total Users
    uint256 public totalUsers;

    // موجودی امتیاز کاربران
    mapping(address => uint256) public userTPTBalance;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor(uint256 _initialPointPrice) {
        owner = msg.sender;
        tptPrice = _initialPointPrice;
    }

    function setPointPrice(uint256 _newPrice) external onlyOwner {
        tptPrice = _newPrice;
    }


    //  VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVvvvv
    // First Time Purchase with 50% Off
    function buyTPT() public payable {
        require(msg.value > 0, "Send BNB to buy TPT");



        uint256 tptAmount = msg.value * 1e18 / tptPrice;
        // uint256 tptAmount = (msg.value * 1e18 / tptPrice)*2;

        if (userId[msg.sender] == 0) {
            totalUsers++;
            userId[msg.sender] = totalUsers;
            userAddressById[totalUsers] = msg.sender;
        }

        userTPTBalance[msg.sender] += tptAmount;
        purchases[msg.sender].push(Purchase(block.timestamp, msg.value, tptAmount));
    }

















    function withdrawAll(address payable _to) external onlyOwner {
        require(_to != address(0), "Invalid address");
        _to.transfer(address(this).balance);
    }

    function getPurchaseCount(address user) external view returns (uint256) {
        return purchases[user].length;
    }

    function getPurchase(address user, uint index) external view returns (uint256 timestamp, uint256 bnbAmount, uint256 tptAmount) {
        Purchase memory p = purchases[user][index];
        return (p.timestamp, p.bnbAmount, p.tptAmount);
    }

    // آیدی یک کاربر خاص
    function getUserId(address user) external view returns (uint256) {
        return userId[user];
    }

    // آدرس کاربر بر اساس آیدی
    function getUserAddress(uint256 id) external view returns (address) {
        return userAddressById[id];
    }

    // موجودی امتیاز کاربر
    function getUserPoints(address user) external view returns (uint256) {
        return userTPTBalance[user];
    }

    // ✅ اضافه کردن امتیاز دستی به کاربر بر اساس آیدی (فقط مالک)
    function grantPointsById(uint256 id, uint256 points) external onlyOwner {
        address user = userAddressById[id];
        require(user != address(0), "Invalid user ID");
        userTPTBalance[user] += points;
    }




    function buyTPTWithOffer() public {}



    function activeOffer() public {
        

    }

    function purchaseWithOffer() public payable {
        activeOffer();
    }



    receive() external payable {
        buyTPT();
    }
}
