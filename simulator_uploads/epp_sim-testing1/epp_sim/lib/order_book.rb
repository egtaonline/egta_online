require 'epp_sim'

#Log4r::Logger.new('order_book')

module OrderBook
  class OrderBook
    def initialize(instrument)
      @instrument = instrument
      #@order_book_log = Logger['order_book']
      #@order_book_log.outputters = Outputter['pricing_info']
      @buy_orders = OrderLedger.new(true)
      @sell_orders = OrderLedger.new(false)
    end

    def to_s; "Buy Orders: "+@buy_orders.to_s + "\nSell Orders: "+ @sell_orders.to_s; end

    def remove_old_orders(trader)
      @buy_orders.remove_old_orders(trader)
      @sell_orders.remove_old_orders(trader)
    end

    def clear_ledgers
      @buy_orders = OrderLedger.new(true)
      @sell_orders = OrderLedger.new(false)
    end

    def submit_order(order, order_ledger, order_ledger_other)
      if yield([order.price, order_ledger.price]) == order.price
        if yield([order.price, order_ledger_other.price]) == order.price && !order_ledger_other.empty? && order.trader != order_ledger_other.top.trader
          process_match(order, order_ledger_other)
        else
          order_ledger.push order
        end
      else
        order_ledger.add_order order
      end
    end

    def submit_buy(order)
      #@order_book_log.debug order.to_s
      submit_order(order, @buy_orders, @sell_orders){|x| x.max}
    end

    def submit_sell(order)
      #@order_book_log.debug order.to_s
      submit_order(order, @sell_orders, @buy_orders){|x| x.min}
    end

    def process_match(new_order, order_ledger)
      @instrument.record_price(order_ledger.price)
      order_ledger.top.trader.resolve_trade(order_ledger.price, order_ledger.is_buy?)
      new_order.trader.resolve_trade(order_ledger.price, !order_ledger.is_buy?)
      order_ledger.remove_match
    end
  end

  class OrderLedger
    def initialize(is_buy)
      @ledger = []
      @is_buy = is_buy
    end

    def empty?
      @ledger.empty?
    end

    def push(order)
      @ledger.push order
    end

    def add_order(order)
      if @is_buy
        l = @ledger.each_index.detect{|i| @ledger[i].price < order.price}
        if l == nil
          @ledger.push order
        else
          @ledger.insert(l, order)
        end
      else
        l = @ledger.each_index.detect{|i| @ledger[i].price > order.price}
        if l == nil
          @ledger.push order
        else
          @ledger.insert(l, order)
        end
      end
    end

    def to_s
      return @ledger.to_s
    end

    def is_buy?; return @is_buy; end

    def sort!
      @ledger.sort!
      if @is_buy
        @ledger.reverse!
      end
      return @ledger
    end

    def top; return @ledger[0]; end

    def remove_match
      @ledger.delete_at 0
    end

    def remove_old_orders(trader)
      @ledger.reject!{|x| x.trader == trader}
    end

    def price
      if @ledger.empty?
        if @is_buy
          return 0
        else
          return 10000000000
        end
      else
        return @ledger[0].price
      end
    end
  end

  class Order
    attr_reader :trader
    attr_reader :price

    def initialize(trader, price)
      @trader = trader
      @price = price
    end

    def to_s; "Trader #{@trader.id}, price=#{@price}"; end

    def <=> x; self.price <=> x.price; end
  end
end
