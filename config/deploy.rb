set :application, "flaming-octo-wight"
set :repository,  "https://github.com/mathfur/#{application}"

set :scm, :git
set :scm_username, 'mathfur'
set :scm_password, proc { Capistrano::CLI.password_prompt('scm_password: ') }

set :user, 'ec2-user'
set :deploy_to, "/home/#{user}/#{application}"

File.read("#{File.dirname(__FILE__)}/domains").each_line do |line|
  role_name, domain = line.split(/\s+/)
  raise "domains has wrong. role_name:#{role_name}" unless %w{app db web}.include?(role_name)
  raise "domains has wrong. domain:#{domain}" unless domain =~ /^[0-9.]+$/
  role role_name, domain
end

namespace :deploy do
  task :install_environment do
    sudo "yum install git"
    sudo "curl -L https://www.opscode.com/chef/install.sh | bash"
  end
  before 'deploy:update_code', :install_environment

  task :install_by_cookbook_main do
    sudo "chef-solo -c solo.rb -j chef.json"
  end

  task :npm_install do
    run 'npm install'
  end
  after 'deploy:update_code', :npm_install
  after 'deploy:update_code', :install_by_cookbook_main

  task :start do
    run "node app.js"
  end
end
