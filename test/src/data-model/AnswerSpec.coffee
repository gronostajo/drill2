describe 'Answer', ->
  beforeEach ->
    module('DrillApp')
    jasmine.addMatchers(customMatchers)
    inject (@Answer) ->

  it 'should stringify into incorrect question', ->
    answer = new @Answer('incorrect', no, 'i')
    expect(answer.toString()).toEqual('  i) incorrect\n')

  it 'should stringify into correct question', ->
    answer = new @Answer('correct', yes, 'C')
    expect(answer.toString()).toEqual('> C) correct\n')
