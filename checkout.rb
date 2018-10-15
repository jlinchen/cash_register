class Checkout
  attr_accessor :products, :absolute_discount, :absolute_discount_limit, :relative_discount, :relative_discount_limit

  def initialize(absolute_discount: nil, absolute_discount_limit: 2, relative_discount: nil, relative_discount_limit: 30)
    @products = []
    @absolute_discount = absolute_discount
    @absolute_discount_limit = absolute_discount_limit
    @relative_discount = relative_discount
    @relative_discount_limit = relative_discount_limit
  end

  def scan(product)
    # beep
    products << product
    return self
  end

  def reset!
    @products = []
    return self
  end

  def total
    # first apply absolute discount then check if total is still above
    if apply_relative_discount?
      (1 - relative_discount) * total_after_absolute_discount
    else
      total_after_absolute_discount
    end.round(2)
  end

  def receipt
    # katsching
    receipt = "Thank you for buying in my shop.\nI am so happy to receive your money.\nYou bought:\n"
    products.uniq.each do |product|
      count = products.count(product)
      receipt.concat("#{count} x #{product.name} for #{count * product_price(product)} €\n")
      receipt.concat("Nice! You saved #{count * absolute_discount} € on your #{product.name}s!\n") if apply_absolute_discount_to?(product)
    end
    receipt.concat("Cool! You saved #{(100 * relative_discount).round}%!\n") if apply_relative_discount?
    receipt.concat("Total: #{total} €")
  end

  private

  def total_after_absolute_discount
    products.map { |product| product_price(product) }.reduce(0, :+).round(2)
  end

  def product_price(product)
    if apply_absolute_discount_to?(product)
      product.price - absolute_discount
    else
      product.price
    end
  end

  def apply_absolute_discount_to?(product)
    # do not reduce the price, if the product is too cheap :D (at least double the discount)
    !absolute_discount.nil? && products.count(product) >= absolute_discount_limit && product.price >= 2 * absolute_discount
  end

  def apply_relative_discount?
    !relative_discount.nil? && total_after_absolute_discount >= relative_discount_limit
  end
end
