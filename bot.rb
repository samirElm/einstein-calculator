require 'eventmachine'
require 'dotenv/load'
require 'sinatra'

require_relative 'slack/websocket'
require_relative 'commands/calculator'

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
      data = JSON.parse(event.data)
      p [:message, JSON.parse(event.data)]
      if data['type'] == 'message' && data['text'].start_with?('=')
        response = Commands::Calculator.new.evaluate(data['text']).to_s

        ws.send({ type: 'message', text: response, channel: data['channel'] }.to_json)
      elsif data['type'] == 'message'
        response = "J'ai rien compris et inutile d'essayer la commande `help`, elle n'existe pas."
        ws.send({ type: 'message', text: response, channel: data['channel'] }.to_json)
      end
    end

    ws.on :close do |event|
      p [:close, event.code, event.reason]
      ws = nil
      EM.stop
    end

    redirect "/?connexion=true"
  end
end
