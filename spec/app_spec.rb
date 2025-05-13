# frozen_string_literal: true

# spec/app_spec.rb
require_relative '../app'
require 'rspec'
require 'rack/test'
require_relative '../db/models/operation'

RSpec.describe 'Sinatra App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe 'POST /calculate' do
    context 'пользователь - Silver' do
      context 'товар с дополнительной скидкой' do
        let(:json_body) do
          {
            user_id: 2,
            positions: [
              { id: 3, price: 500, quantity: 1 }
            ]
          }.to_json
        end

        it 'дает скидку' do
          post '/calculate', json_body, { 'CONTENT_TYPE' => 'application/json' }

          expect(last_response.status).to eq(200)

          body = JSON.parse(last_response.body)

          expect(body['status']).to eq(200)
          expect(body['user_info']).to include(
            'name' => 'Марина',
            'template_name' => 'Silver'
          )
          expect(body).to include('operation_id')
          expect(body['amount']).to eq(400)
          expect(body['bonuses']).to include(
            'bonus_balance' => 10_000.0,
            'bonuses_available' => 10_000.0,
            'cashback_percent' => 6.25,
            'cashback_amount' => 25.0
          )
          expect(body['discounts']).to include(
            'discount_amount' => 100,
            'discount_percent' => 20
          )
          expect(body['positions']).to be_an(Array)
          expect(body['positions'].first).to include(
            'id' => 3,
            'price' => 500,
            'quantity' => 1,
            'name' => 'Хлеб',
            'type' => 'discount',
            'percentage' => 15.0,
            'value' => 75
          )
        end
      end

      context 'товар с дополнительным кешбэком' do
        let(:json_body) do
          {
            user_id: 2,
            positions: [
              { id: 2, price: 500, quantity: 1 }
            ]
          }.to_json
        end

        it 'дает скидку и кэшбэк' do
          post '/calculate', json_body, { 'CONTENT_TYPE' => 'application/json' }

          expect(last_response.status).to eq(200)

          body = JSON.parse(last_response.body)

          expect(body['status']).to eq(200)
          expect(body['user_info']).to include(
            'name' => 'Марина',
            'template_name' => 'Silver'
          )
          expect(body).to include('operation_id')
          expect(body['amount']).to eq(475.0)
          expect(body['bonuses']).to include(
            'bonus_balance' => 10_000.0,
            'bonuses_available' => 10_000.0,
            'cashback_amount' => 75.0,
            'cashback_percent' => 15.79
          )
          expect(body['discounts']).to include(
            'discount_amount' => 25,
            'discount_percent' => 5.0
          )
          expect(body['positions']).to be_an(Array)
          expect(body['positions'].first).to include(
            'id' => 2,
            'price' => 500,
            'quantity' => 1,
            'name' => 'Молоко',
            'type' => 'increased_cashback',
            'percentage' => 10.0,
            'value' => 50.0
          )
        end
      end

      context 'товар без лояльности' do
        let(:json_body) do
          {
            user_id: 2,
            positions: [
              { id: 4, price: 500, quantity: 1 }
            ]
          }.to_json
        end

        it 'не дает скидку и кэшбэк' do
          post '/calculate', json_body, { 'CONTENT_TYPE' => 'application/json' }

          expect(last_response.status).to eq(200)

          body = JSON.parse(last_response.body)

          expect(body['status']).to eq(200)
          expect(body['user_info']).to include(
            'name' => 'Марина',
            'template_name' => 'Silver'
          )
          expect(body).to include('operation_id')
          expect(body['amount']).to eq(475.0)

          expect(body['bonuses']).to include(
            'bonus_balance' => 10_000.0,
            'bonuses_available' => 10_000.0,
            'cashback_amount' => 25.0,
            'cashback_percent' => 5.26
          )

          expect(body['discounts']).to include(
            'discount_amount' => 25.0,
            'discount_percent' => 5.0
          )

          expect(body['positions']).to be_an(Array)
          expect(body['positions'].first).to include(
            'id' => 4,
            'price' => 500,
            'quantity' => 1,
            'name' => 'Сахар',
            'type' => 'noloyalty',
            'percentage' => 0.0,
            'value' => 0.0
          )
        end
      end
    end

    context 'пользователь - Bronze' do
      context 'товар с дополнительной скидкой' do
        let(:json_body) do
          {
            user_id: 1,
            positions: [
              { id: 3, price: 500, quantity: 1 }
            ]
          }.to_json
        end

        it 'дает скидку' do
          post '/calculate', json_body, { 'CONTENT_TYPE' => 'application/json' }

          expect(last_response.status).to eq(200)
        end
      end

      context 'товар с дополнительным кешбэком' do
        let(:json_body) do
          {
            user_id: 2,
            positions: [
              { id: 2, price: 500, quantity: 1 }
            ]
          }.to_json
        end

        it 'дает скидку и кэшбэк' do
          post '/calculate', json_body, { 'CONTENT_TYPE' => 'application/json' }

          expect(last_response.status).to eq(200)
        end
      end

      context 'товар без лояльности' do
        let(:json_body) do
          {
            user_id: 2,
            positions: [
              { id: 4, price: 500, quantity: 1 }
            ]
          }.to_json
        end

        it 'дает скидку и кэшбэк' do
          post '/calculate', json_body, { 'CONTENT_TYPE' => 'application/json' }

          expect(last_response.status).to eq(200)
        end
      end
    end

    context 'пользователь - Gold' do
      context 'товар с дополнительной скидкой' do
        let(:json_body) do
          {
            user_id: 3,
            positions: [
              { id: 3, price: 500, quantity: 1 }
            ]
          }.to_json
        end

        it 'дает скидку' do
          post '/calculate', json_body, { 'CONTENT_TYPE' => 'application/json' }

          expect(last_response.status).to eq(200)
        end
      end

      context 'товар с дополнительным кешбэком' do
        let(:json_body) do
          {
            user_id: 3,
            positions: [
              { id: 2, price: 500, quantity: 1 }
            ]
          }.to_json
        end

        it 'дает скидку и кэшбэк' do
          post '/calculate', json_body, { 'CONTENT_TYPE' => 'application/json' }

          expect(last_response.status).to eq(200)
        end
      end

      context 'товар без лояльности' do
        let(:json_body) do
          {
            user_id: 3,
            positions: [
              { id: 4, price: 500, quantity: 1 }
            ]
          }.to_json
        end

        it 'дает скидку и кэшбэк' do
          post '/calculate', json_body, { 'CONTENT_TYPE' => 'application/json' }

          expect(last_response.status).to eq(200)
        end
      end
    end
  end

  describe 'POST /operations/:id/confirm' do
    let!(:user) do
      User.create(name: 'Марина', bonus: 10_000, template_id: 2)
    end

    let!(:operation) do
      Operation.create(
        user_id: user.id,
        cashback: 75.0,
        cashback_percent: 15.0,
        discount: 25.0,
        discount_percent: 5.0,
        write_off: 0,
        allowed_write_off: 300.0,
        done: false,
        check_summ: 500.0
      )
    end

    let(:json_body) do
      {
        user: { id: user.id },
        write_off: 200
      }.to_json
    end

    it 'подтверждает операцию и возвращает корректные данные' do
      post "/operations/#{operation.id}/confirm", json_body, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(200)

      body = JSON.parse(last_response.body)

      expect(body['status']).to eq('ok')
      expect(body['message']).to eq('Операция подтверждена')

      expect(body['operation']).to include(
        'user_id' => user.id,
        'earned_bonus' => 75.0,
        'total_cashback_percent' => 15.0,
        'total_discount' => 25.0,
        'total_discount_percent' => 5.0,
        'bonus_written_off' => 200.0,
        'final_amount' => 300.0
      )

      operation.reload
      expect(operation.write_off).to eq(200.0)
      expect(operation.check_summ).to eq(300.0)
      expect(operation.done).to eq(true)
    end
  end
end
