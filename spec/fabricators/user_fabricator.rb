Fabricator(:user) do
  email {Fabricate.sequence(:email, 1) {|i| "test#{i}@test.com"}}
  password {Fabricate.sequence(:password, 1) {|i| "password#{i}" }}
  secret_key "srgegta"
end