require 'packages/ubuntu'

policy :gitorious, :roles => :server do
  requires :sprinkle_dependencies
  requires :ubuntu_gitorious_dependencies
  requires :gitorious
  requires :config
  requires :initscripts
  requires :git_user
  requires :git_directories
  requires :start_daemons
  requires :apache_config
end

package :initscripts do
  requires :gitdaemon_initd
  requires :stomp_initd
  requires :gitpoller_initd
end

package :config do
  requires :database_config
  requires :gitorious_config
  requires :stomp_config
end

package :rdiscount do
  gem :rdiscount do
    http_proxy 'http://proxy.intra.bt.com:8080'
  end
  version '1.3.1.1'
  verify { has_gem 'rdiscount', '1.3.1.1' }
end

package :stomp do
  gem :stomp do
    http_proxy 'http://proxy.intra.bt.com:8080'
  end
  version '1.1'
  verify { has_gem 'stomp', '1.1' }
end

package :gitorious_dependencies do
  gems = [:chronic, :daemons, :hoe, :echoe, :'ruby-yadis', :'ruby-openid',
    :'mime-types', :'diff-lcs', :json, :'ruby-hmac', :stompserver, :mysql]

  gems.each do |gem_name|
    puts "installing #{gem_name}"
    gem gem_name do
      http_proxy 'http://proxy.intra.bt.com:8080'
    end
  end
  requires :rdiscount
  requires :stomp

  verify do
    gems.each do |gem|
      has_gem gem
    end
  end
end

package :rack do
  gem :rack do
    http_proxy 'http://proxy.intra.bt.com:8080'
  end
  version '1.0.1'
  verify { has_gem 'rack', '1.0.1' }
end

package :gitorious do
  requires :rack
  requires :gitorious_dependencies
  gem 'mysql' do
    http_proxy 'http://proxy.intra.bt.com:8080'
    pre :install, 'bash -c "export http_proxy=http://proxy.intra.bt.com:8080 && wget http://gitorious.org/gitorious/mainline/archive-tarball/master -O /tmp/gitorious.tar.gz"'
    pre :install, 'tar xfz /tmp/gitorious.tar.gz -C /var/www'
    pre :install, 'mv /var/www/gitorious-mainline /var/www/gitorious'
    pre :install, 'adduser --system --home /var/www/gitorious/ --no-create-home --group --shell /bin/bash git chown -R git:git /var/www/gitorious'
    pre :install, 'chown -R git:git /var/www/gitorious'
    # this next line should work, but http git clone is flakey on gitorious, so using the above tar file instead
    #pre :install, 'export http_proxy=http://proxy.intra.bt.com:8080 && git clone http://git.gitorious.org/gitorious/mainline.git /var/www/gitorious'
    post :install, 'ln -s /var/www/gitorious/script/gitorious /usr/bin'
  end

  verify do
    has_directory '/var/www/gitorious'
  end
end

package :stomp_initd do
  transfer 'init.d/stomp', 'stomp' do
    post :install, 'mv stomp /etc/init.d/stomp'
  end
  verify do
    has_file '/etc/init.d/stomp'
  end
end

package :gitpoller_initd do
  transfer 'init.d/git-poller', 'git-poller' do
    post :install, 'mv git-poller /etc/init.d/git-poller'
  end
  verify do
    has_file '/etc/init.d/git-poller'
  end
end

package :gitdaemon_initd do
  transfer 'init.d/git-daemon', 'git-daemon' do
    post :install, 'mv git-daemon /etc/init.d/git-daemon'
  end
  verify do
    has_file '/etc/init.d/git-daemon'
  end
end

package :gitorious_database do
  noop do
    post :install, 'su - git -c "rake db:create db:migrate RAILS_ENV=production"'
  end
end

package :start_stomp do
  noop do
    post :install, 'chown root:root /etc/init.d/stomp'
    post :install, 'chmod 755 /etc/init.d/stomp'
    post :install, 'update-rc.d stomp defaults'
    post :install, '/etc/init.d/stomp start'
  end
  verify {has_process 'stompserver'}
end

package :start_ruby_daemons do
  noop do
    post :install, 'chown root:root /etc/init.d/git-poller'
    post :install, 'chmod 755 /etc/init.d/git-poller'
    post :install, 'update-rc.d git-poller defaults'
    post :install, '/etc/init.d/git-poller start'
    post :intsall, 'chown root:root /etc/init.d/git-daemon'
    post :install, 'update-rc.d git-daemon defaults'
    post :install, '/etc/init.d/git-daemon start'
  end
  verify {has_process 'ruby'}
end

package :start_daemons do
  requires :stomp_initd
  requires :gitpoller_initd
  requires :gitdaemon_initd
  requires :gitorious_database
  requires :start_stomp
  requires :start_ruby_daemons
end

package :database_config do
  requires :git_user
  transfer 'config/database.yml', '/tmp/database.yml' do
    post :install, 'mv /tmp/database.yml ~git/config/database.yml'
    #post :install, 'chown git:git ~git/config/database.yml'
  end
  verify {has_file '~git/config/database.yml'}
end

package :gitorious_config do
  requires :git_user
  transfer 'config/gitorious.yml', '/tmp/gitorious.yml' do
    post :install, 'mv /tmp/gitorious.yml ~git/config/gitorious.yml'
    #post :install, 'chown git:git ~git/config/gitorious.yml'
  end
  verify {has_file '~git/config/gitorious.yml'}
end

package :stomp_config do
  noop do
    post :install, 'cp ~git/config/broker.yml.example ~git/config/broker.yml'
  end
  verify {has_file '~git/config/broker.yml'}
end

package :git_user do
  noop do
    post :install, 'adduser --system --home /var/www/gitorious/ --no-create-home --group --shell /bin/bash git'
    post :install, 'chown -R git:git /var/www/gitorious'
  end

  verify {file_contains '/etc/passwd', 'git'}
end

package :git_directories do
  noop do
    post :install, "su git -c 'mkdir ~git/.ssh'"
    post :install, "su git -c 'touch ~git/.ssh/authorized_keys'"
    post :install, "chmod 700 ~git/.ssh"
    post :install, "chmod 600 ~git/.ssh/authorized_keys"
    post :install, "su git -c 'mkdir ~git/tmp/pids'"
    post :install, "su git -c 'mkdir ~git/repositories'"
    post :install, "su git -c 'mkdir ~git/tarballs'"
  end

  verify do
      has_file '~git/.ssh/authorized_keys'
      has_directory '~git/tmp/pids'
      has_directory '~git/repositories'
      has_directory '~git/tarballs'
  end
end

# TODO
# logrotate

package :sprinkle_dependencies do
  apt 'wget'
end

package :apache_config do
  transfer 'apache-config/gitorious', '/tmp/gitorious' do
    post :install, 'mv /tmp/gitorious /etc/apache2/sites-available/gitorious'
    post :install, 'ln -s /etc/apache2/sites-available/gitorious /etc/apache2/sites-enabled/002-gitorious'
    post :install, 'rm /etc/apache2/sites-enabled/000-default'
    post :install, 'apachectl restart'
  end
  verify {has_file '/etc/apache2/sites-enabled/002-gitorious'}
end


deployment do
  # mechanism for deployment
  delivery :capistrano do
    recipes 'deploy'
  end

  # source based package installer defaults
  source do
    prefix '/usr/local'
    archives '/usr/local/sources'
    builds '/usr/local/build'
  end
end
