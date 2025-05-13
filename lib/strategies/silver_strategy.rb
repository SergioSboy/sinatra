# frozen_string_literal: true

require_relative 'base_strategy'

class SilverStrategy < BaseStrategy
  def discount
    base = @template.discount.to_f / 100
    extra = @product&.type == 'discount' ? @product.value.to_f / 100 : 0
    amount * (base + extra)
  end

  def cashback
    base = @template.cashback.to_f / 100
    extra = @product&.type == 'increased_cashback' ? @product.value.to_f / 100 : 0
    amount * (base + extra)
  end
end
