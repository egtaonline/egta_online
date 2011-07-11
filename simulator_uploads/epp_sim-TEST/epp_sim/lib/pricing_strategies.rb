require 'java'
require 'epp_sim'

module PricingStrategies

  class PricingStrategy

    def self.create_risk_neutral_utility(simulation_schema)
      @risk_neutral_utility = Java::jmarketsim.agentware.RiskAverseUtility.new(0, simulation_schema["kappa"], simulation_schema["mean dividend"], 1.0/(1.0+simulation_schema["interest rate"]))
    end

    def self.evaluate_with_risk_neutral_utility
      @risk_neutral_utility
    end

    attr_reader :buy_price_vector, :sell_price_vector, :shade
    attr_accessor :private_information, :parameters, :price_with_ra
    def initialize(shade, parameters, private_information)
    end
    def process_news(news, cash, shares, utility_function)
      update_beliefs(news[0], news[1])
    end

    def calculate_value(cash, shares, utility_function)
      utility_function.cash_value(cash, shares, @last_dividend, @parameters["mean dividend"]/@parameters["interest rate"], @shock_posterior_mean, Math.sqrt(@shock_posterior_variance))
    end

    def get_prices(cash, shares, utility_function)
      if @price_with_ra == true
        create_buy_schedule(cash, shares, utility_function)
        create_sell_schedule(cash, shares, utility_function)
      else
        create_buy_schedule(cash, shares, PricingStrategy.evaluate_with_risk_neutral_utility)
        create_sell_schedule(cash, shares, PricingStrategy.evaluate_with_risk_neutral_utility)
      end
      @buy_price_vector.each {|x| x*((100.0-shade)/100.0)}
      @sell_price_vector.each {|x| x*((100.0+shade)/100.0)}
    end

    def create_buy_schedule(cash, shares, utility_function)
      buy_schedule = Array.new
      buy_schedule << [cash, find_next_cep(cash, shares, @parameters["mean dividend"]/@parameters["interest rate"], utility_function)]
      1.upto(@parameters["max shares per transaction"]-1) do |index|
        tcash = buy_schedule.last[0]-buy_schedule.last[1]
        buy_schedule << [tcash, find_next_cep(tcash, shares+index, @parameters["mean dividend"]/@parameters["interest rate"], utility_function)]
      end
      @buy_price_vector = buy_schedule.collect{|entry| entry[1]}
    end

    def create_sell_schedule(cash, shares, utility_function)
      if shares == 0
        return []
      end
      sell_schedule = Array.new
      sell_schedule << [cash, find_previous_cep(cash, shares, @parameters["mean dividend"]/@parameters["interest rate"], utility_function)]
      unless shares == 1
        1.upto([@parameters["max shares per transaction"], shares].min-1) do |index|
          tcash = sell_schedule.last[0]+sell_schedule.last[1]
          sell_schedule << [cash, find_previous_cep(tcash, shares-index, @parameters["mean dividend"]/@parameters["interest rate"], utility_function)]
        end
        @sell_price_vector = sell_schedule.collect{|entry| entry[1]}
      end
    end

    def to_s
      str = self.class.to_s
      str.slice!("PricingStrategies::")
      if @price_with_ra == true
        return "#{str}:RA:#{shade.to_i}"
      else
        return "#{str}:noRA:#{shade.to_i}"
      end
    end

  end

  class BayesianPricing < PricingStrategy
    def initialize(shade, parameters, private_information)
      @shade, @parameters, @private_information = shade, parameters, private_information
      @believed_news_variance = (@private_information.variance_low+@private_information.variance_high)/2.0
      @last_dividend = @parameters["mean dividend"]
      @shock_posterior_mean = 0.0
      @shock_variance = @parameters["signal shock std dev"]**2
      @shock_posterior_variance = @shock_variance
      @gamma = @shock_variance/(@shock_variance+@believed_news_variance)
      update_beliefs(@last_dividend, 0.0)
    end

    def update_beliefs(dividend, signal)
      if dividend != @last_dividend
        @shock_posterior_mean = 0.0
        @shock_posterior_variance = @shock_variance
        @last_dividend = dividend
      end
      @shock_posterior_mean = (1-@gamma)*@shock_posterior_mean+@gamma*signal
      @shock_posterior_variance = (@believed_news_variance*@shock_posterior_variance)/(@believed_news_variance+@shock_posterior_variance)
    end

    def find_next_cep(cash, shares, current_price, utility_function)
      utility_function.find_next_cep(cash, shares, @last_dividend, current_price, @shock_posterior_mean, Math.sqrt(@shock_posterior_variance))
    end

    def find_previous_cep(cash, shares, current_price, utility_function)
      utility_function.find_previous_cep(cash, shares, @last_dividend, current_price, @shock_posterior_mean, Math.sqrt(@shock_posterior_variance))
    end
  end

  class AmbiguityAversePricing < PricingStrategy
    def initialize(shade, parameters, private_information)
      @shade, @parameters, @private_information = shade, parameters, private_information
      @last_dividend = @parameters["mean dividend"]
      @shock_posterior_mean = 0
      @shock_variance = @parameters["signal shock std dev"]**2
      @shock_posterior_variance = @shock_variance
      @gamma_low = @shock_variance/(@shock_variance+@private_information.variance_high)
      @gamma_high = @shock_variance/(@shock_variance+@private_information.variance_low)
      self.update_beliefs(@last_dividend, 0.0)
    end

    def process_news(news, cash, shares, utility_function)
      update_beliefs(news[0], news[1])
      choose_high_or_low(cash, shares, utility_function)
    end

    def update_beliefs(dividend, signal)
      if dividend != @last_dividend
        @shock_posterior_mean = 0
        @shock_posterior_variance = @shock_variance
        @last_dividend = dividend
      end

      @shock_posterior_mean_low = (1-@gamma_low)*@shock_posterior_mean+@gamma_low*signal;
      @shock_posterior_variance_low = (@private_information.variance_high*@shock_posterior_variance)/(@private_information.variance_high+@shock_posterior_variance)
      @shock_posterior_mean_high = (1-@gamma_high)*@shock_posterior_mean+@gamma_high*signal;
      @shock_posterior_variance_high = (@private_information.variance_low*@shock_posterior_variance)/(@private_information.variance_low+@shock_posterior_variance)
    end

    def choose_high_or_low(cash, shares, utility_function)
      value_low = utility_function.cash_value(cash, shares, @last_dividend, @parameters["mean dividend"]/@parameters["interest rate"], @shock_posterior_mean_low, Math.sqrt(@shock_posterior_variance_low))
      value_high = utility_function.cash_value(cash, shares, @last_dividend, @parameters["mean dividend"]/@parameters["interest rate"], @shock_posterior_mean_high, Math.sqrt(@shock_posterior_variance_high))
      if value_low < value_high
        @shock_posterior_mean = @shock_posterior_mean_low
        @shock_posterior_variance = @shock_posterior_variance_low
      else
        @shock_posterior_mean = @shock_posterior_mean_high
        @shock_posterior_variance = @shock_posterior_variance_high
      end
    end

    def find_next_cep(cash, shares, current_price, utility_function)
      price = utility_function.find_next_cep(cash, shares, @last_dividend, current_price, @shock_posterior_mean, Math.sqrt(@shock_posterior_variance))
      price-(@gamma_high-@gamma_low)*Math.sqrt(@shock_variance)/(@parameters["interest rate"]*Math.sqrt(2*Math::PI*@gamma_low))
    end

    def find_previous_cep(cash, shares, current_price, utility_function)
      price = utility_function.find_previous_cep(cash, shares, @last_dividend, current_price, @shock_posterior_mean, Math.sqrt(@shock_posterior_variance))
      price-(@gamma_high-@gamma_low)*Math.sqrt(@shock_variance)/(@parameters["interest rate"]*Math.sqrt(2*Math::PI*@gamma_low))
    end

  end
end