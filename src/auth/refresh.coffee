postman = require './postman'
redirect = require './redirect'
cookies = require '../cookies'
headers = require './headers'
crypt = require './crypt'
_ = require 'underscore'

#todo: call backend for url composition
tryRefresh = (req, route) ->
    refreshQuery = 'grant_type=refresh_token&refresh_token=' + crypt.decrypt(cookies.parse(req)[route['cookie-name'] + '_rt'], route['client-secret'])
    postman.post refreshQuery, route

doRefresh = (result) ->
    headers.setAuthCookies @res, @route, result
    .then((reslt) =>
        redirect.refreshPage @req, reslt
    )

refreshError = (error) ->
    console.log error
    redirect.startAuthCode @req, @res, @route

module.exports =
    token: (req, res, route) ->
        newThis = {req: req, res: res, route: route}
        tryRefresh(req, route).then doRefresh.bind(newThis), refreshError.bind(newThis)