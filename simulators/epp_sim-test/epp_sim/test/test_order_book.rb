#!/Users/bcassell/.rvm/rubies/jruby-1.5.1/bin/jruby
require "test/unit"
require "epp_sim"

class OrderBookTest < Test::Unit::TestCase
  
  def test_submit_order
    order_book = OrderBook::OrderBook.new
    t1 = Trader::Trader.new(1, 0, 1, nil, nil)
    t2 = Trader::Trader.new(2, 0, 1, nil, nil)
    t3 = Trader::Trader.new(3, 0, 1, nil, nil)
    o1 = OrderBook::Order.new(t1, 34)
    order_book.submit_buy(o1)
    o2 = OrderBook::Order.new(t2, 30)
    order_book.submit_sell(o2)
    assert t1.cash == -34
    assert t1.shares == 2
    assert t2.cash == 34
    assert t2.shares == 0
    order_book.submit_buy(OrderBook::Order.new(t1, 31))
    order_book.submit_buy(OrderBook::Order.new(t1, 30))
    order_book.submit_sell(OrderBook::Order.new(t2, 29))
    assert t1.cash == -65
    assert t1.shares == 3
    assert t2.cash == 65
    assert t2.shares == -1
    order_book.submit_sell(OrderBook::Order.new(t3, 25))
    order_book.submit_buy(OrderBook::Order.new(t3, 26))
    assert t3.cash == 30
    assert t3.shares == 0
  end
  
end