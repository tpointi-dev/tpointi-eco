// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StructFallback {
    struct Person {
        string name;
        uint256 age;
        bool isVerified;
    }

    event PersonReceived(string name, uint256 age, bool isVerified);

    fallback() external payable {
        // decode struct از msg.data
        Person memory p = abi.decode(msg.data, (Person));

        emit PersonReceived(p.name, p.age, p.isVerified);
    }

    receive() external payable {}
}
