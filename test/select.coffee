expect = require('chai').expect
{ operandToAbstractSQLFactory, aliasFields, pilotFields } = require('./chai-sql')
operandToAbstractSQL = operandToAbstractSQLFactory()
test = require('./test')
_ = require 'lodash'

pilotName = _.filter(pilotFields, 2: 'name')[0]
pilotAge = _.filter(pilotFields, 2: 'age')[0]
test '/pilot?$select=name', (result) ->
	it 'should select name from pilot', ->
		expect(result).to.be.a.query.that.
			selects([
				pilotName
			]).
			from('pilot')

test '/pilot?$select=favourite_colour', (result) ->
	it 'should select favourite_colour from pilot', ->
		expect(result).to.be.a.query.that.
			selects(
				_.filter(pilotFields, 1: 'favourite_colour')
			).
			from('pilot')

test '/pilot(1)?$select=favourite_colour', (result) ->
	it 'should select from pilot with id', ->
		expect(result).to.be.a.query.that.
			selects(
				_.filter(pilotFields, 1: 'favourite_colour')
			).
			from('pilot').
			where(['Equals', ['ReferencedField', 'pilot', 'id'], ['Bind', 0]])

test "/pilot('TextKey')?$select=favourite_colour", (result) ->
	it 'should select from pilot with id', ->
		expect(result).to.be.a.query.that.
			selects(
				_.filter(pilotFields, 1: 'favourite_colour')
			).
			from('pilot').
			where(['Equals', ['ReferencedField', 'pilot', 'id'], ['Bind', 0]])


test '/pilot?$select=was_trained_by__pilot/name', (result) ->
	it 'should select name from pilot', ->
		expect(result).to.be.a.query.that.
			selects(aliasFields('pilot', [
				pilotName
			], 'was trained by')).
			from(
				'pilot'
				['pilot', 'pilot.was trained by-pilot']
			).
			where(
				['Equals', ['ReferencedField', 'pilot', 'was trained by-pilot'], ['ReferencedField', 'pilot.was trained by-pilot', 'id']]
			)

test '/pilot?$select=trained__pilot/name', (result) ->
	it 'should select name from pilot', ->
		expect(result).to.be.a.query.that.
			selects(aliasFields('pilot', [
				pilotName
			], 'trained')).
			from(
				'pilot'
				['pilot', 'pilot.trained-pilot']
			).
			where(
				['Equals', ['ReferencedField', 'pilot', 'id'], ['ReferencedField', 'pilot.trained-pilot', 'was trained by-pilot']]
			)

test '/pilot?$select=was_trained_by__pilot/name,trained__pilot/name', (result) ->
	it 'should select name from pilot', ->
		expect(result).to.be.a.query.that.
			selects(
				aliasFields('pilot', [
					pilotName
				], 'was trained by')
				.concat(
					aliasFields('pilot', [
						pilotName
					], 'trained')
				)
			).
			from(
				'pilot'
				['pilot', 'pilot.was trained by-pilot']
				['pilot', 'pilot.trained-pilot']
			).
			where(['And'
				['Equals', ['ReferencedField', 'pilot', 'was trained by-pilot'], ['ReferencedField', 'pilot.was trained by-pilot', 'id']]
				['Equals', ['ReferencedField', 'pilot', 'id'], ['ReferencedField', 'pilot.trained-pilot', 'was trained by-pilot']]
			])

test '/pilot?$select=trained__pilot/name,age', (result) ->
	it 'should select name, age from pilot', ->
		expect(result).to.be.a.query.that.
			selects(
				aliasFields('pilot', [
					pilotName
				], 'trained').concat([
					pilotAge
				])
			).
			from(
				'pilot'
				['pilot', 'pilot.trained-pilot']
			).
			where(
				['Equals', ['ReferencedField', 'pilot', 'id'], ['ReferencedField', 'pilot.trained-pilot', 'was trained by-pilot']]
			)


test '/pilot?$select=*', (result) ->
	it 'should select * from pilot', ->
		expect(result).to.be.a.query.that.
			selects(pilotFields).
			from('pilot')


test '/pilot?$select=licence/id', (result) ->
	it 'should select licence/id for pilots', ->
		expect(result).to.be.a.query.that.
			selects([
				operandToAbstractSQL('licence/id')
			]).
			from(
				'pilot'
				['licence', 'pilot.licence']
			).
			where(
				['Equals', ['ReferencedField', 'pilot', 'licence'], ['ReferencedField', 'pilot.licence', 'id']]
			)


test '/pilot?$select=can_fly__plane/plane/id', (result) ->
	it 'should select can_fly__plane/plane/id for pilots', ->
		expect(result).to.be.a.query.that.
			selects([
				operandToAbstractSQL('can_fly__plane/plane/id')
			]).
			from(
				'pilot'
				['pilot-can fly-plane', 'pilot.pilot-can fly-plane']
				['plane', 'pilot.pilot-can fly-plane.plane']
			).
			where(['And'
				['Equals', ['ReferencedField', 'pilot', 'id'], ['ReferencedField', 'pilot.pilot-can fly-plane', 'pilot']]
				['Equals', ['ReferencedField', 'pilot.pilot-can fly-plane', 'can fly-plane'], ['ReferencedField', 'pilot.pilot-can fly-plane.plane', 'id']]
			])
