// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

// The shibaylock leverages using openzeppelin timelock for maximum safety.
// To see openzepplin's audits goto: https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/audit
contract ShibaTimelock {
    using SafeERC20 for IERC20;

    IERC20 public gbone;
    IERC20 public gboneLP;

    TokenTimelock[] public Locks;

    constructor (IERC20 _gbone, IERC20 _gboneLP) {

        gbone = _gbone;
        gboneLP = _gboneLP;
        uint currentTime = block.timestamp;

        createLock(_gbone, msg.sender, currentTime + 60 days);
        createLock(_gbone, msg.sender, currentTime + 120 days);
        createLock(_gbone, msg.sender, currentTime + 180 days);
        createLock(_gbone, msg.sender, currentTime + 240 days);
        createLock(_gboneLP, msg.sender, currentTime + 365 days);
    }

    function createLock(IERC20 token, address sender, uint256 time) internal {
        TokenTimelock lock = new TokenTimelock(token, sender, time);
        Locks.push(lock);
    }

    // Attempts to release tokens. This is done safely with 
    // OpenZeppelin which checks the proper time has passed.
    // To see their code go to: 
    // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/TokenTimelock.sol
    function release(uint lock) external {
        Locks[lock].release();
    }

    function getLockAddress(uint lock) external view returns (address) {
        require(lock <= 4, "getLockAddress: lock doesnt exist");

        return address(Locks[lock]);
    }
    
    //Forward along tokens to their appropriate vesting place
    function forwardTokens() external {

        uint gbones = gbone.balanceOf(address(this));
        uint gboneLPs = gboneLP.balanceOf(address(this));

        require(gbones > 0, "forwardTokens: no gbones!");
        require(gboneLPs > 0, "forwardTokens: no shiba lps!");

        for (uint256 index = 0; index <= 3; index++) {
            gbone.transfer(address(Locks[index]), gbones / 4);
        }

        // just incase theres any gbones left from rounding
        uint leftover = gbone.balanceOf(address(this));

        if (leftover > 0) {
            gbone.transfer(address(Locks[3]), leftover);
        }

        gboneLP.safeTransfer(address(Locks[4]), gboneLPs);
    }


}
