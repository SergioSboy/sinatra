# frozen_string_literal: true

# app.rb
require 'sinatra'
require 'json'
require_relative 'db/db'
require_relative 'db/models/user'
require_relative 'db/models/template'
require_relative 'db/models/product'
require_relative 'lib/services/order_calculator'

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

    operation = Operation[params[:id]]
    halt 404, { error: 'Operation not found' }.to_json unless operation

    user_data = data[:user]
    user = User[user_data[:id]]
    halt 400, { error: 'Invalid user' }.to_json unless user

    write_off = data[:write_off].to_f

    full_price  = operation.total_before_discount.to_f
    discount    = operation.total_discount.to_f
    cashback    = operation.bonuses_awarded.to_f
    to_pay      = operation.total_after_discount.to_f

    actual_write_off = [write_off, to_pay].min
    final_amount = to_pay - actual_write_off

    result = {
      status: 'ok',
      message: 'Операция подтверждена',
      operation: {
        user_id: user.id,
        earned_bonus: cashback.round(2),
        total_cashback_percent: to_pay.zero? ? 0.0 : (cashback / to_pay).round(4),
        total_discount: discount.round(2),
        total_discount_percent: full_price.zero? ? 0.0 : (discount / full_price).round(4),
        bonus_written_off: actual_write_off.round(2),
        final_amount: final_amount.round(2)
      }
    }

    result.to_json
  rescue JSON::ParserError
    halt 400, { error: 'Invalid JSON' }.to_json
  rescue StandardError => e
    halt 500, { error: 'Internal server error', message: e.message }.to_json
  end
end
