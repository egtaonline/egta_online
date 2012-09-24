class Role
  include Mongoid::Document

  embedded_in :role_owner, polymorphic: true

  field :strategies, type: Array, default: []
  field :name
  field :count, type: Integer
  field :reduced_count, type: Integer, default: ->{ count }

  validates :name, presence: true,
                   uniqueness: true,
                   format: { with:  /\A\w+\z/, message: "Only letters, numbers, or underscores allowed." }
end