require 'http'
require 'json'
require 'faye/websocket'
require 'eventmachine'
require 'sinatra'

require_relative 'commands/calculator'
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
    rc = JSON.parse(HTTP.post('https://slack.com/api/oauth.access', params: {
      client_id: ENV["SLACK_CLIENT_ID"],
      client_secret: ENV["SLACK_CLIENT_SECRET"],
      code: params['code']
    }))

    token = rc['bot']['bot_access_token']

    rc = JSON.parse(HTTP.post('https://slack.com/api/rtm.start', params: {
      token: token
    }))

    url = rc['url']

    ws = Faye::WebSocket::Client.new(url)

    ws.on :open do
      p [:open]
    end

    ws.on :message do |event|
      data = JSON.parse(event.data)
      p [:message, JSON.parse(event.data)]
      if data['type'] == 'message' && data['text'].start_with?('=')
        result = Commands::Calculator.new.evaluate(data['text']).to_s
        response = Commands::Responder.new.respond(result)

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
