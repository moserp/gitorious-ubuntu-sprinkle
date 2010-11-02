require 'packages/ubuntu'

policy :gitorious, :roles => :server do
  requires :sprinkle_dependencies
  requires :ubuntu_gitorious_dependencies
  requires :gitorious
  requires :initscripts
end

package :initscripts do
  requires :gitdaemon_initd
  requires :gitpoller_initd
  requires :stomp_initd
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
    :'mime-types', :'diff-lcs', :json, :'ruby-hmac', :stompserver]

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
    pre :install, 'bash -c "export http_proxy=http://proxy.intra.bt.com:8080 && wget http://gitorious.org/gitorious/mainline/archive-tarball/master -O gitorious.tar.gz"'
    pre :install, 'tar xfz ~/gitorious.tar.gz -C /var/www && mv /var/www/gitorious-mainline /var/www/gitorious'
    pre :install, 'adduser --system --home /var/www/gitorious/ --no-create-home --group --shell /bin/bash git chown -R git:git /var/www/gitorious'
    pre :install, 'chown -R git:git /var/www/gitorious'
    # this next line should work, but http git clone is flakey on gitorious, so using the above tar file instead
    #pre :install, 'export http_proxy=http://proxy.intra.bt.com:8080 && git clone http://git.gitorious.org/gitorious/mainline.git /var/www/gitorious'
    post :install, 'apachectl restart'
  end

  verify do
    has_directory '/var/www/gitorious'
  end
end

package :gitpoller_initd do
  transfer 'init.d/git-poller', 'git-poller' do
    post :install, 'mv git-poller /etc/init.d/git-poller && chmod 755 /etc/init.d/git-poller'
    post :install, 'update-rc.d git-poller defaults'
    post :install, '/etc/init.d/git-poller start'
  end
  verify do
    has_file '/etc/init.d/git-poller'
  end
end

package :stomp_initd do
  transfer 'init.d/stomp', 'stomp' do
    post :install, 'mv stomp /etc/init.d/stomp && chmod 755 /etc/init.d/stomp'
    post :install, 'update-rc.d stomp defaults'
    post :install, '/etc/init.d/stomp start'
  end
  verify do
    has_file '/etc/init.d/stomp'
  end
end

package :gitdaemon_initd do
  noop do
    post :install, 'cp ~git/doc/templates/ubuntu/git-daemon /etc/init.d/git-daemon'
    post :install, 'update-rc.d git-daemon defaults'
    post :install, '/etc/init.d/git-daemon start'
  end
  verify do
    has_file '/etc/init.d/git-daemon'
  end
end

# TODO
# logrotate

# TODO as the git user:
#mkdir .ssh
#touch .ssh/authorized_keys
#chmod 700 .ssh
#chmod 600 .ssh/authorized_keys
#mkdir tmp/pids
#mkdir repositories
#mkdir tarballs
#cp config/database.yml config/database.yml
#cp config/gitorious.yml config/gitorious.yml
#cp config/broker.yml config/broker.yml

package :sprinkle_dependencies do
  apt 'wget'
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
