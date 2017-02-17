contract DualIntegrator {
  uint months;
  address factory;
  address partyAAddress;
  address partyBAddress;
  string contractHash;
  string partyAName;
  string partyBName;

  function DualIntegrator(uint _months, address _partyAAddress, address _partyBAddress, string _partyAName, string _partyBName) {
    partyAAddress = _partyAAddress;
    partyBAddress = _partyBAddress;
    partyAName = _partyAName;
    partyBName = _partyBName;
    months = _months;
    factory = msg.sender;
  }

  function setHash(string _hash) {
    contractHash = _hash; // we do not include permission checking here, but in a real application you would restrict this
  }

  function purge() {
    if (msg.sender == factory){
        selfdestruct(factory);
    }
  }

  function getParams() constant returns (uint _months, address _partyAAddress, address _partyBAddress) {
    return (months, partyAAddress, partyBAddress);
  }

  function getNames() constant returns (string _hash) {
    return (contractHash);
  }
}

contract IntegratorFactory {
  address[] addresses;

  function createInstrument(uint _months, address _partyAAddress, address _partyBAddress, string _partyAName, string _partyBName) returns (address IntegratorAddr) {
    address mostRecentIntegrationContract;

    // NOTE: we do not set the hash in the contract on instantiation because the address of the code
    //   needs to be added to the prose document before it is signed with Docusign API and finalized
    //   with the hash of the document.
    mostRecentIntegrationContract = new DualIntegrator(_months, _partyAAddress, _partyBAddress, _partyAName, _partyBName);

    // return the contract address for consumption
    addAddress(mostRecentIntegrationContract);

    return mostRecentIntegrationContract;
  }

  function rmInstrument(address _address) {
    uint placeholder;

    // NOTE: in a real application you would have a check here so that only the proper key pairs could
    // trigger this function.

    for (uint i = 0; i < addresses.length; i++) {
      if (addresses[i] == _address) {
        placeholder = i;
      }
    }

    delete addresses[placeholder];
    addresses.length -= 1;

    DualIntegrator addressToRm = DualIntegrator(_address);
    addressToRm.purge();
  }

  function addAddress(address newAddress) {
    addresses.push(newAddress);
  }

  function getAddresses() constant returns (address[] _addresses) {
    return addresses;
  }
}