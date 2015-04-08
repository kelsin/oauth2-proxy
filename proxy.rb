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
SECRET = ENV['SECRET']
COOKIE_SECRET = ENV['COOKIE_SECRET']

use Rack::SSL
use Rack::Session::Cookie, :secret => COOKIE_SECRET
use OmniAuth::Builder do
  provider :oauth2, CLIENT_ID, CLIENT_SECRET, :client_options => {
             :authorize_url => AUTHORIZE_URL,
             :token_url => TOKEN_URL },
           :scope => SCOPE
end

# Encryption Algorithm
alg = "AES-256-CBC"

# Generate key via SHA256
digest = Digest::SHA256.new
digest.update(SECRET)
key = digest.digest

def encrypt(str)
  aes = OpenSSL::Cipher::Cipher.new(alg)
  iv = aes.random_iv
  iv64 = Base64.urlsafe_encode64(iv)

  aes.encrypt
  aes.key = key
  aes.iv = iv

  cipher = aes.update(str) + aes.final

  { :cipher => Base64.urlsafe_encode64(cipher),
    :iv => iv64 }
end

def decrypt(bin64, iv64)
  aes = OpenSSL::Cipher::Cipher.new(alg)
  aes.decrypt
  aes.key = key
  aes.iv = Base64.urlsafe_decode64(iv)
  aes.update(Base64.urlsafe_decode64(bin64)) + aes.final
end

MISSING_AUTHORIZATION = 'Must provide Authorization header with encrypted token'
MISSING_PARAMS = 'Must provide both parameters in the Authorization header'
FORMAT = 'Authorization: token=<token> iv=<iv>'

get '/auth/:name/callback' do
  encrypted = encrypt(request.env['omniauth.auth']['credentials']['token'])

  query = { :token => encrypted[:cipher],
            :iv => encrypted[:iv],
            :expires_at => request.env['omniauth.auth']['credentials']['expires_at'] }

  redirect "#{REDIRECT_URL}##{Rack::Utils.build_query(query)}"
end

get '/*' do
  authorization = request.env['HTTP_AUTHORIZATION']
  unless authorization
    status 400
    headers 'Content-Type' => 'application/json'
    return {:error => MISSING_AUTHORIZATION,
            :format => FORMAT}.to_json
  end

  auth_params = {}
  authorization.split.each do |param|
    parts = param.split('=', 2)
    auth_params[parts[0]] = parts[1]
  end

  unless auth_params['token'] and auth_params['iv']
    status 400
    request.headers 'Content-Type' => 'application/json'
    return {:error => MISSING_PARAMS,
            :format => FORMAT}.to_json
  end

  token = decrypt(auth_params['token'], auth_params['iv'])

  res = Faraday.get do |req|
    req.headers['Authorization'] = "Bearer #{token}"
    req.url "#{API}#{request.path}"
    req.params = params.clone
  end

  status res.status
  headers res.headers
  res.body
end
