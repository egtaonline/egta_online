class MovingToCvManager < Mongoid::Migration
  def self.up
    Game.all.each do |g|
      g.cv_manager = CvManager.new
      if g["features"] != nil
        puts 'non-nil'
        g["features"].each do |feature|
          g.cv_manager.features.create(:name => feature["name"], :expected_value => feature["expected_value"])
        end
      end
      g.save
    end
  end

  def self.down
  end
end