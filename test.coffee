#!/usr/bin/env coffee

# test.coffee - Tests the chunker
do ->

  fs = require 'fs'
  { test } = require 'tap'
  { inspect } = require 'util'

  Chunker = require './index.js'


  test 'exported interface', (t) ->
    t.plan 3

    chunker = new Chunker
    t.type chunker._transform, 'function', '_transform function overridden'
    t.equivalent chunker.matcher, (new Buffer '\r\n'), 'default matcher supplied'

    chunker = new Chunker matcher: 'asdf'
    t.equivalent chunker.matcher, (new Buffer 'asdf'), 'opts.matcher saved'


  condition = (description, opts) ->
    test description, (t) ->
      { inputs, outputs, matcher, leftover } = opts

      inputs = (new Buffer i for i in inputs) if typeof inputs[0] is 'string'
      outputs = (new Buffer o for o in outputs) if typeof outputs[0] is 'string'
      leftover = new Buffer leftover if typeof leftover is 'string'
      chunker = new Chunker matcher: matcher or '\r\n'

      outputs = (o for o in outputs when o.length)
      t.plan outputs.length + (leftover and 1 or 0)

      index = 0
      chunker.on 'readable', ->
        while index < outputs.length and buffer = chunker.read()
          t.same buffer, outputs[index++], "correct output ##{index}"

        if index >= outputs.length
          chunker.removeAllListeners 'readable'
          t.same chunker.leftover, leftover, "leftover buffer correct" if leftover
          t.end()

      pump = ->
        while inputs.length and chunker.write inputs.shift() then # no-op
        unless inputs.length
          chunker.end()
          chunker.removeListener 'writable', pump

      chunker.on 'writable', pump
      setImmediate pump

  condition 'exact cut',
    inputs: ['asdf\r\n']
    outputs: ['asdf\r\n']

  condition 'inexact cut',
    inputs: ['asdf\r\nzxcv']
    outputs: ['asdf\r\n']
    leftover: 'zxcv'

  condition 'multiple matches in one chunk',
    inputs: ['qwer\r\nasdf\r\nzxcv\r\n']
    outputs: ['qwer\r\n', 'asdf\r\n', 'zxcv\r\n']

  condition 'chunks with matcher in-between',
    inputs: ['asdf\r', '\nqwer\r', '\nzxcv\r', '\n', 'test\r\nlast']
    outputs: ['asdf\r\n', 'qwer\r\n', 'zxcv\r\n', 'test\r\n']
    leftover: 'last'

  condition 'consecutive chunk without matcher',
    inputs: ['asdf', 'qwer', 'zxcv', '\r\n']
    outputs: ['asdfqwerzxcv\r\n']

  condition 'large file input',
    inputs: [fs.readFileSync 'input.txt', 'utf-8']
    outputs: (fs.readFileSync 'output.txt', 'utf-8').split '\n'
    matcher: 'what '

