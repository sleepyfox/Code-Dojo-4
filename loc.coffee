class Line 
  constructor: (@string) ->
    @stateTable = 
      0: @hasCode
      1: @hasNonWhitespaceAfterBlockCommentEnd
      2: @hasNonWhitespaceBeforeBlockCommentStart
      3: -> 0 

  increment: (beforeState, afterState) ->
    # figure out the increment by devolving it to a state table of functions
    i = 0 + (if afterState then 2 else 0) + (if beforeState then 1 else 0)
    @stateTable[i]() 

  isBlank: =>
    if (@string.match(/^\s*$/) is null)
      false
    else
      true

  isAllOneLineComment: =>
    if @string.match(/^\s*\/\//) is null
      false
    else
      true

  isStartOfBlockComment: =>
    if @string.match(/\/\*/) is null
      false
    else
      true

  isEndOfBlockComment: =>
    if @string.match(/\*\//) is null
      false
    else
      true

  hasNonWhitespaceBeforeBlockCommentStart: =>
    if @string.match(/\S+\s*\/\*/) is null
      0
    else
      1

  hasNonWhitespaceAfterBlockCommentEnd: =>
    if @string.match(/\*\/\s*\S+/) is null
      0
    else
      if @string.match(/\*\/\s*\/\//) is null
        1  
      else
        0 
    
  isAllOneLineBlockComment: =>
    if @string.match(/^\s*\/\*.*\*\/\s*$/) is null
      false
    else
      true

  hasCode: =>
    if (@isBlank() or @isAllOneLineComment() or @isAllOneLineBlockComment()) # needed this last to catch the false, false 'transition'
      0
    else
      1
  
  transition: (inBlockComment) =>
    if inBlockComment
      if @isEndOfBlockComment()
        true
      else
        false
    else # not in block comment
      if (@isStartOfBlockComment() and not @isEndOfBlockComment()) # need to catch the one line block comment case
        true
      else
        false

# utility boolean logic method
nor = (a, b) ->
  if b
    !a
  else
    a

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
      newInBlockComment = nor line.transition(inBlockComment), inBlockComment 
      lineCounter = lineCounter + line.increment inBlockComment, newInBlockComment
      inBlockComment = newInBlockComment
    lineCounter

exports.Source = Source
exports.Line = Line
