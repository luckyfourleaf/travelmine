// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./DateTime.sol";

contract Hotel is DateTime, ERC1155, Ownable, ERC1155Burnable {
    using Counters for Counters.Counter;

  address public manager;
  //string hotelName;

    constructor() ERC1155("") {
        manager = msg.sender; //sets the manager to the address passed into the constructor
        //hotelName = name;
  }

  RoomType[] roomTypes; //haven't used yet
  Counters.Counter public roomTypeCounter;//creates roomTypeIds
  mapping(uint => RoomType) public idToRoomType;//mapping roomTypeId to RoomType struct
  Counters.Counter public roomNightCounter;//creates RoomNightIds (tokenIds)
  mapping(uint => RoomNight) public idToRoomNight;//mapping tokenId to RoomNight sruct

  uint[] tokenIds;
  uint[] amounts;

   struct RoomType {
      uint roomTypeId;
      string roomName;
      uint8 maxOccupancy;
      string description;//not sure if this needs to be on chain
      bool allInclusive;//haven't used this yet.  Will need this for pricing
      uint cxlPolicy;//in days prior to check-in
      uint commission;//percentage of price
  }

  struct RoomNight {
    uint tokenId;//tokenId for the NFTs
    uint roomTypeId;//can pull room type info from this
    uint date;
    uint price;//currently per room, not per person
}

  function getTokenIds() public view returns (uint[] memory) {
    return tokenIds;
  }

  function getAmounts() public view returns (uint[] memory) {
    return amounts;
  }

  //create a new RoomType struct, add it to the mapping (and array?), increment counter
  function createRoomType(
    string memory _roomName,
    uint8 _maxOccupancy,
    string memory _description,//not sure if this needs to be on chain
    bool _allInclusive,
    uint _cxlPolicy,
    uint _commission
  ) public onlyOwner {
        uint id = roomTypeCounter.current();
        RoomType memory _newRoomType = RoomType({
            roomTypeId: id,
            roomName: _roomName,
            maxOccupancy: _maxOccupancy,
            description: _description,
            allInclusive: _allInclusive,
            cxlPolicy: _cxlPolicy,
            commission: _commission
            });

            roomTypes.push(_newRoomType);
            idToRoomType[id] = _newRoomType;
            roomTypeCounter.increment();
  }

    function getTimestampsAndDays(
      uint8 startDay,
      uint8 startMonth,
      uint16 startYear,
      uint8 endDay,
      uint8 endMonth,
      uint16 endYear
    ) public view onlyOwner returns (uint, uint) {

      uint startTimestamp = toTimestamp(startYear, startMonth, startDay);
      uint endTimestamp = toTimestamp(endYear, endMonth, endDay);
      uint diff = endTimestamp - startTimestamp;
      uint numDays = diff / 1 days;

      return (startTimestamp, numDays);
    }
    //takes a room type, date range, price, and amount of rooms to be minted each night
    //creates a roomNight struct for each date, assigns them a unique token id, and mints/
    function mintRoomNightHelper(
      uint _roomTypeId,
      uint amount,
      uint _price,
      uint startTimestamp,
      uint numDays
    ) public onlyOwner {

      for(uint i=0; i<numDays; i++) {
        uint _tokenId = roomNightCounter.current();

        RoomNight memory _newRoomNight = RoomNight({
          roomTypeId: _roomTypeId,
          date: startTimestamp + i * 1 days,
          price: _price,
          tokenId: _tokenId
        });

        idToRoomNight[_tokenId] = _newRoomNight;
        tokenIds.push(_tokenId);
        amounts.push(amount);

        roomNightCounter.increment();
        }

      }

      function mintRoomNights(
        uint roomTypeId,
        uint amount,
        uint price,
        uint8 startDay,
        uint8 startMonth,
        uint16 startYear,
        uint8 endDay,
        uint8 endMonth,
        uint16 endYear
      ) public onlyOwner {

        (uint start, uint numDays) =
        getTimestampsAndDays(startDay, startMonth, startYear, endDay, endMonth, endYear);

        mintRoomNightHelper(roomTypeId, amount, price, start, numDays);

        _mintBatch(manager, tokenIds, amounts, "");

        delete tokenIds;
        delete amounts;

      }
    }

    //     function mintAndList(
    //     uint _roomTypeId,
    //     uint amount,
    //     uint8 startDay,
    //     uint8 startMonth,
    //     uint16 startYear,
    //     uint8 endDay,
    //     uint8 endMonth,
    //     uint16 endYear,
    //     uint _price
    //   ) public OnlyOwner {
    //       MintRoomNights(
    //         _roomTypeId,
    //         amount,
    //         startDay,
    //         startMonth,
    //         startYear,
    //         endDay,
    //         endMonth,
    //         endYear,
    //         _price);
    //
    //
    //   }
    //
    //   function setURI(string memory newuri) public onlyOwner {
    //       _setURI(newuri);
    //   }
    //
    // }
