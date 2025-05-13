# frozen_string_literal: true

class BaseStrategy
  def initialize(product, template, position)
    @product = product
    @template = template
    @position = position
  end

  def amount
    @position[:price] * @position[:quantity]
  end

  def discount
    0
  end

  def cashback
    0
  end
end
