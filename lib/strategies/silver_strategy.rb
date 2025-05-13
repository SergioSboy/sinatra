require_relative "base_strategy"

class SilverStrategy < BaseStrategy
  def discount
    return 0 if @product&.type == "noloyalty"
    base = 0.03
    extra = @product&.type == "discount" ? @product.value.to_f / 100 : 0
    full_price * (base + extra)
  end

  def cashback
    return 0 if @product&.type == "noloyalty"
    base = 0.02
    extra = @product&.type == "increased_cashback" ? @product.value.to_f / 100 : 0
    full_price * (base + extra)
  end
end
