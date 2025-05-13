require_relative "base_strategy"

class GoldStrategy < BaseStrategy
  def discount
    return 0 if @product&.type == "noloyalty"
    base = 0.05
    extra = @product&.type == "discount" ? @product.value.to_f / 100 : 0
    full_price * (base + extra)
  end
end
