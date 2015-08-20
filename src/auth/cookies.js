var _ = require('underscore');

exports.set = function (res, route, authentication) {

    //todo: hash incoming ip address along with cookie

    var cookieArray = [route['cookie-name'] + '=' + authentication.access_token,
        route['cookie-name'] + '_RT=' + authentication.refresh_token];

    var cookiePath = route['cookie-path'] || ("/" + route.route);
    cookieArray = _.map(cookieArray, function (item) {
        return item + "; path=" + cookiePath;
    });

    res.setHeader('Set-Cookie', cookieArray);
};