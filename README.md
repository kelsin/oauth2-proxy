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

## Steps

### US Battle.net API

1. Register on https://dev.battle.net and generate an account. You can leave the
   `Register Callback URL` field blank for now.
2. Click the Heroku deploy button above and fill in your `CLIENT_ID` and
   `CLIENT_SECRET` with the data from your https://dev.battle.net account (Key
   and Secret). Put your front end app's url as the `REDIRECT_URL`. Whatever url
   you put here will have `#token=<token>&iv=<iv>` appended to it after login.
3. Make note of your heroku app url and add it to your https://dev.battle.net
   account as the `Register Callback URL` with `/auth/oauth2/callback` as the
   path. For example, if your heroku app is named `sample-app` then the callback
   url shoudl be `https://sample-app.herokuapp.com/auth/oauth2/callback`.
4. When you want your users to login to the Battle.net API redirect them to
`<your herouku app>/auth/oauth2`.
5. When we redirect the user back to your app save the token and iv values.
6. When you need to make an API call make it to `<your heroku
   app>/rest/of/the/api/call` and include an `Authorization` header in the form
   of `Authorization: token=<token> iv=<iv>`

## Configuration Variables

These are the configuration variables that this proxy needs to run. If you want
to use the US Battle.net API and use the Heroku deploy button above, you only
need to setup the **BOLDED** ones.

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
