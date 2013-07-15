expect = require('chai').expect

MongoClient = require('mongodb').MongoClient

MongoCounter = require('../')


describe 'MongoCounter', ->

  testDb = 'mongodb://localhost:27017/test-auto-increment'
  testCollection = 'testCollection'
  testDocumentID = 'testID'
  testField = 'testField'
  testInitialValue = 5

  db = null

  before (done) ->
    MongoClient.connect testDb, (err, connectedDb) ->
      if err? then return done(err)
      else
          db = connectedDb
          done()

  beforeEach (done) ->
    db.dropDatabase(done)
    ###
    db.dropDatabase (err, success) ->
      console.log(err)
      console.log(success)
      db.collection(testCollection).find().toArray (err, docs) ->
        console.log(err)
        console.log(docs)
        done(err, success)
    ###

  it 'should initialize an auto-incrementing field', () ->
    counter = new MongoCounter(db, testCollection, testDocumentID, testField, testInitialValue)
    expect(counter).to.be.ok

  it 'should create document and increment the field on next()', (done) ->
    counter = new MongoCounter(db, testCollection, testDocumentID, testField, testInitialValue)
    counter.next (err, success) ->
      expect(success).to.equal(testInitialValue)
      db.collection(testCollection).findOne { _id: testDocumentID }, (err, doc) ->
        expect(err).to.be.not.ok
        expect(doc).to.have.property(testField).that.equals(testInitialValue)
        done()


  it 'should create document and set field value', (done) ->
    counter = new MongoCounter(db, testCollection, testDocumentID, testField, testInitialValue)
    counter.set 10, (err, success) ->
      expect(success).to.equal(10)
      db.collection(testCollection).findOne { _id: testDocumentID }, (err, doc) ->
        expect(err).to.be.not.ok
        expect(doc).to.have.property(testField).that.equals(10)
        done()

  it 'should reset set field value', (done) ->
    counter = new MongoCounter(db, testCollection, testDocumentID, testField, testInitialValue)
    counter.set 10, (err, success) ->
      expect(success).to.equal(10)
      counter.reset (err, doc) ->
        expect(doc).to.equal(testInitialValue)
        done()

  it 'should use 1 as the default initial value', (done) ->
    counter = new MongoCounter(db, testCollection, testDocumentID, testField)
    counter.next (err, success) ->
      expect(success).to.equal(1)
      done()

  it 'should use "counter" as the default field', (done) ->
    counter = new MongoCounter(db, testCollection, testDocumentID, undefined, testInitialValue)
    counter.next (err, success) ->
      expect(success).to.equal(testInitialValue)
      db.collection(testCollection).findOne { _id: testDocumentID }, (err, doc) ->
        expect(err).to.be.not.ok
        expect(doc).to.have.property('counter').that.equals(testInitialValue)
        done()

  it 'should create document with documentID', (done) ->
    counter = new MongoCounter(db, testCollection, testDocumentID, testField, testInitialValue)
    counter.createDocument (err, success) ->
      expect(err).to.be.not.ok
      expect(success).to.equal(testDocumentID)
      db.collection(testCollection).findOne { _id: success }, (err, doc) ->
        expect(err).to.be.not.ok
        expect(doc).to.deep.equal({ _id: success })
        done()

  it 'should assign ID to document automatically', (done) ->
    counter = new MongoCounter(db, testCollection)
    counter.createDocument (err, success) ->
      expect(err).to.be.not.ok
      expect(success).to.be.ok
      counter.next (err, success) ->
        expect(success).to.equal(1)
        done()

  it 'should use "counters" as the default collection', (done) ->
    counter = new MongoCounter(db)
    counter.createDocument (err, success) ->
      expect(err).to.be.not.ok
      expect(success).to.be.ok
      db.collection('counters').findOne { _id: success }, (err, doc) ->
        expect(err).to.be.not.ok
        expect(doc).to.be.ok
        done()
