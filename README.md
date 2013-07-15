# node-mongo-counter

This module allows you to create a counter field using MongoDB

## Usage

    mongoCounter = new MongoCounter(db, [collectionName], [documentID], [fieldName], [initialValue])
    // collectionName: (default: 'counters') the collection to use for the counter
    // documentID: (default: undefined) the document ID where the counter is created
    // fieldName: (default: 'counter') the field where the counter is stored
    // initialValue: (default: 1) the initial value for the counter

    mongoCounter.createDocument(function (err, objectID) {  })
    // Creates the document for the counter. Not required when `documentID` is defined

    mongoCounter.next(function (err, value) {  })
    // Generates the next number

    mongoCounter.set(value, function (err, success) {  })
    // Sets the counter to `value`

    mongoCounter.reset(function (err, success) {  })
    // Resets the counter to the initial value
