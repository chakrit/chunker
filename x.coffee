
Chunker = require './index.coffee'
chunker = new Chunker '\r\n'

console.log (new Date).getTime()
chunker.pipe process.stdout

chunker.write 'asdf\r'
chunker.write '\nqwer\r'
chunker.write '\n'
chunker.end()

