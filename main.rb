require 'uri'
require 'net/http'
require 'json'
require 'sinatra'

set :port, 5000
set :bind, '0.0.0.0'
set :public_folder, 'public'
set :protection, except: :frame_options

def fetch_weather(query)
  # our weather api
  url1 = "http://api.openweathermap.org/data/2.5/weather?"
  url2 = "&appid=#{ENV['weather_api']}&units=imperial"
  api_url = url1 + query + url2
  uri = URI(api_url)
  res = Net::HTTP.get_response(uri)
  # return weather or empty JSON
  return JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
  return {}
end

def numeric?(lookAhead)
  # test if numeric
  lookAhead.match?(/[[:digit:]]/)
end

def letter?(lookAhead)
  # test if alpha
  lookAhead.match?(/[[:alpha:]]/)
end

get "/" do
  args = params[:args].to_s
  
  if numeric?(args)
    # user gave a zipcode
    query = "zip=#{args}"
  elsif letter?(args)
    # user gave a location
    query = "q=#{args}"
  else
    # something else
    query = "q=Chicago"
  end

  @weather = fetch_weather(query)
  # if query was bad, it returns a {}

  erb :weather
end
