vows = require 'vows'
assert = require 'assert'
loc = require './loc'
Source = loc.Source
Line = loc.Line

BLOCKCOMMENTS = " /* this file has 2 lines of code */   \n
void main { /* start here  \n
 /* finish here */ } "

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

ONELINESOURCE = "public static final void main { }"

vows
  .describe("Count lines of code test")
  .addBatch
    'when creating a new source file':
      topic: -> 
        new Source ONELINESOURCE
      'then source object is not null': (topic) ->
        assert.isNotNull topic
        if debug? then console.log topic
      'and the source.array is not null': (topic) ->
        assert.isNotNull topic.array
      'and the source is 1 line long': (topic) ->
        assert.equal 1, topic.lines()
      'and the source has the correct content': (topic) ->
        assert.equal ONELINESOURCE, topic.array[0]

    'when testing a one line source':
      topic: ->
        new Line ONELINESOURCE
      'then hasCode should return 1': (topic) ->
        assert.equal 1, topic.hasCode()
      'and there is no transition': (topic) ->
        assert.isFalse topic.transition(false)
        assert.isFalse topic.transition(true)
 
    'when testing a single line comment':
      topic: ->
        new Line "   // one line comment "
      'then isAllOneLineComment returns true': (topic) ->
        assert.isTrue topic.isAllOneLineComment() 
      'and isBlank returns false': (topic) ->
        assert.isFalse topic.isBlank()
      'and there is no transition': (topic) ->
        assert.isFalse topic.transition(false)
        assert.isFalse topic.transition(true)
    
    'when testing a blank line':
      topic: ->
        new Line "   "
      'then isBlank returns true': (topic) ->
        assert.isTrue topic.isBlank() 
      'and hasCode returns 0': (topic) ->
        assert.equal 0, topic.hasCode()
      'and there is no transition': (topic) ->
        assert.isFalse topic.transition(false)
        assert.isFalse topic.transition(true)

    'when testing a one line block comment':
      topic: ->
        new Line " /* this file has 0 lines of code */  "
      'then isStartOfBlockComment returns true': (topic) ->
        assert.isTrue topic.isStartOfBlockComment() 
      'and isEndOfBlockComment returns true': (topic) ->
        assert.isTrue topic.isEndOfBlockComment() 
      'and hasNonWhitespaceAfterBlockCommentEnd returns 0': (topic) ->
        assert.equal 0, topic.hasNonWhitespaceAfterBlockCommentEnd()
      'and hasNonWhitespaceBeforeBlockCommentStart returns 0': (topic) ->
        assert.equal 0, topic.hasNonWhitespaceBeforeBlockCommentStart()
      'and there is a transition only from in to out of block': (topic) ->
        assert.isFalse topic.transition(false)
        assert.isTrue topic.transition(true)  

    'when testing a block comment start':
      topic: ->
        new Line "  /* // comment /"
      'then isStartOfBlockComment returns true': (topic) ->
        assert.isTrue topic.isStartOfBlockComment()
      'and hasNonWhitespaceBeforeBlockCommentStart is 0': (topic) ->
        assert.equal 0, topic.hasNonWhitespaceBeforeBlockCommentStart()
      'and there is a transition only from not in a block comment': (topic) ->
        assert.isTrue topic.transition(false)
        assert.isFalse topic.transition(true)

    'when testing a block comment start after code':
      topic: ->
        new Line "1 /* comment ends // 1"
      'then isStartOfBlockComment returns true': (topic) ->
        assert.isTrue topic.isStartOfBlockComment()
      'and hasNonWhitespaceBeforeBlockCommentStart is 1': (topic) ->
        assert.equal 1, topic.hasNonWhitespaceBeforeBlockCommentStart()
      'and there is a transition only from not in a block comment': (topic) ->
        assert.isTrue topic.transition(false)
        assert.isFalse topic.transition(true)

    'when testing a block comment end':
      topic: ->
        new Line "// comment ends */ //"
      'then isStartOfBlockComment returns true': (topic) ->
        assert.isTrue topic.isEndOfBlockComment()
      'and hasNonWhitespaceAfterBlockCommentEnd is 0': (topic) ->
        assert.equal 0, topic.hasNonWhitespaceAfterBlockCommentEnd()
      'and there is a transition only from in a block comment': (topic) ->
        assert.isFalse topic.transition(false)
        assert.isTrue topic.transition(true)
     
    'when testing a block comment end before code':
      topic: ->
        new Line "// comment ends */ 1"
      'then isStartOfBlockComment returns true': (topic) ->
        assert.isTrue topic.isEndOfBlockComment()
      'and hasNonWhitespaceAfterBlockCommentEnd is 1': (topic) ->
        assert.equal 1, topic.hasNonWhitespaceAfterBlockCommentEnd()
      'and there is a transition only from in a block comment': (topic) ->
        assert.isFalse topic.transition(false)
        assert.isTrue topic.transition(true)

    'when testing a block comment that starts and ends on the same line':
      topic: ->
        new Source BLOCKCOMMENTS
      'then the source object has 2 lines of code': (topic) ->
        assert.equal topic.linesOfCode(), 2 
  
    'when testing a simple source Java file with 3 lines':
      topic: ->
        source = new Source SIMPLESOURCE
      'then source object is 7 lines': (topic) ->
        assert.equal topic.lines(), 7
      'and the source object has 3 lines of code': (topic) ->
        assert.equal topic.linesOfCode(), 3

    'when testing a complex source Java file with 5 lines':
      topic: ->
        source = new Source COMPLEXSOURCE
      'then source object is 12 lines': (topic) ->
        assert.equal topic.lines(), 12
      'and the source object has 5 lines of code': (topic) ->
        assert.equal topic.linesOfCode(), 5

  .export(module)

