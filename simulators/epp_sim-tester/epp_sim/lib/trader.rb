require 'java'
require 'epp_sim'

#Log4r::Logger.new('trader')

module Trader
  class Trader
    attr_accessor :cash, :shares, :id, :pricing_strategy
    def initialize(id, cash, shares, pricing_strategy, private_information)
      @id, @cash, @shares = id, cash, shares
      @pricing_strategy, @private_information = pricing_strategy, private_information
    end

    def cash_value
      @pricing_strategy.calculate_value(cash, shares, @private_information.utility_function)
    end

    def receive_news(news); @pricing_strategy.process_news(news, @cash, @shares, @private_information.utility_function); end

    def submit_orders(order_book)
      @pricing_strategy.get_prices(@cash, @shares, @private_information.utility_function)
      get_buy_price_vector.each {|x|
        order_book.submit_buy(OrderBook::Order.new(self, x))
      }
      get_sell_price_vector.each {|x|
        order_book.submit_sell(OrderBook::Order.new(self, x))
      }
    end

    def get_buy_price_vector; @pricing_strategy.buy_price_vector; end

    def get_sell_price_vector; @pricing_strategy.sell_price_vector; end

    def asset_adjustment(adjustment); @shares += adjustment; end

    def cash_adjustment(adjustment); @cash += adjustment; end

    def resolve_trade(cash, is_buy)
      if is_buy
        cash_adjustment(-cash)
        asset_adjustment 1
      else
        cash_adjustment cash
        asset_adjustment(-1)
      end
    end

    def to_s
      "Trader #{@id}: cash=#{@cash}, shares=#{@shares}, pricing_strategy=#{@pricing_strategy.to_s}, private_information=#{@private_information.to_s}"
    end
  end

  class PrivateInformation
    attr_reader :variance_low, :variance_high, :utility_function

    def initialize(variance_low, variance_high, utility_function)
      @variance_low, @variance_high, @utility_function = variance_low, variance_high, utility_function
    end

    def to_s
      "[variance_low=#{variance_low}, variance_high=#{variance_high}, utility_function=#{utility_function.to_string}]"
    end
  end

end
