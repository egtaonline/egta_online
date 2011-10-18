class FixSampleRecords < Mongoid::Migration
  def self.up
      # pull your existing data into memory
      # consider batching for large data sets
      # Note that you must call query methods on the object you are migrating
      # for this method to work (i.e. you can not pull via User#sales)

      Profile.all.each {|p| p.role_instances.destroy_all}

      sample_records_attributes = while_stand_alone_doc(SampleRecord) do    
        SampleRecord.all.map(&:attributes)
      end

      # now when you save your data, your fields will be embedded
      count = sample_records_attributes.size
      sample_records_attributes.each do |attributes|
        profile = Profile.find(attributes["profile_id"])
        profile.sample_records.create!(payoffs: {"All" => attributes["payoffs"]}, features: attributes["features"])
        count -= 1
        puts count
      end

      # remove all the documents from the original collection
    end

    def self.while_stand_alone_doc(klass)
      # by changing the Mongoid::Document.embedded you can temporarily
      # modify which collection Mongoid looks to for your model's data store

      begin
        klass.embedded = false

        yield
      ensure
        klass.embedded = true
      end
    end

  def self.down
  end
end
