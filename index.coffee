
# index.coffee - Main index file
module.exports = do ->

  stream = require 'stream'

  return class Chunker extends stream.Transform
    previous: null
    matcher: new Buffer '\r\n'

    constructor: (options) ->
      super options
      if options and options.matcher
        @matcher = options.matcher
        @matcher = new Buffer @matcher if typeof @matcher is 'string'

    _transform: (chunk, encoding, callback) ->
      pivot = @matcher[@matcher.length - 1]
      matched = false
      match = -1
      start = 0
      skip = 0

      if @previous
        chunk = Buffer.concat [@previous, chunk], @previous.length + chunk.length
        skip = @previous.length - @matcher.length # skip checked bytes
        @previous = null

      # scan for last char
      for i in [skip...chunk.length] by 1
        continue unless chunk[i] is pivot

        # then scan backwards
        match = i
        for j in [i...i - @matcher.length] by -1
          continue if chunk[j] is @matcher[@matcher.length - i + j - 1]
          match = -1

        if match > -1
          part = chunk.slice start, match + 1
          @push part
          @emit 'chunk', part

          start = match + 1

      # save stuff from last matched item
      @previous = chunk.slice start
      callback null

