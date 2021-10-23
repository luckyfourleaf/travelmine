// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts@4.3.2/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.3.2/access/Ownable.sol";
import "@openzeppelin/contracts@4.3.2/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts@4.3.2/utils/Counters.sol";

contract Hotel is ERC1155, Ownable, ERC1155Burnable {
    using Counters for Counters.Counter;

  address private manager;
  string hotelName;
  string hotelLocation;
  uint tokenId;
  RoomType[] roomTypes;

    constructor(
      string memory name,
      string memory location
      ) ERC1155("ROOM") {
        manager = msg.sender;
        hotelName = name;
        hotelLocation = location;
  }

   struct RoomType {
      string roomName;
      uint8 maxOccupancy;
      string description;
      bool allInclusive;
  }

  struct RoomNight {
      RoomType roomType;
      uint date;
      uint cxlPolicy;
      uint price;
      uint commission;
      address owner;
      bool sold;
  }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyOwner
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }
}
