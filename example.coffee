
fs = require 'fs'
Chunker = require './index'

chunker = new Chunker matcher: 'what '
input = fs.createReadStream './input.txt'

USE_EVENT = no

write = (chunk) ->
  process.stdout.write chunk
  process.stdout.write '\r\n'


if USE_EVENT # uses the `chunk` event`
  chunker.on 'chunk', write

else # uses normal stream events
  chunker.on 'readable', ->
    write chunk while chunk = chunker.read()

input.pipe chunker
input.once 'end', -> write chunker.leftover

