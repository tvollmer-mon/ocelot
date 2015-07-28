var url = require('url'),
    postman = require('./postman');

function tryCode (req, route) {
    var url_parts = url.parse(req.url, true);
    var query = url_parts.query;
    var code = query.code;
    var state = query.state;

    var redirectUrl = new Buffer(state, 'base64').toString('utf8');
    if (redirectUrl.indexOf('?') > -1) {
        redirectUrl = redirectUrl.substring(redirectUrl.indexOf('?'));
    }
    redirectUrl = redirectUrl + "/receive-auth-token";
    redirectUrl = encodeURIComponent(redirectUrl);

    var exchangeQuery = 'grant_type=authorization_code&code=' + code + '&redirect_uri=' + redirectUrl;

    return postman.post(exchangeQuery, route);
}

exports.code = function(req, res, route){
    tryCode(req, route).then(function (result) {
        var url_parts = url.parse(req.url, true);
        var query = url_parts.query;
        var state = query.state;
        var origUrl = new Buffer(state, 'base64').toString('utf8');
        res.setHeader('Location', origUrl);
        res.setHeader('Set-Cookie', [route.authentication['cookie-name'] + '=' + result.access_token, route.authentication['cookie-name'] + '_RT=' + result.refresh_token, route.authentication['oidc-cookie-name'] + '=' + result.id_token]);
        res.statusCode = 307;
        res.end();
    }, function (error) {
        console.log(error);
        res.statusCode = 500;
        res.end();
    });
};
