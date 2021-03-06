express = require 'express'
Dictionary = require '../models/dictionary'
mongodb = require 'mongodb'
router = express.Router()

router.get '/', (req, res)->
  res.render 'dictionaries/index',
    search: ''
    ORG: false
    words: []

router.get '/create/:word', (req, res)->
  if req.params.word
    dictionary = new Dictionary()
    dictionary.initialized ()->
      dictionary.put req.params.word, null, (err)->
        res.redirect "/dictionaries/#{req.params.word}"

router.get '/remove_org/:search', (req, res)->
  search = req.params.search
  dictionary = new Dictionary()
  query =
    w:
      $regex: search
    t: 'ORG'
  dictionary.remove query, (err)->
    res.redirect("/dictionaries/#{search}")

router.get '/update', (req, res)->
  dictionary = new Dictionary()
  if req.query.update_sy
    sy = req.query.val.split(' ')
    dictionary.updateById req.query.update_sy, {$set: {sy: sy}}, (err)->
      for s in sy
        dictionary.put s, null, ()->
  if req.query.update_boost
    i = req.query.val
    dictionary.updateById req.query.update_boost, {$set: {i: i}}, (err)->
  if req.query.del_word
    dictionary.remove {_id: mongodb.ObjectId req.query.del_word}, (err)->
  if req.query.del_org
    dictionary.updateById req.query.del_org, {$pull: {t: 'ORG'}}, (err)->

  res.status 200
  res.render 'success'

router.get '/:search', (req, res)->
  search = req.params.search
  dictionary = new Dictionary()
  if req.query.id
    dictionary.get [req.query.id], (err, words)->
      res.render 'dictionaries/index',
        search: ''
        ORG: (req.query.ORG == 'true')
        words: words
  else
    options = {}
    options.t = 'ORG' if req.query.ORG == 'true'
    dictionary.search search, options, (err, words)->
      res.render 'dictionaries/index',
        search: search
        ORG: (req.query.ORG == 'true')
        words: words

module.exports = router;
