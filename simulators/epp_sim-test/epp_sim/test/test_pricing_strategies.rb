#!/Users/bcassell/.rvm/rubies/jruby-1.5.1/bin/jruby
require 'test/unit'
require 'java'
require "epp_sim"

class PricingStrategiesTest < Test::Unit::TestCase
  
  def test_bayesian_pricing
    parameters = Hash.new
    parameters["mean dividend"] = 1.0
    parameters["shock variance"] = 0.015
    parameters["max shares per transaction"] = 3
    parameters["interest rate"] = 0.05
    parameters["signal shock std dev"] = 0.01
    utility = Java::jmarketsim.agentware.RiskAverseUtility.new(0, 0.1, 1.0, 1.0/(1.05))
    bayesian_pricing = PricingStrategies::BayesianPricing.new(0, parameters, Trader::PrivateInformation.new(0.01, 0.02, utility))
    bayesian_pricing.calculate_prices(100, 4, utility)
  end
  
end
