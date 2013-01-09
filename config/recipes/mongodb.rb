namespace :mongodb do
  desc "Install latest mongodb"
  task :install, roles: :app do
    run "#{sudo} apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10"
    mongosource = <<-MONGO
deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen
MONGO
    put mongosource, "/tmp/10gen.list"
    run "#{sudo} mkdir -p /etc/apt/souces.list.d"
    run "#{sudo} mv /tmp/10gen.list /etc/apt/sources.list.d/"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get install mongodb-10gen"
  end
  after "deploy:install", "mongodb:install"
end