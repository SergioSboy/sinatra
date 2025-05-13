# frozen_string_literal: true

require_relative '../strategies/bronze_strategy'
require_relative '../strategies/silver_strategy'
require_relative '../strategies/gold_strategy'

class OrderCalculator
  attr_reader :user, :positions, :result

  def initialize(user:, positions:)
    @user = user
    @template = user.template
    @positions = positions
    @result = base_result
  end

  def call
    positions.each do |pos|
      position_data, full, discount, cashback, final = process_position(pos)
      result[:positions] << position_data
      result[:total_before_discount] += full
      result[:total_discount] += discount
      result[:amount] += final
      result[:bonuses][:cashback_amount] += cashback
    end

    finalize_result
    deep_round(result)
  end

  private

  def strategy_for(loyalty)
    case loyalty.downcase
    when 'bronze' then BronzeStrategy
    when 'silver' then SilverStrategy
    when 'gold'   then GoldStrategy
    else BaseStrategy
    end
  end

  def process_position(pos)
    product = Product[pos[:id]]
    strategy = strategy_for(@template.name).new(product, @template, pos)

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

  def finalize_result
    result[:discounts][:discount_amount] = result[:total_discount]
    result[:discounts][:discount_percent] =
      calculate_percent(result[:total_discount], result[:total_before_discount])

    result[:bonuses][:cashback_percent] =
      calculate_percent(result[:bonuses][:cashback_amount], result[:amount])

    result[:bonuses][:bonus_balance] = user.bonus.to_f
    result[:bonuses][:bonuses_available] = user.bonus.to_f
    result[:user_info] = {
      name: user.name,
      template_name: @template.name
    }
    result[:status] = 200
    result[:operation_id] = nil
  end

  def calculate_percent(part, total)
    return 0.0 if total.to_f.zero?

    (part.to_f / total) * 100
  end

  def base_result
    {
      total_before_discount: 0.0,
      total_discount: 0.0,
      amount: 0.0,
      bonuses: { cashback_amount: 0.0 },
      discounts: {},
      positions: []
    }
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
end
