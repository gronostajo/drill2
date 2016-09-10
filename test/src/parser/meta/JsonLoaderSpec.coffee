describe 'JsonLoader', ->
  beforeEach ->
    module('DrillApp')
    jasmine.addMatchers(customMatchers)
    inject (@JsonLoader) ->

  it 'should throw on invalid input', ->
    expect(=> new @JsonLoader().load('wtf')).toThrow()

  it 'should parse valid input', ->
    result = new @JsonLoader(test: (v) -> v).load('{ "test": true }')
    expect(result.object.test).toBe(true)
    expect(result.unknown).toBeEmptyArray()

  it 'should use mappers', ->
    mappingResult = 'mappingResult'
    mapper = jasmine.createSpy().and.returnValue(mappingResult)
    result = new @JsonLoader(test: mapper).load('{ "test": true }')
    expect(mapper).toHaveBeenCalledWith(true, 'test', jasmine.any(Function))
    expect(result.object.test).toBe(mappingResult)
    expect(result.unknown).toBeEmptyArray()

  it 'should provide defaults for missing members', ->
    mappingResult = 'mappingResult'
    mapper = jasmine.createSpy().and.returnValue(mappingResult)
    result = new @JsonLoader(test: mapper).load('{}')
    expect(mapper).toHaveBeenCalledWith(undefined, 'test', jasmine.any(Function))
    expect(result.object.test).toBe(mappingResult)
    expect(result.unknown).toBeEmptyArray()

  it 'should report members without matching mappers', ->
    result = new @JsonLoader({}).load('{ "test": null }')
    expect(result.unknown).toBeArrayOfSize(1)
    expect(result.unknown[0]).toEqual('test')

  it 'should pass field name as second argument', ->
    mapper = jasmine.createSpy().and.returnValue('whatever')
    new @JsonLoader(test: mapper).load('{ "test": null }')
    expect(mapper).toHaveBeenCalledWith(null, 'test', jasmine.any(Function))

  it 'should handle compound results', ->
    referenceResult =
      field1: 'one'
      field2: 'two'
    mapper = jasmine.createSpy().and.returnValue(referenceResult)
    result = new @JsonLoader(test: mapper).load('{ "test": null }')
    expect(result.object.field1).toEqual('one')
    expect(result.object.field2).toEqual('two')
    for member of result.object
      expect(referenceResult).toHaveMember(member)
    expect(result.unknown).toBeEmptyArray()

  it 'should log exceptions', ->
    validSpy = jasmine.createSpy('validSpy').and.returnValue('valid')
    logSpy = jasmine.createSpy('logSpy')
    mappers =
      a_valid: validSpy
      invalid: -> throw new Error('test error')
      z_valid: validSpy
    new @JsonLoader(mappers).load('{"a_valid": true, "invalid": true, "z_valid": true}', logSpy)
    expect(validSpy.calls.count()).toBe(2)
    expect(logSpy).toHaveBeenCalled()

  it 'should throw for repeated members', ->
    mappers =
      a: -> dupe: yes
      b: -> dupe: yes
    expect =>
      new @JsonLoader(mappers).load('{"a": true, "b": true}')
    .toThrowError('Member dupe already exists')
