# config valid for current version and patch releases of Capistrano
lock '~> 3.19.2'

set :application, 'venganzas_del_pasado'
set :repo_url, 'git@github.com:jschwindt/Venganzas-del-Pasado.git'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/venganzasdelpasado.com.ar'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/database.yml', 'config/credentials/production.key'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets',
       'public/uploads', 'public/sitemaps',
       'public/st0', 'public/st1', 'public/st2', 'public/st3', 'public/st4'

# Default value for default_env is {}
set :default_env,
    { path: '/usr/local/rbenv/shims:/usr/local/rbenv/bin:/home/jschwindt/.nvm/versions/node/v12.22.12/bin:$PATH' }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
