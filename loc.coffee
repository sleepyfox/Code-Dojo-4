class Line 
  constructor: (@string) ->

  isAllOneLineComment: ->
    if @string.match(/^\s*\/\//) is null
      false
    else
      true

  isStartOfBlockComment: ->
    if @string.match(/\/\*/) is null
      false
    else
      true

  isEndOfBlockComment: ->
    if @string.match(/\*\//) is null
      false
    else
      true

  hasNonWhitespaceBeforeBlockCommentStart: ->
    if @string.match(/\S+\s*\/\*/) is null
      false
    else
      true

  hasNonWhitespaceAfterBlockCommentEnd: ->
    if @string.match(/\*\/\s*\S+/) is null
      false
    else
      true
  
class Source   
  constructor: (string) ->
    @array = string.split '\n'

  lines: ->
    @array.length

  linesOfCode: ->
    lineCounter = 0
    inBlockComment = false
    for sourceLine in @array
      line = new Line sourceLine
      # start of hideous nested if/else block
      if inBlockComment
        if line.isEndOfBlockComment() 
          inBlockComment = false
          if line.hasNonWhitespaceAfterBlockCommentEnd() 
            lineCounter++
      else # not in block comment
        if line.isStartOfBlockComment() 
          inBlockComment = true
          if line.hasNonWhitespaceBeforeBlockCommentStart() 
            lineCounter++
        else # not start of block comment
          unless line.isAllOneLineComment() 
            lineCounter++          
    lineCounter

exports.Source = Source
exports.Line = Line
