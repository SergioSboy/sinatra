# spec/app_spec.rb
require_relative "../app"
require "rspec"
require "rack/test"

RSpec.describe "Sinatra App" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe "POST /calculate" do
    let(:json_body) do
      {
        user_id: 2,
        positions: [
          { id: 2, price: 1000, quantity: 2 },
          { id: 3, price: 500, quantity: 1 }
        ]
      }.to_json
    end

    it "returns 200" do
      post "/calculate", json_body, { "CONTENT_TYPE" => "application/json" }

      expect(last_response.status).to eq(200)

      body = JSON.parse(last_response.body)

      expect(body).to include("total_before_discount", "total_after_discount", "bonuses_awarded")
      expect(body["positions"]).to be_an(Array)
      expect(body["positions"].first).to include("id", "final_price", "discount", "cashback")
    end

    it "продукт без скидок и кешбэка" do
      post "/calculate", {
        user_id: 2,
        positions: [{ id: 4, price: 500, quantity: 1 }]
      }.to_json, { "CONTENT_TYPE" => "application/json" }

      expect(last_response.status).to eq(200)
      body = JSON.parse(last_response.body)
      pos = body["positions"].first

      expect(pos["discount"]).to eq(0.0)
      expect(pos["cashback"]).to eq(0.0)
    end
  end
end
