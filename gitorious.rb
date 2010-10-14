require 'packages/ubuntu'

policy :gitorious, :roles => :app do
  requires :ubuntu
end


deployment do

  # mechanism for deployment
  delivery :capistrano do
    recipes 'deploy'
    set :use_sudo, false
  end

  # source based package installer defaults
  source do
    prefix '/usr/local'
    archives '/usr/local/sources'
    builds '/usr/local/build'
  end

end
