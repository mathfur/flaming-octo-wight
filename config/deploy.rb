set :application, "flaming-octo-wight"
set :repository, ENV['FROM_LOCAL'] ? File.dirname(__FILE__) + "/.." : "https://github.com/mathfur/#{application}"
set :branch, ENV['BRANCH'] || :master

set :scm, :git
set :scm_username, 'mathfur'
set :scm_password, proc { Capistrano::CLI.password_prompt('scm_password: ') }

set :user, 'ec2-user'
ssh_options[:keys] = ENV['PRIVATE_KEY']
default_run_options[:pty]=true
set :deploy_to, "/home/#{user}/#{application}"

File.read("#{File.dirname(__FILE__)}/domains").each_line do |line|
  role_name, domain = line.split(/\s+/)
  raise "domains has wrong. role_name:#{role_name}" unless %w{app db web}.include?(role_name)
  raise "domains has wrong. domain:#{domain}" unless domain =~ /^[a-zA-Z0-9.-]+$/
  role role_name, domain
end

namespace :deploy do
  task :install_environment do
    sudo "yum install -y git"
    sudo "which chef-solo || (curl -L https://www.opscode.com/chef/install.sh | sudo bash)"
  end
  before 'deploy:update_code', "deploy:install_environment"

  task :install_by_cookbook_main do
    sudo "chef-solo -c #{release_path}/cookbooks/solo.rb -j #{release_path}/cookbooks/chef.json"
  end
  after 'deploy:update_code', "deploy:install_by_cookbook_main"

  task :npm_install do
    run "(cd #{release_path}; npm install)"
  end
  after 'deploy:update_code', "deploy:npm_install"

  task :start do
    run "(cd #{current_path}; node app.js)"
  end
end
