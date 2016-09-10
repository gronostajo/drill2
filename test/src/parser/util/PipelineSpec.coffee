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
    result = pipeline.get()
    expect(result).toBeArrayOfSize(3)
    expect(result[0]).toEqual('A')
    expect(result[1]).toEqual('B')
    expect(result[2]).toEqual('C')

  it 'should fail when mapping a non-array', ->
    pipeline = new @Pipeline('non-array')
    expect ->
      pipeline.map((v) -> v)
    .toThrow()

  it 'should filter items if value is an array', ->
    pipeline = new @Pipeline([1, 2, 3, 4])
    pipeline.filter((n) -> n % 2 == 0)
    result = pipeline.get()
    expect(result).toBeArrayOfNumbers()
    expect(result.length).toBe(2)
    expect(result[0]).toBe(2)
    expect(result[1]).toBe(4)

  it 'should fail when filtering a non-array', ->
    pipeline = new @Pipeline('non-array')
    expect ->
      pipeline.filter((v) -> yes)
    .toThrow()

  it 'should chain methods', ->
    new @Pipeline(true)
    .apply((v) -> [v])
    .map((v) -> v)
    .filter(-> yes)
    .get()

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
    expect(pipeline.getLog()).toBeArrayOfSize(2)
    expect(pipeline.getLog()[0]).toEqual('test')
    expect(pipeline.getLog()[1]).toEqual('test2')

  it 'should log messages when filtering', ->
    pipeline = new @Pipeline([1, 2, 3, 4])
    pipeline.filter (n, logFn) ->
      logFn(n) if n % 2 isnt 0
      yes
    .filter (n, logFn) ->
      logFn(n) if n % 2 is 0
      no
    expect(pipeline.getLog()).toBeArrayOfSize(4)
    expect(pipeline.getLog()[0]).toBe(1)
    expect(pipeline.getLog()[1]).toBe(3)
    expect(pipeline.getLog()[2]).toBe(2)
    expect(pipeline.getLog()[3]).toBe(4)

  it 'should have independent logs for each instance', ->
    teeFunc = (value, logFn) ->
      logFn(value)
      value
    new @Pipeline([1, 2, 3]).filter(teeFunc)
    log = new @Pipeline([1, 2, 3]).filter(teeFunc).getLog()
    expect(log).toBeArrayOfSize(3)
