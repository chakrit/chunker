
fs = require 'fs'
Chunker = require './index'

chunker = new Chunker matcher: 'what '
input = fs.createReadStream './input.txt'

chunker.on 'readable', ->
  while chunk = chunker.read()
    process.stdout.write chunk
    process.stdout.write '\r\n'

input.pipe chunker

