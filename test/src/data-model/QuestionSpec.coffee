# coffeelint: disable=no_unnecessary_double_quotes
# because it doesn't work properly with block strings

describe 'Question', ->
  beforeEach ->
    module('DrillApp')
    jasmine.addMatchers(customMatchers)
    inject (@Question) ->

  it 'should stringify into question without ID', ->
    question = new @Question('body')
    question.addAnswer('incorrect', no, 'i')
    question.addAnswer('correct', yes, 'C')
    expect(question.toString()).toEqual """
                                        body
                                          i) incorrect
                                        > C) correct

                                        """

  it 'should stringify into question with ID', ->
    question = new @Question('body', 'id')
    question.addAnswer('correct', yes, 'C')
    question.addAnswer('incorrect', no, 'i')
    expect(question.toString()).toEqual """
                                        [#id] body
                                        > C) correct
                                          i) incorrect

                                        """

  it 'should stringify into question with multi-line body', ->
    question = new @Question('body\nmore body\neven more body')
    question.addAnswer('incorrect', no, 'i')
    question.addAnswer('correct', yes, 'C')
    expect(question.toString()).toEqual """
                                        body
                                        more body
                                        even more body
                                          i) incorrect
                                        > C) correct

                                        """

  it 'should stringify into question without answers', ->
    question = new @Question('body')
    question.addAnswer('incorrect', no, 'i')
    question.addAnswer('correct', yes, 'C')
    expect(question.toString(no)).toEqual """
                                        body

                                        """
