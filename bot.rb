require 'eventmachine'
require 'sinatra'
require 'dotenv/load'

require_relative 'slack/websocket'
require_relative 'commands/responder'

Thread.new do
  EM.run do
  end
end

get '/' do
  if params.key?('connexion')
    "Team Successfully Registered"
  else
    send_file 'index.html'
  end
end

get '/oauth2callback' do
  if params.key?('error')
    redirect "/?access=denied"
  else
    ws = Slack::WebSocket.new(params['code']).call

    ws.on :open do
      p [:open]
    end

    ws.on :message do |event|
      Commands::Responder.new(data: event.data, websocket: ws).respond
    end

    ws.on :close do |event|
      p [:close, event.code, event.reason]
      ws = nil
      EM.stop
    end

    redirect "/?connexion=true"
  end
end
