const uuidv4 = require('uuid/v4');
const uuidToHex = require('uuid-to-hex');
const RequestForQuotations = embark.require('Embark/contracts/RequestForQuotations');
const emptyString = "";


let accounts;

config({
    contracts: {
        "RequestForQuotations": {
            // args: [100]
        }
    }
}, (err, theAccounts) => {
    accounts = theAccounts;
});


contract("RequestForQuotations", function () {

    it("Return empty string for a non-existent RFQ", async function () {
        const id = uuidToHex(uuidv4(), true);
        const result = await RequestForQuotations.methods.getRFQUBL(id).call();
        assert.strictEqual(result, emptyString);
    });

    it("Submit a new RFQ", async function () {
        let resultNbrRFQs = await RequestForQuotations.methods.nbrRFQs().call();
        assert.strictEqual(parseInt(resultNbrRFQs, 10), 0);

        const id = uuidToHex(uuidv4(), true);
        const issuedAt = new Date().getTime();
        const ubl = '<RequestForQuotation xmlns=... </RequestForQuotation>';

        await RequestForQuotations.methods.submitRFQ(id, issuedAt, ubl).send();

        resultNbrRFQs = await RequestForQuotations.methods.nbrRFQs().call();
        assert.strictEqual(parseInt(resultNbrRFQs, 10), 1);

        const resultUBL = await RequestForQuotations.methods.getRFQUBL(id).call();
        assert.strictEqual(resultUBL, ubl);

        // TODO add another RFQ
    });
});