
fs = require 'fs'
Chunker = require './index'

chunker = new Chunker matcher: 'what '
input = fs.createReadStream './input.txt'

USE_EVENT = no


if USE_EVENT # uses the `chunk` event`
  chunker.on 'chunk', (chunk) ->
    process.stdout.write chunk
    process.stdout.write '\r\n'

else # uses normal stream events
  chunker.on 'readable', ->
    while chunk = chunker.read()
      process.stdout.write chunk
      process.stdout.write '\r\n'

input.pipe chunker

