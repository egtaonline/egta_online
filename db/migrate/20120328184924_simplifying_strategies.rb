class Strategy
  include Mongoid::Document
  field :name
  field :number
end

class SimplifyingStrategies < Mongoid::Migration
  
  def self.up
    db = Simulator.db
    Simulator.all.each do |s|
      s.roles.each do |r|
        Strategy.find(r.strategy_ids).each do |strat|
          r.strategies << strat.name
        end
      end
      s.save
      s.reload
      puts s.roles.inspect
    end
  end

  def self.down
  end
end