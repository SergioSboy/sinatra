require_relative "base_strategy"

class BronzeStrategy < BaseStrategy
  def cashback
    return 0 if @product&.type == "noloyalty"
    rate = @product&.type == "increased_cashback" ? @product.value.to_f / 100 : 0.01
    full_price * rate
  end
end
