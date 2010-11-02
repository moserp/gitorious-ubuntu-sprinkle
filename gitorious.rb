require 'packages/ubuntu'

policy :gitorious, :roles => :server do
  requires :sprinkle_dependencies
  requires :ubuntu_gitorious_dependencies
  requires :gitorious
end

package :rdiscount do
  gem :rdiscount do
    http_proxy 'http://proxy.intra.bt.com:8080'
  end
  version '1.3.1.1'
end

package :stomp do
  gem :stomp do
    http_proxy 'http://proxy.intra.bt.com:8080'
  end
  version '1.1'
end

package :gitorious_dependencies do
  [:chronic, :daemons, :hoe, :echoe, :'ruby-yadis', :'ruby-openid', :'mime-types', :'diff-lcs', :json, :'ruby-hmac'].each do |gem_name|
    puts "installing #{gem_name}"
    gem gem_name do
      http_proxy 'http://proxy.intra.bt.com:8080'
    end
  end
  requires :rdiscount
  requires :stomp
end

package :rack do
  gem :rack do
    http_proxy 'http://proxy.intra.bt.com:8080'
  end
  version '1.0.1'
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
  end

  verify do
    has_directory '/var/www/gitorious'
  end
end

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
