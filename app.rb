# frozen_string_literal: true

# app.rb
require 'sinatra'
require 'json'
require_relative 'db/db'
require_relative 'db/models/user'
require_relative 'db/models/template'
require_relative 'db/models/product'
require_relative 'lib/services/order_calculator'
require_relative 'lib/services/operation_confirmation_service'

post '/calculate' do
  content_type :json

  begin
    data = JSON.parse(request.body.read, symbolize_names: true)

    user = User[data[:user_id]]
    halt 404, { error: 'User not found' }.to_json unless user

    positions = data[:positions]

    result = OrderCalculator.new(user: user, positions: positions).call

    result.to_json
  rescue JSON::ParserError
    halt 400, { error: 'Invalid JSON' }.to_json
  rescue StandardError => e
    halt 500, { error: 'Internal server error', message: e.message }.to_json
  end
end

post '/operations/:id/confirm' do
  content_type :json

  begin
    data = JSON.parse(request.body.read, symbolize_names: true)

    result = OperationConfirmationService.new(
      user_id: data[:user][:id],
      operation_id: params[:id],
      write_off: data[:write_off]
    ).call

    result.to_json
  rescue JSON::ParserError
    halt 400, { error: 'Invalid JSON' }.to_json
  rescue StandardError => e
    puts e.message
    halt 500, { error: 'Server error', message: e.message }.to_json
  end
end
