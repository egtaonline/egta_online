require 'java'
require 'order_book'
require 'trader'
require 'pricing_strategies'
require 'instrumentation'

class Array
  def shuffle!
    each_index do |i|
      j = rand(length-i) + i
      self[j], self[i] = self[i], self[j]
    end
  end

  def shuffle
    dup.shuffle!
  end
end

module Simulator
  class ProfileSimulator
    attr_reader :instrument
    def initialize(profile, simulation_schema)
      @instrument = EquityPremiumInstrumentation.new(simulation_schema["interest rate"], simulation_schema["quarters"], YAML_LOGGER)
      @profile = profile
      @simulation_schema = simulation_schema
      @simulation_generator = Java::jmarketsim.simware.SimRandomGenerator.new(
            simulation_schema["left variance"], simulation_schema["right variance"], simulation_schema["mean risk aversion"],
            simulation_schema["risk aversion std dev"], simulation_schema["mean dividend"], simulation_schema["kappa"],
            simulation_schema["dividend shock std dev"], simulation_schema["signal shock std dev"])
    end

    def run
#      mylog = Log4r::Logger.new 'mylog'
#      mylog.outputters = Log4r::Outputter.stdout

      order_book = OrderBook::OrderBook.new(@instrument)
      traders = build_traders
      for i in 1..@simulation_schema["quarters"] do
        dividend = Array[@simulation_generator.next_dividend, 0].max
        for k in 1..@simulation_schema["news per quarter"] do
          news = @simulation_generator.next_news
          traders.shuffle!
          traders.each do |j|
            j.receive_news(news)
            order_book.remove_old_orders(j)
            j.submit_orders(order_book)
          end
        end
        @instrument.end_quarter(dividend)
        traders.each{|j| j.cash_adjustment(j.cash*(@simulation_schema["interest rate"])+j.shares*[dividend, 0].max)}
      end
      @instrument.finalize(traders)
      YAML_LOGGER.record_payoff_data(format_payoff_data(traders))
#     trade_log = Logger['trader']
#      trade_log.outputters = Outputter['payoff_data']
#      traders.each{|i|
#        trade_log.info i.to_s
#      }

    end

    def build_traders
      PricingStrategies::PricingStrategy.create_risk_neutral_utility(@simulation_schema)
      traders = Array.new(@simulation_schema["number of agents"]) {|i|
        utility = Java::jmarketsim.agentware.RiskAverseUtility.new(@simulation_generator.next_risk_aversion(), @simulation_schema["kappa"], @simulation_schema["mean dividend"], 1.0/(1.0+@simulation_schema["interest rate"]))
        variance = Array[@simulation_generator.next_believed_variance(), @simulation_generator.next_believed_variance()].sort!
        private_information = Trader::PrivateInformation.new(variance[0], variance[1], utility)
        temp = @profile[i*@profile.size/@simulation_schema["number of agents"]]
        pricing_strategy = PricingStrategies.const_get(temp.split(":")[0]).new(temp.split(":")[2].to_f, @simulation_schema, private_information)
        if temp.split(":")[1] == "noRA"
          pricing_strategy.price_with_ra = false
        else
          pricing_strategy.price_with_ra = true
        end
        Trader::Trader.new(i, @simulation_schema["cash"], @simulation_schema["shares"], pricing_strategy, private_information)
      }
      return traders
    end

    def format_payoff_data(traders)
      payoff_data = Hash.new
      traders.each do |i|
        strat = i.pricing_strategy.to_s
        if payoff_data.has_key? strat
          payoff_data[strat] = [payoff_data[strat][0]+1, payoff_data[strat][1]+i.cash_value]
        else
          payoff_data[strat] = [1, i.cash_value]
        end
      end
      return_hash = Hash.new
      payoff_data.each{|x,y| return_hash[x] = y[1]/y[0]}
      return return_hash
    end
  end
end
