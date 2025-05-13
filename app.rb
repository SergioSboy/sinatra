# frozen_string_literal: true

# app.rb
require 'sinatra'
require "json"
require_relative 'db/db'
require_relative 'db/models/user'
require_relative 'db/models/template'
require_relative 'db/models/product'
require_relative "lib/calculator"

post '/calculate' do
  content_type :json

  data = JSON.parse(request.body.read, symbolize_names: true)

  user_id = data[:user_id]
  positions = data[:positions]

  result = calculate_order(user_id: user_id, positions: positions)
  result.to_json
end
