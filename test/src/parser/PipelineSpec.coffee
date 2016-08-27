describe 'Pipeline', ->
  beforeEach ->
    module('DrillApp')
    inject (@Pipeline) ->

  it 'should return untouched data', ->
    input = new Object()
    pipeline = new @Pipeline(input)
    expect(pipeline.get()).toBe(input)

  it 'should apply single function', ->
    pipeline = new @Pipeline('abc')
    pipeline.apply((s) -> s.toUpperCase())
    expect(pipeline.get()).toEqual('ABC')

  it 'should apply multiple functions', ->
    pipeline = new @Pipeline('abc')
    pipeline.apply((s) -> s.toUpperCase())
    pipeline.apply((s) -> s + 'xyz')
    expect(pipeline.get()).toEqual('ABCxyz')

  it 'should map items if value is an array', ->
    pipeline = new @Pipeline(['a', 'b', 'c'])
    pipeline.map((s) -> s.toUpperCase())
    expect(pipeline.get()).toEqual(['A', 'B', 'C'])

  it 'should fail if mapping a non-array', ->
    pipeline = new @Pipeline('non-array')
    expect ->
      pipeline.map((v) -> v)
    .toThrow()

  it 'should chain methods', ->
    new @Pipeline(true).apply((v) -> [v]).map((v) -> v).get()

  it 'should have empty log after successful parsing', ->
    pipeline = new @Pipeline('a')
    pipeline.apply((s) -> s.toUpperCase())
    pipeline.get()
    expect(pipeline.getLog().length).toBe(0)

  it 'should log messages when applying', ->
    pipeline = new @Pipeline('asd')
    pipeline.apply (v, logFn) ->
      logFn('test')
      v
    .apply (v, logFn) ->
      logFn('test2')
      v
    expect(pipeline.getLog().length).toBe(2)
    expect(pipeline.getLog()[0]).toEqual('test')
    expect(pipeline.getLog()[1]).toEqual('test2')

  it 'should log messages when mapping', ->
    pipeline = new @Pipeline(['asd'])
    pipeline.map (v, logFn) ->
      logFn('test')
      v
    .map (v, logFn) ->
      logFn('test2')
      v
    expect(pipeline.getLog().length).toBe(2)
    expect(pipeline.getLog()[0]).toEqual('test')
    expect(pipeline.getLog()[1]).toEqual('test2')
