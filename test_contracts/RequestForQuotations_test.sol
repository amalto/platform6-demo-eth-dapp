pragma solidity ^0.5.1;

import "remix_tests.sol"; // this import is automatically injected by Remix.
import "./RequestForQuotations.sol";


contract RequestForQuotationsTest {


    RequestForQuotations rfqContract;

    function beforeAll () public {
        rfqContract = new RequestForQuotations();
    }

    function checkRFQCreation () public {
        Assert.equal(rfqContract.nbrOfRFQs(), 0, "There should be no RFQs created yet");

        // 8044c4b2-a6e1-4b2a-95e1-bf75becc867c
        // 9175ae38-1023-46c3-9119-787f85e54ad5
        // 8f282b8a-daec-4bbd-a077-bb5548489379
        // b539ae01-76b6-402b-a6b2-20488f1695de
        // a2b24232-ef31-449b-a7a2-971b6c775e03
        bytes32 id = "5d05fde0be654ed19bd57db88dfaf171";
        uint issuedAt = uint(1);
        string memory ubl = "<RequestForQuotation xmlns=... </RequestForQuotation>";
        rfqContract.submitRFQ(id, issuedAt, ubl);

        Assert.equal(rfqContract.nbrOfRFQs(), 1, "There should be 1 created RFQ");

        uint resultIssuedAt;
        string memory resultUbl;
        RequestForQuotations.RFQStatus resultStatus;
        bytes32[] memory quoteIds;
        (resultIssuedAt, resultUbl, resultStatus, quoteIds) = rfqContract.getRFQ(id);
        Assert.equal(resultIssuedAt, issuedAt, "issuedAt field is wrong");
        Assert.equal(resultUbl, ubl, "ubl field is wrong");
        Assert.equal(uint(resultStatus), uint(RequestForQuotations.RFQStatus.Received), "status field is wrong");
        Assert.equal(quoteIds.length, 0, "quoteIds field is wrong");
    }
}
