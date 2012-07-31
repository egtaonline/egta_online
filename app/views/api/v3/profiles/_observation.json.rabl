object false

node :symmetry_groups do
  @profile.symmetry_groups.collect{ |symmetry_group| partial "api/v3/profiles/symmetry_group", locals: { observation_id: @observation_id } }
end