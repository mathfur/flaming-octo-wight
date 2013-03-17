set :application, "flaming-octo-wight"
set :repository,  "https://github.com/mathfur/#{application}"

set :scm, :git
set :scm_username, 'mathfur'
set :scm_password, proc { Capistrano::CLI.password_prompt('scm_password: ') }

set :user, 'ec2-user'
ssh_options[:keys] = "~/.ssh/private/#{ENV['PRIVATE_KEY']}"
default_run_options[:pty]=true
set :deploy_to, "/home/#{user}/#{application}"

File.read("#{File.dirname(__FILE__)}/domains").each_line do |line|
  role_name, domain = line.split(/\s+/)
  raise "domains has wrong. role_name:#{role_name}" unless %w{app db web}.include?(role_name)
  raise "domains has wrong. domain:#{domain}" unless domain =~ /^[0-9.]+$/
  role role_name, domain
end

namespace :deploy do
  task :install_environment do
    sudo "which git || yum install -y git"
    sudo "which chef-solo || (curl -L https://www.opscode.com/chef/install.sh | sudo bash)"
  end
  before 'deploy:update_code', "deploy:install_environment"

  task :install_by_cookbook_main do
    sudo "chef-solo -c #{release_path}/cookbooks/solo.rb -j #{release_path}/cookbooks/chef.json"
  end

  task :npm_install do
    run 'npm install'
  end
  after 'deploy:update_code', "deploy:install_by_cookbook_main"
  after 'deploy:update_code', "deploy:npm_install"

  task :start do
    run "node app.js"
  end
end
