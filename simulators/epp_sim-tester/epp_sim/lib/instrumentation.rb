require 'yaml_logger'

class EquityPremiumInstrumentation
  def initialize(interest_rate, quarter_count, yaml_logger)
    @interest_rate = interest_rate
    @total_price_1 = 0
    @average_price_0 = -1
    @period_count = 0
    @total_premium = 0
    @transaction_count = 0
    @total_dividend = 0
    @quarter_count = quarter_count
  end

  def record_price(price)
    @total_price_1 += price
    @transaction_count += 1
  end

  def end_quarter(dividend)
    @total_dividend += dividend
    if @transaction_count != 0
      if @average_price_0 != -1
        @total_premium += ((@total_price_1/@transaction_count)+dividend)/@average_price_0-(1+@interest_rate)
        @period_count += 1
      end
      @average_price_0 = @total_price_1/@transaction_count
      @total_price_1 = 0
      @transaction_count = 0
    end
  end

  def finalize(traders)
    average_payoff = 0
    traders.each{|x| average_payoff += x.cash_value}
    YAML_LOGGER.record_feature("average_payoff", average_payoff/traders.size)
    YAML_LOGGER.record_feature("average_equity_premium", @period_count != 0 ? @total_premium/@period_count : @total_premium != 0 ? "Problem" : "NIL")
    YAML_LOGGER.record_feature("average_dividend", @total_dividend/@quarter_count)
    @total_price_1 = 0
    @average_price_0 = -1
    @period_count = 0
    @total_premium = 0
    @transaction_count = 0
    @total_dividend = 0
  end
end
