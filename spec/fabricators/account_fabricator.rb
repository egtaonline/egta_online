Fabricator(:account) do
  username "bcassell"
  active true
end

Fabricator(:account_with_failure, :from => :account) do
  username "fakename"
  password "fake"
end