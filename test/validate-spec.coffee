assert = require('assert')
sinon = require('sinon')
headers = require('../src/auth/headers')
postman = require('../src/auth/postman')
exchange = require('../src/auth/exchange')
validate = require('../src/auth/validate')
postmanMock = undefined

restore = (mockFunc) ->
    if mockFunc and mockFunc.restore
        mockFunc.restore()

describe 'validate', ->
    it 'resolves if no required validation', (done) ->
        req = {}
        route = {}
        route['require-auth'] = false
        validate.authentication(req, route).then ((auth) ->
            done()
        ), (auth) ->
            assert.fail 'auth failed!'
            done()
    it 'rejects if required validation but none sent', (done) ->
        req = headers: ''
        route = {}
        validate.authentication(req, route).then ((auth) ->
            assert.fail 'should have failed!'
            done()
        ), (auth) ->
            done()
    it 'resolves if bearer token found and valid', (done) ->
        req = headers: {}
        route = {}
        auth = id: 'myauth'
        req.headers.authorization = 'bearer abc'
        postmanMock = sinon.stub(postman, 'postAs', (query, client, secret) ->
            { then: (s, f) ->
                s auth
            }
        )
        validate.authentication(req, route).then ((returnedAuth) ->
            assert.equal auth, returnedAuth
            done()
        ), (auth) ->
            assert.fail 'failed!'
            done()
    it 'resolves if auth token found and valid', (done) ->
        req = headers: cookie: 'mycookie=abc'
        route = {}
        auth = id: 'myauth'
        route['cookie-name'] = 'mycookie'
        postmanMock = sinon.stub(postman, 'postAs', (query, client, secret) ->
            { then: (s, f) ->
                s auth
            }
        )
        validate.authentication(req, route).then ((returnedAuth) ->
            assert.equal auth, returnedAuth
            done()
        ), (auth) ->
            assert.fail 'failed!'
            done()
    it 'rejects if auth token found but invalid', (done) ->
        req = headers: cookie: 'mycookie=abc'
        route = {}
        auth = id: 'myauth'
        route['cookie-name'] = 'mycookie'
        validate.authentication(req, route).then ((returnedAuth) ->
            assert.fail 'should fail!'
            done()
        ), (auth) ->
            done()
    afterEach ->
        restore postmanMock