pragma solidity ^0.5.1;


contract RequestForQuotations {

  enum RFQStatus { Received, Declined }

  struct RequestForQuotation {
    uint issuedAt;
    string ubl;
    RFQStatus status;
  }

  // A string field cannot be indexed in a event, this is why a confirmationId of type uint was introduced.
  // As an added benefit, it also allows to count the number of submitted RFQs.
  event RFQSubmitted(uint indexed confirmationId, string id);

  /* ------------- State ------------- */

  address private buyer;

  uint public nbrSubmittedRFQs = 0;

  // Maps the confirmation id to the external id
  mapping(uint => string) public confirmationIdsToExternalIds;

  // Maps the external id to the RFQ
  mapping(string => RequestForQuotation) rfqs;

  /* ------------- RFQ can only be submitted by a buyer ------------- */

  constructor() public {
    buyer = msg.sender;
  }

  function getBuyerAddress() public view returns (address) {
    return buyer;
  }

  modifier onlyBuyer() {
    require(msg.sender == buyer);
    _;
  }

  /* ------------- RFQ logic ------------- */

  function getRFQUBL(string memory id) public view returns (string memory ubl) {
    return rfqs[id].ubl;
  }

  function submitRFQ(string memory id, uint issuedAt, string memory ubl) public onlyBuyer returns (uint confirmationId)  {
    confirmationId = nbrSubmittedRFQs + 1;
    nbrSubmittedRFQs = confirmationId;

    confirmationIdsToExternalIds[confirmationId] = id;
    rfqs[id].issuedAt = issuedAt;
    rfqs[id].ubl = ubl;
    rfqs[id].status = RFQStatus.Received;

    emit RFQSubmitted(confirmationId, id);
    return confirmationId;
  }
}
