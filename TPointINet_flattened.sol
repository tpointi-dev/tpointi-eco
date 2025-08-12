// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC20.sol)

pragma solidity >=0.4.16;


// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts (last updated v5.4.0) (utils/introspection/IERC165.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC165.sol


// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC165.sol)

pragma solidity >=0.4.16;


// File: @openzeppelin/contracts/interfaces/IERC1363.sol


// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC1363.sol)

pragma solidity >=0.6.2;



/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v5.3.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Variant of {safeTransfer} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransfer(IERC20 token, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Variant of {safeTransferFrom} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}

// File: TPointINet.sol


pragma solidity ^0.8.28;




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
