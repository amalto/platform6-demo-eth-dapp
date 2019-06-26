# Platform 6 Ethereum Demo DApp

FIXME Link to Platform 6 tutorial.

This project is based on the [Embark framework](https://embark.status.im/).

This project contains the following smart contracts:


# SimpleStorage

## storedData - view
_No parameters_

## set - read
|name |type |description
|-----|-----|-----------
|newValue|uint256|

## get - view
_No parameters_

## constructor - read
|name |type |description
|-----|-----|-----------
|initialValue|uint256|

## StoredDataChanged - event
|name |type |description
|-----|-----|-----------
|oldValue|uint256|
|newValue|uint256|


# RequestForQuotations


## getRFQ - view
|name |type |description
|-----|-----|-----------
|id|bytes16|

## getQuote - view
|name |type |description
|-----|-----|-----------
|id|bytes16|

## declineRFQ - read
|name |type |description
|-----|-----|-----------
|id|bytes16|
|rfqId|bytes16|
|issuedAt|uint256|

## submitQuote - read
|name |type |description
|-----|-----|-----------
|id|bytes16|
|rfqId|bytes16|
|issuedAt|uint256|
|ubl|string|

## submitRFQ - read
|name |type |description
|-----|-----|-----------
|id|bytes16|
|issuedAt|uint256|
|ubl|string|

## nbrOfRFQs - view
_No parameters_

## nbrOfQuotes - view
_No parameters_

## getBuyerAddress - view
_No parameters_

## constructor - read
_No parameters_

## RFQReceived - event
|name |type |description
|-----|-----|-----------
|id|bytes16|
|issuedAt|uint256|
|ubl|string|

## QuoteReceived - event
|name |type |description
|-----|-----|-----------
|supplier|address|
|rfqId|bytes16|
|quoteId|bytes16|
|issuedAt|uint256|
|ubl|string|

## RFQDeclined - event
|name |type |description
|-----|-----|-----------
|supplier|address|
|rfqId|bytes16|
|quoteId|bytes16|
|issuedAt|uint256|
