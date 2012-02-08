Fabricator(:account) do
  username "bcassell"
  active true
  skip true
end

Fabricator(:account_with_failure, :from => :account) do
  username "fakename"
  password "fake"
  skip false
end