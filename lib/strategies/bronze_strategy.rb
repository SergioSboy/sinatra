# frozen_string_literal: true

require_relative 'base_strategy'

class BronzeStrategy < BaseStrategy
  def cashback
    rate = @product&.type == 'increased_cashback' ? @product.value.to_f / 100 : 0.01
    amount * rate
  end
end
