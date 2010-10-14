package :ubuntu do
  requires :apt_update
  requires :wget
  requires :build_essential
  requires :git
  requires :mysql
  requires :apache
  requires :sendmail
  requires :ruby
  requires :rubygems
  requires :imagemagick
  requires :geoip
  requires :zlib
#  requires :onig
#  requires :sphinx
  requires :java
  requires :activemq
  requires :passenger
end

package :apt_update do
  noop do
    post :install, 'apt-get update'
  end
end

package :wget do
  apt 'wget'
end

package :build_essential do
  apt 'build-essential'
end

package :git do
  apt 'git-core'
  apt 'git-svn'
end

package :mysql do
  apt 'mysql-server'
  apt 'mysql-client'
end

package :apache do
  apt 'apache2 apache2-dev'
end

package :sendmail do
  apt 'sendmail'
end

package :ruby do
  apt 'ruby1.9 ruby1.9-dev libopenssl-ruby1.9' do
    post :install, 'ln -sf /usr/bin/ruby1.9 /usr/local/bin/ruby'
  end
end

package :rubygems do
  apt 'rubygems1.9' do
    post :install, 'ln -sf /usr/bin/gem1.9 /usr/local/bin/gem'
  end
end

package :imagemagick do
  apt 'imagemagick'
end

package :geoip do
  apt 'geoip-bin libgeoip1 libgeoip-dev'
end

package :zlib do
  apt 'zlib1g zlib1g-dev'
end

package :onig do
  source "http://www.geocities.jp/kosako3/oniguruma/archive/onig-5.9.1.tar.gz"
end

package :sphinx do
  source "http://www.sphinxsearch.com/downloads/sphinx-0.9.8.tar.gz"
end

package :java do
  apt 'openjdk-6-jre'
end

package :activemq do
  apt 'uuid uuid-dev'
end

package :passenger do
  gem 'passenger' do
    post :install, '/var/lib/gems/1.9.0/bin/passenger-install-apache2-module --auto'
  end
end
