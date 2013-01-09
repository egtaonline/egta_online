namespace :redis do
  desc "Install Redis"
  task :install, roles: :app do
    # Get a more recent version of redis
    dotdeb = <<-DOTDEB
deb http://packages.dotdeb.org stable all
deb-src http://packages.dotdeb.org stable all
DOTDEB
    put dotdeb,"/tmp/dotdeb"
    run "#{sudo} mv /tmp/dotdeb /etc/apt/sources.list.d/dotdeb.org.list"
    run "wget http://www.dotdeb.org/dotdeb.gpg"
    run "cat dotdeb.gpg | sudo apt-key add -"
    run "#{sudo} apt-get update"
    run "#{sudo} apt-get -y install redis-server"
  end
  after "deploy:install", "redis:install"
end