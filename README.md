
# CHUNKER

node v0.10.x required.

Split your streams into chunks with an arbitary-length matcher. Explicitly
does not consume tokens. Useful for splitting up chunks and passing it to an
external parser that expects the split tokens to be there.

# API

This module exports a `Chunker` class. This is simply an instance of a
[`Transform` stream][0] so you can pipe things in and it will only output
(emit `readable`) a chunk that has all the content from the start of the first
chunk until the specified splitter token (called a `matcher` inside the
codebase)

### example.js

```js
var fs = require('fs'), Chunker = require('./index.js');

var chunker = new Chunker({ matcher: 'what ' })
  , input = fs.createReadStream('./input.txt');

chunker.on('readable', function() {
  var chunk;
  while (chunk = chunker.read()) {
    console.log(chunk.toString());
  }
});

process.stdin.pipe(chunker);
```

### output

```
$ node example.js
do what 
you want to do not what 
you are told to do and do what 
makes you happy and keep away from what 
makes you sad but do what 
you have to do that is what 
resposibility means but do not forget what 
makes your heart tick or you will forgot what 
```

# LICENSE

BSD3 (see LICENSE file)

[0]: http://nodejs.org/api/stream.html#stream_class_stream_transform

