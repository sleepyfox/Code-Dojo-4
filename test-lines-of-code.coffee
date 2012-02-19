vows = require 'vows'
assert = require 'assert'
loc = require './loc'
Source = loc.Source
Line = loc.Line

ONELINESOURCE = "public static final void main { }"

ONELINECOMMENT = "   // one line comment "

STARTOFBLOCKCOMMENT = "  1 /* // comment /"

ENDOFBLOCKCOMMENT = "// comment ends */ //"

SIMPLESOURCE = "// This file contains 3 lines of code \n
public interface Dave { \n
  /** \n
   * count the number of lines in a file\n
   */\n
  int countLines(File inFile); // not the real signature!\n
}"

COMPLEXSOURCE = "/*****\n
   * This is a test program with 5 lines of code\n
   *  \/* no nesting allowed!\n
   //*****//***/// Slightly pathological comment ending...\n
\n
  public class Hello {\n
      public static final void main(String [] args) { // gotta love Java\n
          // Say hello\n
        System./*wait*/out./*for*/println/*it*/(\"Hello/*\");\n
      }\n
\n
}"

vows
  .describe("Count lines of code test")
  .addBatch
    'when creating a new source file':
      topic: -> 
        source = new Source ONELINESOURCE
      'then source object is not null': (topic) ->
        assert.isNotNull topic
        if debug? then console.log topic
      'and the source.array is not null': (topic) ->
        assert.isNotNull topic.array
      'and the source is 1 line long': (topic) ->
        assert.equal 1, topic.lines()
      'and the source has the correct content': (topic) ->
        assert.equal ONELINESOURCE, topic.array[0]
      
    'when testing a single line comment':
      topic: ->
        new Line ONELINECOMMENT
      'then isAllOneLineComment returns true': (topic) ->
        assert.isTrue topic.isAllOneLineComment() 
    
    'when testing a block comment start':
      topic: ->
        new Line STARTOFBLOCKCOMMENT
      'then isStartOfBlockComment returns true': (topic) ->
        assert.isTrue topic.isStartOfBlockComment()
      'and hasNonWhitespaceBeforeBlockCommentStart': (topic) ->
        assert.isTrue topic.hasNonWhitespaceBeforeBlockCommentStart()

    'when testing a block comment end':
      topic: ->
        new Line ENDOFBLOCKCOMMENT
      'then isStartOfBlockComment returns true': (topic) ->
        assert.isTrue topic.isEndOfBlockComment()
      'and hasNonWhitespaceAfterBlockCommentEnd': (topic) ->
        assert.isTrue topic.hasNonWhitespaceAfterBlockCommentEnd()

    'when testing a simple source Java file with 3 lines':
      topic: ->
        source = new Source SIMPLESOURCE
      'then source object is 7 lines': (topic) ->
        assert.equal topic.lines(), 7
      'and the source object has 3 lines of code': (topic) ->
        assert.equal topic.linesOfCode(), 3

    'when testing a complex source Java file with 3 lines':
      topic: ->
        source = new Source COMPLEXSOURCE
      'then source object is 12 lines': (topic) ->
        assert.equal topic.lines(), 12
      'and the source object has 5 lines of code': (topic) ->
        assert.equal topic.linesOfCode(), 5

  .export(module)

