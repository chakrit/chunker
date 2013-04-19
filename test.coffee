
# test.coffee - Tests the chunker
do ->

  { test } = require 'tap'
  { inspect } = require 'util'

  Chunker = require './index.js'


  test 'exported interface', (t) ->
    t.plan 3

    chunker = new Chunker
    t.type chunker._transform, 'function', '_transform function not overridden'
    t.equivalent chunker.matcher, (new Buffer '\r\n'), 'default matcher not supplied'
    t.equivalent (new Chunker matcher: 'asdf').matcher, (new Buffer 'asdf'), 'specified matcher not saved'

  test 'CRLF chunking', (t) ->

    condition = (description, opts) ->
      t.test description, (t) ->
        { inputs, outputs, matcher } = opts

        t.plan outputs.length

        inputs = (new Buffer i for i in inputs) if typeof inputs[0] is 'string'
        outputs = (new Buffer o for o in outputs) if typeof outputs[0] is 'string'
        chunker = new Chunker matcher or '\r\n'

        index = 0
        chunker.on 'readable', ->
          while buffer = chunker.read()
            t.equivalent buffer, outputs[index++], "invalid chunk #{index}"

        chunker.write buffer for buffer in inputs
        chunker.end()


    condition 'exact cut',
      inputs: ['asdf\r\n']
      outputs: ['asdf\r\n']

    condition 'multiple matches in one chunk',
      inputs: ['qwer\r\nasdf\r\nzxcv\r\n']
      outputs: ['qwer\r\n', 'asdf\r\n', 'zxcv\r\n']

    condition 'chunks with matcher in-between',
      inputs: ['asdf\r', '\nqwer\r', '\nzxcv\r', '\n']
      outputs: ['asdf\r\n', 'qwer\r\n', 'zxcv\r\n']

    condition 'consecutive chunk without matcher',
      inputs: ['asdf', 'qwer', 'zxcv', '\r\n']
      outputs: ['asdfqwerzxcv\r\n']

    # TODO: More exhausive test

    `/*
    chunk ['asdf\r\n'], ['asdf\r\n']
    chunk ['asdf\r\nqwer\r\n'], ['asdf\r\n', 'qwer\r\n']
    chunk ['asdf\r', '\nqwer\r', '\n'], ['asdf\r\n', 'qwer\r\n']
    */`


