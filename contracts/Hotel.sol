// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./DateTime.sol";

contract Hotel is DateTime, ERC1155, Ownable, ERC1155Burnable {
    using Counters for Counters.Counter;

  address private manager;
  string hotelName;

    constructor(address owner, string memory name) ERC1155(",m,") {
        manager = owner; //sets the manager to the address passed into the constructor
        hotelName = name;
  }

  RoomType[] roomTypes; //haven't used yet
  Counters.Counter private roomTypeCounter;//creates roomTypeIds
  mapping(uint => RoomType) public idToRoomType;//mapping roomTypeId to RoomType struct
  Counters.Counter private roomNightCounter;//creates RoomNightIds (tokenIds)
  mapping(uint => RoomNight) public idToRoomNight;//mapping tokenId to RoomNight sruct

  Counters.Counter private index;

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


    function getNumDays(uint startTimestamp, uint endTimeStamp) internal pure returns (uint) {
      uint diff = endTimeStamp - startTimestamp;
      uint numDays = diff / DAY_IN_SECONDS;
      return numDays;
    }

    function getTimestampsAndArrays(
      uint8 startDay,
      uint8 startMonth,
      uint16 startYear,
      uint8 endDay,
      uint8 endMonth,
      uint16 endYear
    ) public view onlyOwner returns (
      uint[] memory, uint[] memory, uint, uint) {

      uint startTimestamp = toTimestamp(startYear, startDay, startMonth);
      uint endTimestamp = toTimestamp(endYear, endDay, endMonth);
      uint numDays = getNumDays(startTimestamp, endTimestamp);

      uint[] memory tokenIds = new uint[](numDays);
      uint[] memory amounts = new uint[](numDays);

      return (tokenIds, amounts, startTimestamp, endTimestamp);
    }
    //takes a room type, date range, price, and amount of rooms to be minted each night
    //creates a roomNight struct for each date, assigns them a unique token id, and mints/
    function mintRoomNightHelper(
      uint _roomTypeId,
      uint amount,
      uint _price,
      uint[] memory tokenIds,
      uint[] memory amounts,
      uint startTimestamp,
      uint endTimestamp
    ) internal onlyOwner {

      for(uint i=startTimestamp; i<endTimestamp; i+DAY_IN_SECONDS) {
        uint _tokenId = roomNightCounter.current();
        uint _index = index.current();

        RoomNight memory _newRoomNight = RoomNight({
          roomTypeId: _roomTypeId,
          date: i,
          price: _price,
          tokenId: _tokenId
        });

        idToRoomNight[_tokenId] = _newRoomNight;
        tokenIds[_index] = _tokenId;
        amounts[_index] = amount;

        roomNightCounter.increment();
        index.increment();
        }

        _mintBatch(manager, tokenIds, amounts, "");
        index.reset();
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

        (uint[] memory ids, uint[] memory amounts, uint start, uint end) =
        getTimestampsAndArrays(startDay, startMonth, startYear, endDay, endMonth, endYear);

        mintRoomNightHelper(roomTypeId, amount, price, ids, amounts, start, end);
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
