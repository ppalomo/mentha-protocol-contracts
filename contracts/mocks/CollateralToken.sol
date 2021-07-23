//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import 'hardhat/console.sol';

contract CollateralToken is ERC20, Ownable {

    /// @notice Contract constructor
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address _to, uint _amount) external onlyOwner {
        _mint(_to, _amount);
    }

}