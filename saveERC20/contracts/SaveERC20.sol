// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.3;

contract SaveERC20 {
    interface IERC20 {
      function transferFrom(address from, address to, uint256 amount) external returns (bool);
      function transfer(address to, uint256 amount) external returns (bool);
  }
}
