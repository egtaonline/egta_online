Fabricator(:server_proxy) do
  after_build {|server_proxy| Fabricate(:account); server_proxy.start}
end