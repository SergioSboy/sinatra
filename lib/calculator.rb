# frozen_string_literal: true

require_relative 'strategies/bronze_strategy'
require_relative 'strategies/silver_strategy'
require_relative 'strategies/gold_strategy'

def strategy_for(loyalty)
  case loyalty.downcase
  when 'bronze' then BronzeStrategy
  when 'silver' then SilverStrategy
  when 'gold'   then GoldStrategy
  else BaseStrategy
  end
end

def process_position(pos, template)
  product = Product[pos[:id]]
  strategy = strategy_for(template.name).new(product, template, pos)

  full = strategy.amount
  discount = strategy.discount
  cashback = strategy.cashback
  final = full - discount

  position_data = {
    id: pos[:id],
    quantity: pos[:quantity],
    price: pos[:price],
    name: product.name,
    type: product.type,
    percentage: product.value.to_f,
    value: pos[:price] * (product.value.to_f / 100.0)
  }

  [position_data, full, discount, cashback, final]
end

def calculate_order(user_id:, positions:)
  user = User[user_id]
  template = user.template

  result = {
    total_before_discount: 0.0,
    total_discount: 0.0,
    amount: 0.0,
    bonuses: { cashback_amount: 0.0 },
    discounts: {},
    positions: []
  }

  positions.each do |pos|
    position_data, full, discount, cashback, final = process_position(pos, template)

    result[:positions] << position_data
    result[:total_before_discount] += full
    result[:total_discount] += discount
    result[:amount] += final
    result[:bonuses][:cashback_amount] += cashback
  end

  result[:discounts][:discount_amount] = result[:total_discount]
  result[:discounts][:discount_percent] =
    calculate_discount_percent(result[:total_before_discount], result[:total_discount])
  result[:bonuses][:cashback_percent] = calculate_cashback_percent(result[:amount], result[:bonuses][:cashback_amount])

  deep_round(result)
end

def deep_round(data, precision = 2)
  case data
  when Hash
    data.transform_values { |v| deep_round(v, precision) }
  when Array
    data.map { |v| deep_round(v, precision) }
  when Numeric
    data.round(precision)
  else
    data
  end
end

def calculate_discount_percent(total_before, total_discount)
  return 0.0 if total_before.zero?

  (total_discount / total_before) * 100
end

def calculate_cashback_percent(amount, cashback)
  return 0.0 if amount.zero?

  (cashback / amount) * 100
end
