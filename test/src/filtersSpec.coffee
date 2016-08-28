describe 'bankersPercentageOfFilter', ->
  beforeEach ->
    module('DrillApp')
    inject (bankersPercentageOfFilter) ->
      @filter = bankersPercentageOfFilter

  it 'should leave integers unchanged', ->
    expect(@filter(0, 100)).toEqual('0%')
    expect(@filter(1, 100)).toEqual('1%')
    expect(@filter(2, 100)).toEqual('2%')
    expect(@filter(10, 100)).toEqual('10%')
    expect(@filter(13, 100)).toEqual('13%')
    expect(@filter(-10, 100)).toEqual('-10%')

  it 'should round halves to nearest even integer', ->
    expect(@filter(0.5, 100)).toEqual('0%')
    expect(@filter(1.5, 100)).toEqual('2%')
    expect(@filter(10.5, 100)).toEqual('10%')
    expect(@filter(11.5, 100)).toEqual('12%')
    expect(@filter(12.5, 100)).toEqual('12%')
    expect(@filter(87.5, 100)).toEqual('88%')
    expect(@filter(-10.5, 100)).toEqual('-10%')
    expect(@filter(-11.5, 100)).toEqual('-12%')

  it 'should round quarters to nearest integer', ->
    expect(@filter(0.25, 100)).toEqual('0%')
    expect(@filter(1.75, 100)).toEqual('2%')
    expect(@filter(10.25, 100)).toEqual('10%')
    expect(@filter(11.75, 100)).toEqual('12%')
    expect(@filter(-10.25, 100)).toEqual('-10%')
    expect(@filter(-11.75, 100)).toEqual('-12%')

  it 'should round .99 to nearest integer', ->
    expect(@filter(0.99, 100)).toEqual('1%')
    expect(@filter(1.01, 100)).toEqual('1%')
    expect(@filter(10.99, 100)).toEqual('11%')
    expect(@filter(11.01, 100)).toEqual('11%')
    expect(@filter(-10.99, 100)).toEqual('-11%')
    expect(@filter(-11.01, 100)).toEqual('-11%')
