class Features
  include Mongoid::Document
  embedded_in :player
end