pragma solidity ^0.7.5;

import "remix_tests.sol"; // this import is automatically injected by Remix.
import "./RequestForQuotations.sol";


contract RequestForQuotationsTest {

    RequestForQuotations rfqContract;

    function beforeAll() public {
        rfqContract = new RequestForQuotations();
    }

    function checkRFQCreation() public {
        bytes16 id = "5d05fde0be654ed1";
        uint issuedAt = uint(1);
        string memory ubl = "<RequestForQuotation xmlns=... </RequestForQuotation>";
        rfqContract.submitRFQ(id, issuedAt, ubl);

        uint resultIssuedAt;
        string memory resultUbl;
        RequestForQuotations.RFQStatus resultStatus;
        (resultIssuedAt, resultUbl, resultStatus) = rfqContract.getRFQ(id);
        Assert.equal(resultIssuedAt, issuedAt, "issuedAt field is wrong");
        Assert.equal(resultUbl, ubl, "ubl field is wrong");
        Assert.equal(uint(resultStatus), uint(RequestForQuotations.RFQStatus.Received), "status field is wrong");
    }

    function checkQuoteCreation() public {
        Assert.equal(rfqContract.nbrOfQuotes(), 0, "There should be no quotes created yet");

        // Create RFQ
        bytes16 rfqId = "8044c4b2a6e14b2a";
        rfqContract.submitRFQ(rfqId, uint(1), "ubl");
        RequestForQuotations.RFQStatus resultStatus;
        (,, resultStatus) = rfqContract.getRFQ(rfqId);
        Assert.equal(uint(resultStatus), uint(RequestForQuotations.RFQStatus.Received), "status field is wrong");

        // Decline RFQ
        bytes16 declineId = "9175ae38102346c3";
        rfqContract.declineRFQ(declineId, rfqId, uint(1));

        (,, resultStatus) = rfqContract.getRFQ(rfqId);
        Assert.equal(uint(resultStatus), uint(RequestForQuotations.RFQStatus.Declined), "status field is wrong");

        uint resIssuedAt;
        string memory resUBL;
        RequestForQuotations.QuoteStatus resQuoteStatus;
        bytes16 resRFQId;
        address resSupplier;

        (resIssuedAt, resUBL, resQuoteStatus, resRFQId, resSupplier) = rfqContract.getQuote(declineId);
        Assert.equal(resIssuedAt, uint(1), "issuedAt field is wrong");
        Assert.equal(resUBL, "", "ubl field is wrong");
        Assert.equal(uint(resQuoteStatus), uint(RequestForQuotations.QuoteStatus.Decline), "status field is wrong");
        Assert.equal(resRFQId, rfqId, "RFQ id field is wrong");

        Assert.equal(rfqContract.nbrOfQuotes(), 1, "There should be 1 created quote");

        // Submit RFQ
        bytes16 offerId = "8f282b8adaec4bbd";
        string memory ubl = "quoteUBL";
        rfqContract.submitQuote(offerId, rfqId, uint(2), ubl);

        (,, resultStatus) = rfqContract.getRFQ(rfqId);
        Assert.equal(uint(resultStatus), uint(RequestForQuotations.RFQStatus.QuoteProvided), "status field is wrong");

        (resIssuedAt, resUBL, resQuoteStatus, resRFQId, resSupplier) = rfqContract.getQuote(offerId);
        Assert.equal(resIssuedAt, uint(2), "issuedAt field is wrong");
        Assert.equal(resUBL, ubl, "ubl field is wrong");
        Assert.equal(uint(resQuoteStatus), uint(RequestForQuotations.QuoteStatus.Offer), "status field is wrong");
        Assert.equal(resRFQId, rfqId, "RFQ id field is wrong");

        Assert.equal(rfqContract.nbrOfQuotes(), 2, "There should be 2 created quote");

        declineId = "a2b24232ef31449b";
        rfqContract.declineRFQ(declineId, rfqId, uint(1));

        (,, resultStatus) = rfqContract.getRFQ(rfqId);
        Assert.equal(uint(resultStatus), uint(RequestForQuotations.RFQStatus.QuoteProvided), "status field is wrong");

        Assert.equal(rfqContract.nbrOfQuotes(), 3, "There should be 3 created quote");
    }
}
