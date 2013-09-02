
# CHUNKER

node v0.10.x required for the [streams2 support][1].

Split your streams into chunks with an arbitrary-length matcher. Does not consume the
matcher bytes so you can further analyze them or use them as delimiter for parsing. Also
expose the `leftover` buffer to make connection mode-switching easier to implement.

Chunker is designed to work with very small splitter token such as CRLF or '\0'.

# API

This module exports a `Chunker` class. This is simply an instance of a
[`Transform` stream][0] so you can pipe things in and it will only output (emit
`readable`) a chunk that has all the content from the start of the first chunk until the
end of the specified splitter token (called a `matcher` inside the codebase)

For convenience, you can also listen for the chunker's `chunk` event. Additionally, you
can inspect the `leftover` property to get at the last chunk that has yet to be processed
once the stream ends.

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

process.stdin.once('end',  function() {
  console.log(chunker.leftover.toString());
})

process.stdin.pipe(chunker);
```

### output

```
$ cat input.txt | node example.js
do what 
you want to do not what 
you are told to do and do what 
makes you happy and keep away from what 
makes you sad but do what 
you have to do that is what 
resposibility means but do not forget what 
makes your heart tick or you will forgot what 
you were born to be
```

# LICENSE

BSD3 (see LICENSE file)

# TODO

* Support for longer-length chunker or use a proper state machine string matching
  algorithm.
* More exhausive streaming tests.

[0]: http://nodejs.org/api/stream.html#stream_class_stream_transform
[1]: http://blog.nodejs.org/2012/12/20/streams2/

