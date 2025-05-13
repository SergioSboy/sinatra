# lib/calculator.rb
require_relative "strategies/bronze_strategy"
require_relative "strategies/silver_strategy"
require_relative "strategies/gold_strategy"

def strategy_for(loyalty)
  case loyalty.downcase
  when "bronze" then BronzeStrategy
  when "silver" then SilverStrategy
  when "gold"   then GoldStrategy
  else BaseStrategy
  end
end

def calculate_order(user_id:, positions:)
  user = User[user_id]
  loyalty_name = user.template.name

  result = {
    total_before_discount: 0,
    total_discount: 0,
    total_after_discount: 0,
    bonuses_awarded: 0,
    positions: []
  }

  positions.each do |pos|
    product = Product[pos[:id]]
    strategy = strategy_for(loyalty_name).new(product, pos)

    full = strategy.full_price
    discount = strategy.discount
    cashback = strategy.cashback
    final = full - discount

    result[:positions] << {
      id: pos[:id],
      quantity: pos[:quantity],
      price: pos[:price],
      full_price: full.round(2),
      discount: discount.round(2),
      final_price: final.round(2),
      cashback: cashback.round(2)
    }

    result[:total_before_discount] += full
    result[:total_discount] += discount
    result[:total_after_discount] += final
    result[:bonuses_awarded] += cashback
  end

  result.each { |k, v| result[k] = v.round(2) if v.is_a?(Numeric) }
  result
end
