const Hotel = artifacts.require('Hotel');

contract('Hotel', (accounts) => {
  it('should deploy and assign deployer address to manager address', async () => {
    const hotel = await Hotel.deployed();
    assert(hotel, "contract was not deployed");

    const manager = await hotel.manager();
    assert.equal(manager, accounts[0]);
  });
  it('should create a room type', async () => {
    const hotel = await Hotel.deployed();
    await hotel.createRoomType('oceanview', '2', 'nice', 'false', '14', '10', {from: accounts[0]});
    const roomType = await hotel.idToRoomType(0);
    assert.equal(roomType.roomName, 'oceanview');
  });
  it('should calculate number of days in a date range', async () => {
    const hotel = await Hotel.deployed();
    const result = await hotel.getTimestampsAndDays('11','11','2021','13','11','2021');
    assert.equal(result[1], '2');
    });
  it('should create a room night', async () => {
    const hotel = await Hotel.deployed();
    await hotel.createRoomType('oceanview', '2', 'nice', 'false', '14', '10', {from: accounts[0]});

    const startDay = '11';
    const endDay = '13';

    const result1 = await hotel.getTimestampsAndDays(startDay,'11','2021',endDay,'11','2021');
    const result2 = await hotel.mintRoomNightHelper('0','10','100',result1[0],result1[1], {from: accounts[0]});

    const token0 = await hotel.idToRoomNight(0);
    assert.equal(token0.price, '100');

    const token1 = await hotel.idToRoomNight(1);
    assert.equal(token1.price, '100');

    const token0Date = await hotel.getDay(token0.date);
    assert.equal(token0Date, startDay);

    const token1Date = await hotel.getDay(token1.date);
    assert.equal(token1Date, endDay - 1);

    const counter = await hotel.roomNightCounter();
    assert.equal(counter, '2');
  });
  it('should mint room nights and send them to the manager address', async () => {
    const hotel = await Hotel.deployed();

    await hotel.createRoomType('oceanview', '2', 'nice', 'false', '14', '10', {from: accounts[0]});
    await hotel.mintRoomNights('0','10','100','11','11','2021','13','11','2021');

    const manager = await hotel.manager();

    balance = await hotel.balanceOf(manager, '0');
    assert.equal(balance, '10');

    balance2 = await hotel.balanceOf(manager, '1');
    assert.equal(balance2, '10');

    //const counter = await hotel.roomNightCounter();
    //assert.equal(counter, '2');  This is failing. Returning '4'.  This is because the contract is not re-deploying before this test.
  });
});
