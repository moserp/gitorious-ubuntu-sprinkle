require 'packages/ubuntu'

policy :gitorious, :roles => :server do
  requires :sprinkle_dependencies
  requires :ubuntu_gitorious_dependencies
  requires :gitorious
end

package :gitorious do
  #binary 'http://gitorious.org/gitorious/mainline/archive-tarball/master'
  noop do
    pre :install, 'bash -c "export http_proxy=http://proxy.intra.bt.com:8080 && wget http://gitorious.org/gitorious/mainline/archive-tarball/master -O gitorious.tar.gz"'
    pre :install, 'bash -c "tar xfz ~/gitorious.tar.gz -C /var/www && mv /var/www/gitorious-mainline /var/www/gitorious"'
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
