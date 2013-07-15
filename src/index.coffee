ObjectID = require('mongodb').ObjectID

module.exports = class MongoCounter
  constructor: (@db, @collectionName = 'counters', @documentID = undefined, @fieldName = 'counter', @initialValue = 1) ->

  mongoUpdateObject: (value) ->
    toReturn = {}
    toReturn[@fieldName] = value
    toReturn

  setOrNext: ( mongoOp, callback ) ->
    @db.collection(@collectionName).findAndModify { _id: @documentID }, [], mongoOp, { upsert: true, new: true }, (err, doc) =>
      if err? then return callback(err, null)
      callback(null, doc[@fieldName] )

  reset: (callback) -> @set(@initialValue, callback)
  set: (value, callback) -> @setOrNext({ $set: @mongoUpdateObject(value) }, callback)
  next: (callback) -> @setOrNext({ $inc: @mongoUpdateObject(@initialValue) }, callback)


  createDocument: (callback) -> @db.collection(@collectionName).save { _id: @documentID }, {safe:true}, (err, success) =>
    if err? then callback(err)
    #MongoDB returns 1 when the document was updated. In this case, it already existed and @documentID must be set
    else if success == 1 then callback(null, @documentID)
    #Otherwise, MongoDB returns the document
    else
      @documentID = success._id
      callback(null, @documentID)