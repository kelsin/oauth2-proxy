require 'sinatra'
require 'omniauth'
require 'omniauth-oauth2'
require 'rack/ssl'

# These variables should all be set in your environment
CLIENT_ID = ENV['CLIENT_ID']
CLIENT_SECRET = ENV['CLIENT_SECRET']
REDIRECT_URL = ENV['REDIRECT_URL']
AUTHORIZE_URL = ENV['AUTHORIZE_URL']
TOKEN_URL = ENV['TOKEN_URL']
SCOPE = ENV['SCOPE']

use Rack::SSL
use Rack::Session::Cookie
use OmniAuth::Builder do
  provider :oauth2, CLIENT_ID, CLIENT_SECRET, :client_options => {
             :authorize_url => AUTHORIZE_URL,
             :token_url => TOKEN_URL,
             :scope => SCOPE }
end

post '/auth/:name/callback' do
  request.env['omniauth.auth'].inspect
end

get '/*' do
  "Hello World!"
end
