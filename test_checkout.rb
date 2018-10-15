require_relative "checkout"
require_relative "product"
require "test/unit"

class TestCheckout < Test::Unit::TestCase
  def setup
    @curry_sauce = Product.new('001', 'Curry Sauce', 1.95)
    @pizza = Product.new('002', 'Pizza', 5.99)
    @men_shirt = Product.new('003', 'Men T-Shirt', 25)
  end

  def test_scan
    co = Checkout.new
    assert_equal(32.94, co.scan(@curry_sauce).scan(@pizza).scan(@men_shirt).total)
    co.reset!
    assert_equal(13.93, co.scan(@pizza).scan(@curry_sauce).scan(@pizza).total)
    assert_equal(38.93, co.scan(@men_shirt).total)
  end

  def test_products
    co = Checkout.new
    assert_equal([@curry_sauce, @pizza, @men_shirt], co.scan(@curry_sauce).scan(@pizza).scan(@men_shirt).products)
  end

  def test_absolute_discount
    co = Checkout.new(absolute_discount: 2)
    assert_equal(9.93, co.scan(@pizza).scan(@curry_sauce).scan(@pizza).total)
    # do not reduce cheap curry sauce but the pizza!
    co.reset!
    assert_equal(7.80, co.scan(@curry_sauce).scan(@curry_sauce).scan(@curry_sauce).scan(@curry_sauce).total)
    co.reset!
    assert_equal(11.88, co.scan(@pizza).scan(@curry_sauce).scan(@pizza).scan(@curry_sauce).total)
  end

  def test_relative_discount
    co = Checkout.new(relative_discount: 0.1)
    assert_equal(29.65, co.scan(@curry_sauce).scan(@pizza).scan(@men_shirt).total)
    co.reset!
    assert_equal(35.04, co.scan(@pizza).scan(@curry_sauce).scan(@pizza).scan(@men_shirt).total)
  end

  def test_discounts_together
    co = Checkout.new(absolute_discount: 2, relative_discount: 0.1)
    assert_equal(31.44, co.scan(@pizza).scan(@curry_sauce).scan(@pizza).scan(@men_shirt).total)
    # do not apply relative discount after absolute discount reduces under limit
    co = Checkout.new(absolute_discount: 6, relative_discount: 0.5, relative_discount_limit: 40)
    assert_equal(38, co.scan(@men_shirt).scan(@men_shirt).total)
  end

  def test_receipt
    co = Checkout.new(absolute_discount: 2, relative_discount: 0.1)
    receipt = "Thank you for buying in my shop.\n" +
              "I am so happy to receive your money.\n" +
              "You bought:\n" +
              "2 x Pizza for 7.98 €\n" +
              "Nice! You saved 4 € on your Pizzas!\n" +
              "1 x Curry Sauce for 1.95 €\n" +
              "1 x Men T-Shirt for 25 €\n" +
              "Cool! You saved 10%!\n" +
              "Total: 31.44 €"
    assert_equal(receipt, co.scan(@pizza).scan(@curry_sauce).scan(@pizza).scan(@men_shirt).receipt)
  end
end
