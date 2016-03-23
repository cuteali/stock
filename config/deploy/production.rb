set :stage, :production
# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server 'yaohuo.la', user: 'ubuntu', roles: %w{app db web}, primary: true
# server 'example.com', user: 'deploy', roles: %w{app web}, other_property: :other_value
# server 'db.example.com', user: 'deploy', roles: %w{db}

# chef_role :db,      'role:appserver AND chef_environment:prod',  limit: 1, primary: true
# chef_role :app,     'role:appserver AND chef_environment:prod'
# chef_role :web,     'role:appserver AND chef_environment:prod'
# chef_role :worker,  'role:worker AND chef_environment:prod'

set :user,          'ubuntu'
set :rails_env,     'production'

# connection_options = {
#     port:           22,
#     forward_agent:  true,
#     user:           'ubuntu',
#     keys:           %w(~/.ssh/id_rsa),
#     auth_methods:   %w(publickey)
# }

# set :ssh_options,   connection_options

# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any  hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :app, %w{deploy@example.com}, my_property: :my_value
# role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
# role :db,  %w{deploy@example.com}



# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.



# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
 set :ssh_options, {
   keys: %w(~/.ssh/id_rsa),
   forward_agent: false,
   auth_methods: %w(password)
 }
#
# The server-based syntax can be used to override options:
# ------------------------------------
server 'yaohuo.la',
  user: 'ubuntu',
  roles: %w{web app},
  ssh_options: {
    user: 'user_name', # overrides user setting above
    keys: %w(~/.ssh/id_rsa),
    forward_agent: false,
    auth_methods: %w(publickey password)
    # password: 'please use keys'
  }