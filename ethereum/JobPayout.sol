pragma solidity ^0.4.4;

contract Provider {
  string public providerName;
  string public description;

  mapping (address => staffUser) public staffList;
  mapping (bytes32 => Job) public jobs;

  struct staffUser{
    bool active;
    uint lastUpdated;
    uint256 payout;
  }

  struct Job {
    bytes32 name;
    uint256 rate;
  }

  function Provider(string _name, string _description) {
    providerName = _name;
    description = _description;
  }

  function setDebt(uint256 _debt, address _userAddress) {
    User person = User(_userAddress);
    person.setDebt(_debt);
  }

  function recievePayment(address _userAddress) payable returns (bool result) {
    User person = User(_userAddress);
    person.clearDebt();
    return true;
  }

  function addStaff(address _userAddress) {
    staffList[_userAddress] = staffUser({
      active:true,
      lastUpdated: now,
      payout: 0
      });
  }

  function addJob(bytes32 _name, uint256 _rate) {
    jobs[_name] = Job({name:_name,rate:_rate});
  }

  function updateJobRate(bytes32 _name, uint256 _rate){
    jobs[_name].rate = _rate; 
  }

  function payOutJob(address _userAddress, bytes32 _jobName) {
    if (!_userAddress.send(jobs[_jobName].rate)) {
      staffList[_userAddress].payout += jobs[_jobName].rate;
    }
  }
}

contract User {
  string public userName;
  address public owner;

  mapping (address => Service) public services;

  struct Service{
    bool active;
    uint lastUpdated;
    uint debt;
  }

  function User(string _name) payable {
    userName = _name;
    owner = msg.sender;
  }

  function registerToProvider(address _providerAddress){
    services[_providerAddress] = Service({
      active:true,
      lastUpdated: now,
      debt: 0
      });
  }

  function setDebt(uint256 _debt){
    if(services[msg.sender].active){
      services[msg.sender].lastUpdated = now;
      services[msg.sender].debt += _debt;
      } else {
        throw;
      }
  }

  function clearDebt() returns (bool result){
    if (services[msg.sender].active){
      services[msg.sender].lastUpdated = now;
      services[msg.sender].debt = 0;
    } else {
      throw;
    }
  }

  function unsubcribe(address _providerAddress){
    if(services[_providerAddress].debt == 0){
      services[_providerAddress].active = false;
    } else {
      throw;
    }
  }

}
