// SPDX-License-Identifier: MIT LICENSE

pragma solidity 0.8.15;
import "@klaytn/contracts/access/Ownable.sol";
import "@klaytn/contracts/KIP/token/KIP7/KIP7.sol";
import "@klaytn/contracts/KIP/token/KIP7/extensions/KIP7Burnable.sol";


contract N2DRewards is KIP7Burnable, Ownable {

  mapping(address => bool) controllers;
  
  constructor() KIP7("N2DRewards", "N2DR") { }

  function mint(address to, uint256 amount) external {
    require(controllers[msg.sender], "Only controllers can mint");
    _mint(to, amount);
  }

  function burnFrom(address account, uint256 amount) public override {
      if (controllers[msg.sender]) {
          _burn(account, amount);
      }
      else {
          super.burnFrom(account, amount);
      }
  }

  function addController(address controller) external onlyOwner {
    controllers[controller] = true;
  }

  function removeController(address controller) external onlyOwner {
    controllers[controller] = false;
  }
}