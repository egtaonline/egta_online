class ReducedRole < Role
  field :reduced_count, type: Integer

  validates :reduced_count, presence: true, numericality: { only_integer: true, greater_than: 0 }
end