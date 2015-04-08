require 'sinatra'
require 'omniauth'
require 'omniauth-oauth2'
require 'rack/ssl'
require 'json'
require 'digest/sha2'
require 'openssl'
require 'base64'
require 'rack'

# These variables should all be set in your environment
API = ENV['API']
CLIENT_ID = ENV['CLIENT_ID']
CLIENT_SECRET = ENV['CLIENT_SECRET']
REDIRECT_URL = ENV['REDIRECT_URL']
AUTHORIZE_URL = ENV['AUTHORIZE_URL']
TOKEN_URL = ENV['TOKEN_URL']
SCOPE = ENV['SCOPE']
KEY = ENV['KEY']

use Rack::SSL
use Rack::Session::Cookie
use OmniAuth::Builder do
  provider :oauth2, CLIENT_ID, CLIENT_SECRET, :client_options => {
             :authorize_url => AUTHORIZE_URL,
             :token_url => TOKEN_URL,
             :scope => SCOPE }
end

# Encryption Algorithm
alg = "AES-256-CBC"

# Generate key via SHA256
digest = Digest::SHA256.new
digest.update(KEY)
key = digest.digest

get '/auth/:name/callback' do
  iv = OpenSSL::Cipher::Cipher.new(alg).random_iv
  iv64 = Base64.encode64(iv)

  aes = OpenSSL::Cipher::Cipher.new(alg)
  aes.encrypt
  aes.key = key
  aes.iv = iv

  # Now we go ahead and encrypt our plain text.
  token = aes.update(request.env['omniauth.auth']['credentials']['token']) + aes.final
  token64 = Base64.encode64(token)

  query = { :token => token64,
            :iv => iv64,
            :expires_at => request.env['omniauth.auth']['credentials']['expires_at'] }
  redirect "#{REDIRECT_URL}##{Rack::Utils.build_query(query)}"
end

MISSING_AUTHORIZATION = 'Must provide Authorization header with encrypted token'
MISSING_PARAMS = 'Must provide both parameters in the Authorization header'
FORMAT = 'Authorization: token=<token> iv=<iv>'

get '/test' do
  headers 'Content-Type' => 'application/json'
  return request.env.to_json
end

get '/headers' do
  output = headers.to_json
  headers 'Content-Type' => 'application/json'
  return output
end

get '/*' do
  authorization = request.env['HTTP_AUTHORIZATION']
  unless authorization
    status 400
    headers 'Content-Type' => 'application/json'
    return {:error => MISSING_AUTHORIZATION,
            :format => FORMAT}.to_json
  end

  params = {}
  authorization.split.each do |param|
    parts = param.split('=', 2)
    params[parts[0]] = parts[1]
  end

  unless params['token'] and params['iv']
    status 400
    request.headers 'Content-Type' => 'application/json'
    return {:error => MISSING_PARAMS,
            :format => FORMAT}.to_json
  end

  aes = OpenSSL::Cipher::Cipher.new(alg)
  aes.decrypt
  aes.key = key
  aes.iv = Base64.decode64(params['iv'])
  token = aes.update(Base64.decode64(params['token'])) + aes.final

  res = Faraday.get do |req|
    req.headers['Authorization'] = "Bearer #{token}"
    req.url "#{API}#{request.path}"
    req.params = params.clone
  end

  status res.status
  headers res.headers
  res.body
end
