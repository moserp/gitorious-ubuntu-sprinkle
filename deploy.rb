set :user, 'root'
role :app, '192.168.56.10', :primary => true
set :use_sudo, false
