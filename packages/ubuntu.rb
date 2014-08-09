package :ubuntu_gitorious_dependencies do
  pre :install, 'apt-get update'
  requires :git
  requires :mysql
  requires :geoip
  requires :imagemagick
  requires :sphinx
  requires :passenger
  requires :passenger_config
  requires :memcached
end

package :mysql do
  apt 'mysql-server mysql-client'
end

package :git do
  apt 'git-core git-svn'
end

package :ruby do
  apt 'build-essential zlib1g zlib1g-dev libssl-dev libopenssl-ruby libreadline5-dev ruby ruby-dev rake'
end

package :rubygems do
  apt 'rubygems'
end

package :geoip do
  apt 'geoip-bin libgeoip1 libgeoip-dev'
  gem 'geoip' do
    http_proxy 'http://proxy.intra.bt.com:8080'
  end
  verify do
    has_gem 'geoip'
  end
end

package :imagemagick do
  apt 'imagemagick'
end

package :sphinx do
  apt 'sphinxsearch'
end

package :passenger_dependencies do
  apt 'libcurl4-openssl-dev apache2-dev apache2 build-essential' do
    post :install, 'a2enmod rewrite'
    post :install, 'a2enmod ssl'
  end
end

package :passenger do
  requires :passenger_dependencies
  requires :ruby
  requires :rubygems

  gem 'passenger' do
    http_proxy 'http://proxy.intra.bt.com:8080'
    post :install, '/var/lib/gems/1.8/bin/passenger-install-apache2-module --auto'
  end

  verify do
    has_file '/var/lib/gems/1.8/gems/passenger-3.0.0/ext/apache2/mod_passenger.so'
  end
end

package :passenger_config do
  passenger_config = "LoadModule passenger_module /var/lib/gems/1.8/gems/passenger-3.0.0/ext/apache2/mod_passenger.so
PassengerRoot /var/lib/gems/1.8/gems/passenger-3.0.0
PassengerRuby /usr/bin/ruby"
  push_text passenger_config, '/etc/apache2/sites-available/passenger', :sudo => true do
    post :install, "ln -s /etc/apache2/sites-available/passenger /etc/apache2/sites-enabled/001-passenger"
  end

  verify do
    has_file '/etc/apache2/sites-enabled/001-passenger'
  end
end

package :memcached do
  apt 'memcached'
end
