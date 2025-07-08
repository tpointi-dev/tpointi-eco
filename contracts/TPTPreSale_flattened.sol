// SPDX-License-Identifier: MIT

// File: contracts/IBNBPrice.sol


pragma solidity ^0.8.20;

interface IBNBPrice {
     
    function setEqMode() external; 
    function getEqMode() external view returns( bool);
    function getEqModeString() external view returns( string memory);
    function viewAverage() external view returns (uint256);
    function viewAverageStatic() external view returns (uint256);
    function bnbToUsd(uint8 index) external view  returns (uint);
    function usdToBnb(uint8 index) external view  returns (uint);
}
// File: contracts/TPTPreSale.sol


pragma solidity ^0.8.20;


contract TPTPreSale {
    address payable internal priceContract;
    address payable public owner;
    bool internal locked;
    uint8 public thisStep;
    mapping(uint8 => uint256) public tptStepPrice;
    uint256 internal getPriceTax;
    uint256 internal minRequire;
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

    mapping(address => uint256) internal userId;
    mapping(uint256 => UserInfo) internal users;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier pauseable() {
        require(thisStep != 0, "Contract Paused");
        _;
    }

    modifier reentrancy() {
        require(locked != true, "No Reentrancy,pls wait");
        locked = true;
        _;
        locked = false;
    }

    constructor(address payable _priceContract) {
        owner = payable (msg.sender);
        thisStep = 1;
        priceContract = _priceContract;
        getPriceTax = 65e12;
        minRequire = 1e16; // def to 5e16
        totalUsers = 0;
    }

    fallback() external payable {
        require(msg.value >= minRequire, "Send more BNB to buy TPT");
        require(msg.data.length >= 32, "Invalid data length");
        if (abi.decode(msg.data, (bool))) {
            require(msg.value == 5e16, "send just 0.05 bnb");
        }
        (bool sent, ) = priceContract.call{value: getPriceTax}("");
        require(sent, "Transfer failed");
        buyTPT(abi.decode(msg.data, (bool)));
    }

    receive() external payable {
        require(msg.value >= minRequire, "Send more BNB to buy TPT");
        (bool sent, ) = priceContract.call{value: getPriceTax}("");
        require(sent, "Transfer failed");

        buyTPT(false);
    }

    function setPriceMode() public onlyOwner {
        IBNBPrice(priceContract).setEqMode();
    }

    function getPriceMode() public view onlyOwner returns (string memory) {
        return IBNBPrice(priceContract).getEqModeString();
    }

    // 1 5000000000000
    // 2 10000000000000
    // 3 10600000000000
    // 4 11236000000000
    // 5 14045000000000
    // 6 18960000000000
    // 7 28441000000000
    // 8 45506000000000
    // 9 77360000000000
    //10 100000000000000
    // 1515552247497953 usdbnb 16d    value : 151169269202239400  => 100$
    // offer ? 13196508 : 6598254
    function buyTPT(bool _useOffer) internal pauseable reentrancy {
        if (userId[msg.sender] == 0) {
            totalUsers++;
            userId[msg.sender] = totalUsers;

            UserInfo storage userInfo = users[userId[msg.sender]];
            userInfo.walletAddress = msg.sender;
            userInfo.tptBalance = 0;
            userInfo.hasOffer = true;

            // Save User
            users[userId[msg.sender]] = userInfo;
        }
        uint256 usdBnbPrice = IBNBPrice(priceContract).viewAverage();
        uint256 amount;
        if (_useOffer) {
            require(users[userId[msg.sender]].hasOffer, "no offer more");
            amount =
                (((msg.value * 1e18) / usdBnbPrice) / tptStepPrice[thisStep]) *
                2;
            users[userId[msg.sender]].hasOffer = false;
        } else {
            amount = ((msg.value * 1e18) / usdBnbPrice) / tptStepPrice[thisStep];
        }
        users[userId[msg.sender]].tptBalance += amount;
        users[userId[msg.sender]].purchaseList.push(
            Purchase(block.timestamp, msg.value, amount, thisStep)
        );
    }

    function setThisStep(uint8 _step) public onlyOwner {
        thisStep = _step;
    }

    function setTPTPrice(uint8 _step, uint256 _price) public onlyOwner {
        tptStepPrice[_step] = _price;
    }

    function getThisStepPrice() public view returns (uint256) {
        return tptStepPrice[thisStep];
    }

    function withdrawAll(address payable _to) external onlyOwner {
        require(_to != address(0), "Invalid address");
        _to.transfer(address(this).balance);
    }

    function getPurchaseCount(address _userAddress)
        external
        view
        returns (uint256)
    {
        return users[userId[_userAddress]].purchaseList.length;
    }

    function getPurchase(address _userAddress, uint256 index)
        external
        view
        returns (Purchase memory)
    {
        
        return users[userId[_userAddress]].purchaseList[index];
    }

    function getUserId(address user) external view returns (uint256) {
        return userId[user];
    }

    function getUserById(uint256 id) external view returns (UserInfo memory) {
        return users[id];
    }

    function getUserTPTBalance(address _userAddress)
        external
        view
        returns (uint256)
    {
        return users[userId[_userAddress]].tptBalance;
    }


    function setBNBPriceAddress(address payable _priceContract)
        public
        onlyOwner
    {
        priceContract = _priceContract;
    }

    function chaneOwner(address payable  _owner) public onlyOwner{
        owner = _owner ;
    }


    function setMinRequire(uint _min) public onlyOwner{
        require(_min >= getPriceTax , "min should be more than tax");
        minRequire = _min;
    }
}
