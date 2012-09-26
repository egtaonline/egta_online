module RoleManipulator
  module Base
    def add_role(name, count=nil, reduced_count=count)
      roles.find_or_create_by(name: name, count: count, reduced_count: reduced_count)
    end

    def remove_role(role_name)
      roles.where(name: role_name).destroy_all
    end

    def add_strategy(role_name, strategy_name)
      role = roles.find_or_create_by(name: role_name)
      strategies = role.strategies
      if strategy_name =~ /\A[\w:.-]+\z/ && !strategies.include?(strategy_name)
        strategies << strategy_name
        role.update_attribute(:strategies, strategies.sort)
      end
    end

    def remove_strategy(role_name, strategy_name)
      role = roles.where(name: role_name).first
      if role != nil
        role.strategies.delete(strategy_name)
        role.save!
      end
    end

    def strategies_for(role_name)
      role = roles.where(name: role_name).first
      role == nil ? [] : role.strategies
    end
  end

  module RolePartition
    def unassigned_player_count
      rcount = roles.map{ |r| r.count }.reduce(:+)
      rcount == nil ? (size ? size : 0) : size-rcount
    end

    def available_strategies(role_name)
      simulator.strategies_for(role_name)-self.strategies_for(role_name)
    end

    def available_roles
      simulator.roles.collect{ |r| r.name }-roles.collect{ |r| r.name }
    end
  end

  module Scheduler
    include Base
    include RolePartition

    def add_strategy(role, strategy_name)
      super
      Resque.enqueue(ProfileAssociater, self.id)
    end

    def remove_strategy(role_name, strategy_name)
      role = super
      Resque.enqueue(StrategyRemover, self.id) if role != nil
    end

    def remove_role(role_name)
      remove_self_from_profiles(self.profiles) if roles.where(name: role_name).first
      super
    end

    def add_strategies_to_game(game)
      roles.each do |r|
        game.roles.create!(name: r.name, count: r.count)
        r.strategies.each{ |s| game.add_strategy(r.name, s) }
      end
    end

    def invalid_role_partition?
      (roles.collect{ |role| role.count }.reduce(:+) != size) | roles.detect{ |r| r.strategies.count == 0 }
    end
  end
end

