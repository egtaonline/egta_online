module Mongoid #:nodoc:
  # Include this module to add automatic sequence feature
  # usage:
  # Class KlassName
  #   include Mongoid::Document
  #   include Mongoid::Sequence
  # ...
  #   field :number, :type=>Integer
  #   sequence :number
  # ...

  module Sequence
    extend ActiveSupport::Concern

    class Holder
      include Document
      field :seq, :type => Integer
    end

    included do
      set_callback :validate, :before, :set_sequence
    end

    module ClassMethods
      attr_accessor :sequence_fields

      def sequence(field)
        self.sequence_fields ||= []
        self.sequence_fields << field
      end
    end

    def set_sequence
      if self.class.sequence_fields.is_a?(Array)
        self.class.sequence_fields.each do |field|
          next if self[field]
          # load schema info (TODO: find better way)
          Holder.first unless Holder._collection

          # TODO: should be Holder._collection.find_and_modify.
          # But as it seems the currnet MongoId::Collection doesn't support find_and_modify, this logic calls Mongo::Collection directly for now
          next_sequence = Holder._collection.master.collection.find_and_modify(:query => {"_id" => "#{self.class.name.underscore}_#{field}"},
                                                                               :update=> {"$inc"=> {"seq"=>1}},
                                                                               :new => true,
                                                                               :upsert => true)
          self[field] = next_sequence["seq"]
        end
      end
    end
  end
end