class BaseStrategy
  def initialize(product, position)
    @product = product
    @position = position
  end

  def full_price
    @position[:price] * @position[:quantity]
  end

  def discount
    0
  end

  def cashback
    0
  end
end
