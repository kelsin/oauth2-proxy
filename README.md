# OAuth2 Proxy

A simple heroku-ready app for proxying oauth requests for front end only
apps. This is a reference implementation of the ideas presented by
[Alex Bilbie](http://alexbilbie.com/) in his blog post:
[OAuth and Single Page JavaScript Web-Apps](http://alexbilbie.com/2014/11/oauth-and-javascript/).

This proxy should work with any OAuth2 enabled API that accepts Bearer tokens
and supports the authorization_code login flow.

The easiest way to get started with this proxy is to deploy it to a free heroku
instance using the button below. This button will setup most of the required
variables with defaults to use the
[US Battle.net API](https://dev.battle.net/). It's easy to change from these
defaults if you need to. If you do want to use this proxy for the Battle.net
APIs than you only need to add in your `CLIENT_ID`, `CLIENT_SECRET` and
`REDIRECT_URL`.

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

## Configuration Variables

Variable | Description | Battle.net API Default
-------|----------|-----------------
API | The base url of the API to proxy to | `https://us.api.battle.net`
**CLIENT_ID** | Your OAuth2 Client ID for the proxied API | This is listed as your `Key` in your https://dev.battle.net account
**CLIENT_SECRET** | Your OAuth2 Client Secret for the proxied API | This is listed as your `Secret` in your https://dev.battle.net account
**REDIRECT_URL** | This is the URL that this proxy will redirect to after login. It should **not** include the `#` symbol. | This is where your app is hosted, .i.e `http://myawesomeapp.com`
AUTHORIZE_URL | This is the OAuth2 authorize url for the proxied API | `https://us.battle.net/oauth/authorize`
TOKEN_URL | This is the OAuth2 token url for the proxied API | `https://us.battle.net/oauth/token`
SCOPE | These are the scopes to request for your OAuth2 access token | `wow.profile sc2.profile`
SECRET | This is the secret key used to encrypt your access token | This is automatically generated for you by Heroku
COOKIE_SECRET | This is the secret key used to encrypt your session cookie during login | This is automatically generated for you by Heroku
