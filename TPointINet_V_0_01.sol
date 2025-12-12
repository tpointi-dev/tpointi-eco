// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TPointINet_V_0_01 is Context {
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
    uint256 internal equalZero;
    uint32 internal cycleCount;
    uint256 internal winnerPrize;
    uint256 internal writerRewardAmount;

    address internal owner;
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

    modifier onlyOwner() {
        require(_msgSender() == owner, "Caller is not the owner");
        _;
    }

    modifier noReentrant() {
        require(!isLocked, "Processing in progress");
        isLocked = true;
        _;
        isLocked = false;
    }

    constructor(
        address _owner,
        address _first,
        address _usdt,
        uint8 _timeCycle,
        uint _maxProfit    ) {
        // owner = 0x39D7202B6195a8Cdb5c381cD7de7De79987161C4;
        owner = _owner;
        // usdt = 0x55d398326f99059fF775485246999027B3197955;
        usdt = IERC20(_usdt);

        totalRegistered = 1;
        idToAddress[totalRegistered] = _first;
        maxProfit = _maxProfit * 1e18 * 2;
        equalZero = _maxProfit * 1e18;

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
            totalClaimed: 0,
            remainingRewards: 0
        });

        userInfo[_first] = _user;
        rewardStartTime = block.timestamp;
        totalRegistered++;
        timeCycle = _timeCycle;
        isLocked = false;
    }
    /// @notice Go to this contract(usdt) address and approve TPointiNet(this contract address) for registration.
    /// @return UsdTether contract address.
    function approveUsdTether() external view returns (address) {
        return address(usdt);
    }


    /// @notice Check if a user exists in the system.
    /// @dev This function checks if a user is registered by verifying their ID.
    /// @param user The address of the user to check.
    /// @return True if the user is registered, false otherwise.
    function _isUserExists(address user) private view returns (bool) {
        return userInfo[user].id != 0;
    }

    /// @dev This function handles the distribution of uni-level rewards to upline.
    function _handleUniLevelRewards(address _upline) private {
        uint8 uplineIndex = 0;
        address currentUpline = _upline;
        while (currentUpline != address(0) && uplineIndex <= 5) {
            uint256 reward = uplineRewardList[uplineIndex] * 1e17;
            if (currentUpline != idToAddress[1]) {
                usdt.safeTransfer(currentUpline, reward);
            }
            userInfo[currentUpline].totalClaimed += reward;
            currentUpline = userInfo[currentUpline].upLine;
            uplineIndex++;
        }
    }

    /// @dev This function handles the registration of a new user.
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
        if(_upline != idToAddress[1]) {
            cycleLottery[cycleCount].push(_upline);
        }
    }

    /// @notice Activate a user by registering them with a specified upline.
    /// @param _upline The address of the upline to register the user under.
    /// @dev This function allows a user to register under an existing upline.
    /// @notice This function can only be called by externally owned accounts (EOAs).
    function activateUser(address _upline) external onlyEOA {
        _handleRegistration(_upline);
    }

    /// @notice Get information about a user.
    /// @param _user The address of the user to retrieve information for.
    /// @return userModel A UserModel struct containing the user's information.
    function getUserInfo(
        address _user
    ) public view returns (UserModel memory userModel) {
        userModel = userInfo[_user];
        // userModel.totalClaimed = userModel.totalClaimed / 1e18;
        // userModel.remainingRewards = (userModel.remainingRewards - equalZero) / 1e18;
        return userModel;
    }

    /// @notice Get the upline of a user.
    /// @param user The address of the user to retrieve the upline for.
    /// @return The address of the user's upline.
    function getUserUpline(address user) public view returns (address) {
        return userInfo[user].upLine;
    }

    /// @notice Get the direct children of a user.
    /// @param user The address of the user to retrieve the directs for.
    /// @return left The address of the user's left direct.
    /// @return right The address of the user's right direct.
    function getUserDirects(
        address user
    ) public view returns (address left, address right) {
        return (userInfo[user].leftDirect, userInfo[user].rightDirect);
    }

    /// @notice Get the total number of registered users.
    /// @return The total number of registered users.
    function getTotalRegistered() public view returns (uint32) {
        return totalRegistered;
    }

    /// @notice Get the weaker side points of a user.
    /// @param user The address of the user to retrieve the weaker side points for.
    /// @return The weaker side points of the user.
    function _getUserWeakerSidePoints(
        address user
    ) private view returns (uint32) {
        return
            userInfo[user].totalLeftPoints <= userInfo[user].totalRightPoints
                ? userInfo[user].totalLeftPoints
                : userInfo[user].totalRightPoints;
    }

    /// @notice Get the rewardable points of a user.
    /// @param user The address of the user to retrieve the rewardable points for.
    /// @return The rewardable points of the user (0-6).
    function _getUserRewardablePoints(
        address user
    ) private view returns (uint24) {
        if (userInfo[user].remainingRewards <= equalZero) {
            return 0;
        } else {
            uint24 minPoints = userInfo[user].leftPoints <=
                userInfo[user].rightPoints
                ? userInfo[user].leftPoints
                : userInfo[user].rightPoints;
            return minPoints < 6 ? minPoints : 6;
        }
    }

    /// @notice Check if a user is eligible for rewards.
    /// @param user The address of the user to check eligibility for.
    /// @return True if the user is eligible, false otherwise.
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

    /// @notice Calculate the eligible users for rewards.
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


    /// @notice Get the total qualified points of all eligible users.
    /// @return total The total qualified points of all eligible users.
    function _getTotalQualifiedPoints() private view returns (uint24 total) {
        for (uint24 i = 0; i < eligibleCount; i++) {
            total += _getUserRewardablePoints(eligibleUsers[i]);
        }
    }

    /// @notice Calculate the point unit value for rewards.
    /// @return The calculated point unit value.
    function _calculatePointUnitValue() private view returns (uint256) {
        uint256 totalRewardPool = (((pendingParticipants -
            claimedParticipants) * 90) + (claimedParticipants * 100)) *
            10 ** 18;
        return totalRewardPool / _getTotalQualifiedPoints();
    }

    /// @notice Get the time cycle duration.
    /// @return The time cycle duration in seconds.
    function getTimeCycle() external view returns (uint256) {
        return timeCycle;
    }

    /// @notice Handle the lottery process.
    function _handleLottery() private {
        uint winners = cycleLottery[cycleCount].length;
        winnerPrize = usdt.balanceOf(address(this));

        uint256 rand;
        while (rand == 0) {
            rand = uint256(
                keccak256(
                    abi.encodePacked(block.prevrandao, block.timestamp, winners)
                )
            );
        }
        uint256 winnerIndex = rand % winners;
        lotteryWinner = cycleLottery[cycleCount][winnerIndex];
        usdt.safeTransfer(lotteryWinner, winnerPrize);
        userInfo[lotteryWinner].totalClaimed += winnerPrize;
    }

    /// @notice Handle the writer reward distribution.
    /// @param _rewardWriter The address of the reward writer.
    /// @param amount The amount of writing reward.
    function _handleWriterReward(
        address _rewardWriter,
        uint256 amount
    ) private {
        usdt.safeTransfer(_rewardWriter, amount);
        userInfo[_rewardWriter].totalClaimed += amount;
    }

    /// @notice Claim rewards, Close cycle and Distribute rewards.
    /// @dev This function can only be called by externally owned accounts (EOA).
    function claimReward() external onlyEOA noReentrant {
        require(
            block.timestamp > rewardStartTime + timeCycle * 1 hours,
            "Reward time not reached"
        );
        require(_isUserExists(_msgSender()), "User not registered");

        _calculateEligibleUsers();

        rewardTotalPoints = _getTotalQualifiedPoints();
        require(rewardTotalPoints > 0, "No qualified points");

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
            user.remainingRewards = (user.remainingRewards - usdtAmount);
            userInfo[_userAddress] = user;
        }

        rewardStartTime = block.timestamp;
        pendingParticipants = 0;
        claimedParticipants = 0;

        eligibleCount = 0;

        writerRewardAmount = usdt.balanceOf(address(this)) / 2;
        rewardWriter = _msgSender();

        _handleWriterReward(rewardWriter, writerRewardAmount);
        _handleLottery();
        cycleCount++;
    }

    /// @notice Get the left and right points of a user.
    /// @param user The address of the user to retrieve the points for.
    /// @return leftPoints The left points of the user.
    /// @return rightPoints The right points of the user.
    function getUserLeftRightPoints(
        address user
    ) public view returns (uint32 leftPoints, uint32 rightPoints) {
        return (
            userInfo[user].totalLeftPoints,
            userInfo[user].totalRightPoints
        );
    }

    /// @notice Get all registered users within a specific range.
    /// @param start The starting index of the range.
    /// @param end The ending index of the range.
    /// @return An array of addresses representing the registered users in the specified range.
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

    /// @notice Get the USDT balance of the contract.
    /// @return The USDT balance of the contract.
    function getContractUSDTBalance() public view returns (uint256) {
        return usdt.balanceOf(address(this)) / 10 ** 18;
    }

    /// @notice Get the last cycle information.
    /// @return lastUnitReward The last unit reward.
    /// @return lastRewardWriter The address of the last reward writer.
    /// @return lastWriterReward The last writer reward.
    /// @return lastTotalPoints The last total points.
    /// @return totalRewards The total rewards.
    /// @return lotteryUser The address of the lottery user.
    /// @return lotteryWinnerReward The lottery winner reward.
    function getLastCycleInfo()
        public
        view
        returns (
            uint256 lastUnitReward,
            address lastRewardWriter,
            uint256 lastWriterReward,
            uint24 lastTotalPoints,
            uint256 totalRewards,
            address lotteryUser,
            uint256 lotteryWinnerReward
        )
    {
        totalRewards = rewardTotalPoints * rewardUnitPrice;
        return (
            rewardUnitPrice / 10 ** 18,
            rewardWriter,
            writerRewardAmount / 10 ** 18,
            rewardTotalPoints,
            totalRewards / 10 ** 18,
            lotteryWinner,
            winnerPrize / 10 ** 18
        );
    }

    /// @notice Get the weaker side points of a user.
    /// @param user The address of the user to retrieve the points for.
    /// @return The weaker side points of the user.
    function getUserWeakerSidePoints(
        address user
    ) public view returns (uint32) {
        return _getUserWeakerSidePoints(user);
    }

    /// @notice Get the stronger side points of a user.
    /// @param user The address of the user to retrieve the points for.
    /// @return The stronger side points of the user.
    function getUserStrongerSidePoints(
        address user
    ) private view returns (uint32) {
        return
            userInfo[user].totalLeftPoints >= userInfo[user].totalRightPoints
                ? userInfo[user].totalLeftPoints
                : userInfo[user].totalRightPoints;
    }

    /// @notice Get the total team points of a user.
    /// @param user The address of the user to retrieve the points for.
    /// @return The total team points of the user.
    function getUserTotalTeam(address user) public view returns (uint32) {
        return userInfo[user].totalLeftPoints + userInfo[user].totalRightPoints;
    }

    /// @notice Get total registered users in this cycle.
    /// @return Total registered users in this cycle.
    function getCycleRegisteredUsers() public view returns (address[] memory) {
        address[] memory ret = new address[](pendingParticipants);
        for (uint256 i = 0; i < pendingParticipants; i++) {
            ret[i] = recentParticipants[i];
        }
        return ret;
    }

    /// @notice Reinvest and recharge max profit.
    function reInvest() external onlyEOA noReentrant {
        require(_isUserExists(_msgSender()), "User not registered");
        require(
            userInfo[_msgSender()].remainingRewards < maxProfit,
            "Remaining rewards exceed limit"
        );

        usdt.safeTransferFrom(_msgSender(), address(this), 100 * 10 ** 18);
        address upline = userInfo[_msgSender()].upLine;
        _handleUniLevelRewards(upline);

        userInfo[_msgSender()].remainingRewards += equalZero;
        if (userInfo[upline].remainingRewards > equalZero) {
            cycleLottery[cycleCount].push(upline);
        }
        recentParticipants[pendingParticipants] = _msgSender();
        pendingParticipants++;
        claimedParticipants++;

        if (!userInfo[_msgSender()].isNotFirst) {
            userInfo[userInfo[_msgSender()].upLine].leftPoints++;
            // userInfo[userInfo[_msgSender()].upLine].totalLeftPoints++;
        } else {
            userInfo[userInfo[_msgSender()].upLine].rightPoints++;
            // userInfo[userInfo[_msgSender()].upLine].totalRightPoints++;
        }
    }

    /// @notice Renounce ownership of the contract.
    /// @param _newOwner The address of the new owner.
    function reNounceOwnership(address _newOwner) external onlyOwner() {
        owner = _newOwner;
    }

    /// @notice Get the owner of the contract.
    /// @return The address of the contract owner.
    function getOwner() external view returns (address) {
        return owner;
    }

    /// @notice Convert a uint256 value to a string.
    /// @param _value The uint256 value to convert.
    /// @return The string representation of the uint256 value.
    function _uintToString(
        uint256 _value
    ) internal pure returns (string memory) {
        if (_value == 0) return "0";
        uint256 temp = _value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (_value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(_value % 10)));
            _value /= 10;
        }
        return string(buffer);
    }

    /// @notice Get the remaining time for the current cycle.
    /// @return remainingTime The time remaining until the cycle ends.
    /// @return endTime The end time of the cycle.
    function getRemainingCycleTime()
        external
        view
        returns (string memory remainingTime, string memory endTime)
    {
        uint256 cycleEndTime = rewardStartTime + (timeCycle * 1 hours);
        uint256 endHour = (cycleEndTime / 3600) % 24;
        uint256 endMinute = (cycleEndTime / 60) % 60;
        uint256 endSecond = cycleEndTime % 60;

        if (block.timestamp >= cycleEndTime) {
            return (
                string(
                    "Cycle ended, Ready to claim rewards"
                ),
                string(
                    abi.encodePacked(
                        _uintToString(endHour),
                            " : ",
                            _uintToString(endMinute),
                            " : ",
                            _uintToString(endSecond),
                            " UTC"
                        )
                    )
                
            );
        }
        uint256 remainingMinutes = (cycleEndTime - block.timestamp) / 60;
        uint256 remainingSeconds = (cycleEndTime - block.timestamp) % 60;

        return (
            string(
                abi.encodePacked(
                    "Waiting for ",
                    _uintToString(remainingMinutes),
                    " minutes and ",
                    _uintToString(remainingSeconds),
                    " seconds"
                )
            ),
            string(abi.encodePacked(_uintToString(endHour), " : ", _uintToString(endMinute)," : ", _uintToString(endSecond), " UTC"))
        );
    }



    /// @notice Get the remaining rewards for a user.
    /// @param _user The address of the user.
    /// @return The remaining rewards for the user.
    function getRemainingRewards(address _user) external view returns (uint256) {

        return userInfo[_user].remainingRewards <= equalZero
            ? 0
            : (userInfo[_user].remainingRewards - equalZero) / 1e18;
    }
}
