// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TPointINet is Context {
    using SafeERC20 for IERC20;
    IERC20 internal usdt;

    struct UserModel {
        uint32 id;
        uint32 totalLeftPoints;
        uint32 totalRightPoints;
        uint24 leftPoints;
        uint24 rightPoints;
        uint8 directsCount;
        bool isNotFirst;
        address upLine;
        address leftDirect;
        address rightDirect;
        uint256 registrationTime;
        uint256 totalClaimed;
        uint256 remainingRewards;
    }

    mapping(uint32 => address) internal idToAddress;
    mapping(address => UserModel) internal userInfo;
    mapping(uint256 => address) internal recentParticipants;
    mapping(uint32 => address[]) internal cycleLottery;
    mapping(uint24 => address) internal eligibleUsers;

    uint8 internal timeCycle;
    uint24 internal eligibleCount;
    uint24 internal rewardTotalPoints;
    uint32 internal totalRegistered;
    uint256 internal rewardStartTime;
    uint256 internal pendingParticipants;
    uint256 internal claimedParticipants;
    uint256 internal rewardUnitPrice;
    uint8[6] internal uplineRewardList = [30, 20, 10, 10, 5, 5];
    uint256 internal maxProfit;
    uint32 internal cycleCount;
    uint256 internal winnerPrize;

    address internal owner;
    address internal operator;
    address internal rewardWriter;
    address internal lotteryWinner;

    bool internal isLocked;
    string internal ipfsHash;

    modifier onlyEOA() {
        address sender = _msgSender();
        uint size;
        assembly {
            size := extcodesize(sender)
        }
        require(size == 0, "Caller is a contract");
        _;
    }

    modifier onlyOperator() {
        require(_msgSender() == operator, "Caller is not the operator");
        _;
    }

    modifier noReentrant() {
        require(!isLocked, "Processing in progress");
        isLocked = true;
        _;
        isLocked = false;
    }

    constructor(
        address _operator,
        address _first,
        address _usdt,
        uint8 _timeCycle,
        uint _maxProfit
    ) {
        owner = 0x39D7202B6195a8Cdb5c381cD7de7De79987161C4;
        operator = _operator;
        // 0x55d398326f99059fF775485246999027B3197955
        totalRegistered = 1;
        usdt = IERC20(_usdt);
        idToAddress[totalRegistered] = _first;
        maxProfit = _maxProfit * 1e18;

        UserModel memory _user = UserModel({
            id: totalRegistered,
            totalLeftPoints: 0,
            totalRightPoints: 0,
            leftPoints: 0,
            rightPoints: 0,
            directsCount: 1,
            isNotFirst: false,
            upLine: address(0),
            leftDirect: address(0),
            rightDirect: address(0),
            registrationTime: block.timestamp,
            totalClaimed: maxProfit,
            remainingRewards: 0
        });

        userInfo[_first] = _user;
        rewardStartTime = block.timestamp;
        totalRegistered++;
        timeCycle = _timeCycle;
        isLocked = false;
    }

    function getUSDTAddress() external view returns (address) {
        return address(usdt);
    }

    function _isUserExists(address user) private view returns (bool) {
        return userInfo[user].id != 0;
    }

    function _handleUniLevelRewards(address _upline) private {
        uint8 uplineIndex = 0;
        address currentUpline = _upline;
        while (currentUpline != address(0) && uplineIndex <= 5) {
            uint256 reward = uplineRewardList[uplineIndex] * 1e17;
            if(currentUpline != idToAddress[1]){
                usdt.safeTransfer(currentUpline, reward);
            }
            userInfo[currentUpline].totalClaimed += reward;
            currentUpline = userInfo[currentUpline].upLine;
            uplineIndex++;
        }
    }

    function _handleRegistration(address _upline) private onlyEOA noReentrant {
        require(
            userInfo[_upline].directsCount != 2,
            "Upline already has 2 directs"
        );
        require(_msgSender() != _upline, "Cannot refer yourself");
        require(!_isUserExists(_msgSender()), "Already registered");
        require(_isUserExists(_upline), "Upline not registered");
        usdt.safeTransferFrom(_msgSender(), address(this), 100 * 10 ** 18);
        _handleUniLevelRewards(_upline);
        idToAddress[totalRegistered] = _msgSender();
        UserModel memory newUser = UserModel({
            id: totalRegistered,
            totalLeftPoints: 0,
            totalRightPoints: 0,
            leftPoints: 0,
            rightPoints: 0,
            directsCount: 0,
            isNotFirst: userInfo[_upline].directsCount == 0 ? false : true,
            upLine: _upline,
            leftDirect: address(0),
            rightDirect: address(0),
            registrationTime: block.timestamp,
            remainingRewards: maxProfit,
            totalClaimed: 0
        });
        userInfo[_msgSender()] = newUser;
        recentParticipants[pendingParticipants] = _msgSender();
        pendingParticipants++;
        if (userInfo[_upline].directsCount == 0) {
            userInfo[_upline].leftPoints++;
            userInfo[_upline].totalLeftPoints++;
            userInfo[_upline].leftDirect = _msgSender();
        } else {
            userInfo[_upline].rightPoints++;
            userInfo[_upline].totalRightPoints++;
            userInfo[_upline].rightDirect = _msgSender();
        }
        userInfo[_upline].directsCount++;
        totalRegistered++;
        cycleLottery[cycleCount].push(_upline);
    }

    function registerUser(address _upline) external onlyEOA {
        _handleRegistration(_upline);
    }

    function getUserInfo(address _user) public view returns (UserModel memory) {
        return userInfo[_user];
    }

    function getUserUpline(address user) public view returns (address) {
        return userInfo[user].upLine;
    }

    function getUserDirects(
        address user
    ) public view returns (address left, address right) {
        return (userInfo[user].leftDirect, userInfo[user].rightDirect);
    }

    function getTotalRegistered() public view returns (uint32) {
        return totalRegistered;
    }

    function _getUserWeakerSidePoints(
        address user
    ) private view returns (uint32) {
        return
            userInfo[user].totalLeftPoints <= userInfo[user].totalRightPoints
                ? userInfo[user].totalLeftPoints
                : userInfo[user].totalRightPoints;
    }

    function _getUserRewardablePoints(
        address user
    ) private view returns (uint24) {
        if (userInfo[user].remainingRewards == 0) {
            return 0;
        } else {
            uint24 minPoints = userInfo[user].leftPoints <=
                userInfo[user].rightPoints
                ? userInfo[user].leftPoints
                : userInfo[user].rightPoints;
            return minPoints < 6 ? minPoints : 6;
        }
    }

    function _isNewEligibleUser(address user) private view returns (bool) {
        if (_getUserRewardablePoints(user) > 0) {
            for (uint24 i = 0; i < eligibleCount; i++) {
                if (eligibleUsers[i] == user) {
                    return false;
                }
            }
            return true;
        }
        return false;
    }

    function _calculateEligibleUsers() private {
        address parent;
        address current;
        for (uint256 i = 0; i < pendingParticipants; i++) {
            current = userInfo[userInfo[recentParticipants[i]].upLine].upLine;
            parent = userInfo[recentParticipants[i]].upLine;
            if (_isNewEligibleUser(parent)) {
                eligibleUsers[eligibleCount] = parent;
                eligibleCount++;
            }

            while (current != address(0)) {
                if (!userInfo[parent].isNotFirst) {
                    userInfo[current].leftPoints++;
                    userInfo[current].totalLeftPoints++;
                } else {
                    userInfo[current].rightPoints++;
                    userInfo[current].totalRightPoints++;
                }

                if (_isNewEligibleUser(current)) {
                    eligibleUsers[eligibleCount] = current;
                    eligibleCount++;
                }

                parent = current;
                current = userInfo[current].upLine;
            }
        }
    }

    function _getTotalQualifiedPoints() private view returns (uint24 total) {
        for (uint24 i = 0; i < eligibleCount; i++) {
            total += _getUserRewardablePoints(eligibleUsers[i]);
        }
    }

    function _calculatePointUnitValue() private view returns (uint256) {
        uint256 totalRewardPool = (((pendingParticipants -
            claimedParticipants) * 90) + (claimedParticipants * 100)) *
            10 ** 18;
        return totalRewardPool / _getTotalQualifiedPoints();
    }

    function getTimeCycle() external view returns (uint256) {
        return timeCycle;
    }

    function _handleLottery() private {
        uint winners = cycleLottery[cycleCount].length;
        winnerPrize = usdt.balanceOf(address(this));

        uint256 rand = uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number - 1),
                    block.timestamp,
                    msg.sender,
                    block.prevrandao,
                    winners
                )
            )
        );
        uint256 winnerIndex = rand % winners;
        lotteryWinner = cycleLottery[cycleCount][winnerIndex];
        usdt.safeTransfer(lotteryWinner, winnerPrize);
        userInfo[lotteryWinner].totalClaimed += winnerPrize;
    }

    function _handleWriterReward(
        address _rewardWriter,
        uint256 amount
    ) private {
        usdt.safeTransfer(_rewardWriter, amount);
    }

    function claimReward() external onlyEOA noReentrant {
        require(
            block.timestamp > rewardStartTime + timeCycle * 1 hours,
            "Reward time not reached"
        );
        require(_isUserExists(_msgSender()), "User not registered");

        _calculateEligibleUsers();

        rewardTotalPoints = _getTotalQualifiedPoints();
        require(rewardTotalPoints > 0, "No qualified points");

        rewardWriter = _msgSender();
        rewardUnitPrice = _calculatePointUnitValue();

        for (uint24 i = 0; i < eligibleCount; i++) {
            address _userAddress = eligibleUsers[i];
            UserModel memory user = userInfo[_userAddress];
            // maxPoints = 6
            uint24 userPoints = _getUserRewardablePoints(_userAddress);
            if (user.leftPoints == userPoints) {
                user.leftPoints = 0;
                user.rightPoints -= userPoints;
            } else if (user.rightPoints == userPoints) {
                user.leftPoints -= userPoints;
                user.rightPoints = 0;
            } else {
                if (user.leftPoints < user.rightPoints) {
                    user.rightPoints -= user.leftPoints;
                    user.leftPoints = 0;
                } else {
                    user.leftPoints -= user.rightPoints;
                    user.rightPoints = 0;
                }
            }

            uint256 rewardAmount = userPoints * rewardUnitPrice;

            uint usdtAmount = rewardAmount > usdt.balanceOf(address(this))
                ? usdt.balanceOf(address(this))
                : rewardAmount;

            usdt.safeTransfer(_userAddress, usdtAmount);

            user.totalClaimed += usdtAmount;
            user.remainingRewards = user.remainingRewards <= usdtAmount
                ? 0
                : user.remainingRewards - usdtAmount;
            userInfo[_userAddress] = user;
        }

        rewardStartTime = block.timestamp;
        pendingParticipants = 0;
        claimedParticipants = 0;

        eligibleCount = 0;

        uint writerRewardAmount = usdt.balanceOf(address(this)) / 2;

        _handleWriterReward(rewardWriter, writerRewardAmount);
        _handleLottery();
        cycleCount++;
    }

    function setTimeCycle(uint8 _timeCycle) external onlyOperator {
        timeCycle = _timeCycle <= 24 ? _timeCycle : 24;
    }

    function getUserLeftRightPoints(
        address user
    ) public view returns (uint32 leftPoints, uint32 rightPoints) {
        return (
            userInfo[user].totalLeftPoints,
            userInfo[user].totalRightPoints
        );
    }

    function getAllRegisteredUsersInRange(
        uint32 start,
        uint32 end
    ) public view returns (address[] memory) {
        uint32 index;
        address[] memory result = new address[]((end - start) + 1);
        for (uint32 i = start; i <= end; i++) {
            result[index] = idToAddress[i];
            index++;
        }
        return result;
    }

    function getContractUSDTBalance() public view returns (uint256) {
        return usdt.balanceOf(address(this)) / 10 ** 18;
    }

    function getLastRewardInfo()
        public
        view
        returns (
            uint256 lastUnitReward,
            address lastRewardWriter,
            uint24 lastTotalPoints
        )
    {
        return (rewardUnitPrice / 10 ** 18, rewardWriter, rewardTotalPoints);
    }

    function getUserWeakerSidePoints(
        address user
    ) public view returns (uint32) {
        return _getUserWeakerSidePoints(user);
    }

    function getUserStrongerSidePoints(
        address user
    ) private view returns (uint32) {
        return
            userInfo[user].totalLeftPoints >= userInfo[user].totalRightPoints
                ? userInfo[user].totalLeftPoints
                : userInfo[user].totalRightPoints;
    }

    function getUserTotalTeam(address user) public view returns (uint32) {
        return userInfo[user].totalLeftPoints + userInfo[user].totalRightPoints;
    }

    function getTodayRegisteredUsers() public view returns (address[] memory) {
        address[] memory ret = new address[](pendingParticipants);
        for (uint256 i = 0; i < pendingParticipants; i++) {
            ret[i] = recentParticipants[i];
        }
        return ret;
    }

    function writeIPFS(string memory hash) external onlyOperator {
        ipfsHash = hash;
    }

    function getIPFS() external view returns (string memory) {
        return ipfsHash;
    }

    function reInvest() external onlyEOA noReentrant {
        require(_isUserExists(_msgSender()), "User not registered");
        require(
            userInfo[_msgSender()].remainingRewards < 5000,
            "Remaining rewards exceed limit"
        );

        usdt.safeTransferFrom(_msgSender(), address(this), 100 * 10 ** 18);
        address upline = userInfo[_msgSender()].upLine;
        _handleUniLevelRewards(upline);

        userInfo[_msgSender()].remainingRewards += maxProfit;
        if (userInfo[upline].remainingRewards > 0) {
            cycleLottery[cycleCount].push(upline);
        }
        recentParticipants[pendingParticipants] = _msgSender();
        pendingParticipants++;
        claimedParticipants++;

        if (!userInfo[_msgSender()].isNotFirst) {
            userInfo[userInfo[_msgSender()].upLine].leftPoints++;
            userInfo[userInfo[_msgSender()].upLine].totalLeftPoints++;
        } else {
            userInfo[userInfo[_msgSender()].upLine].rightPoints++;
            userInfo[userInfo[_msgSender()].upLine].totalRightPoints++;
        }
    }

    function reNounceOwnership() external {
        require(msg.sender == owner, "Only owner can change");
        owner = address(0);
    }

    function getLotteryWinner() external view returns (address, uint256) {
        return (lotteryWinner, winnerPrize);
    }

    function setOperator(address _operator) external {
        require(msg.sender == owner, "Only owner can change");
        require(_operator != address(0), "Invalid address");
        operator = _operator;
    }

    function getOperator() external view returns (address) {
        return operator;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

}
