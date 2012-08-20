module RoleManipulator
  module Base
    def add_role(name, count=nil)
      roles.find_or_create_by(name: name, count: count)
    end

    def remove_role(role_name)
      roles.where(name: role_name).destroy_all
    end

    def add_strategy(role_name, strategy_name)
      role = roles.find_or_create_by(name: role_name)
      if strategy_name =~ /\A[\w:.-]+\z/ && !role.strategies.include?(strategy_name)
        role.strategies << strategy_name
        role.strategies.sort!
        role.save!
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
      self.profiles.pull(:scheduler_ids, self.id) if roles.where(name: role_name).first
      super
    end
  end
end

