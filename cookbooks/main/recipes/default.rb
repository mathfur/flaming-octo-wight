user_name = "ec2-user"
application_name = "flaming-octo-wight"

home_dir = "/home/#{user_name}"
application_dir = "/#{home_dir}/#{application_name}/current"

%w{make gcc gcc-c++ git vim zsh nginx}.each do |name|
  package name do
    action :install
  end
end

directory "/home/#{user_name}/tmp" do
  owner user_name
  group user_name
  action :create
end

script "Add ~/local/bin to PATH" do
  interpreter "bash"
  flags "-e"
  user user_name
  cwd "#{home_dir}/tmp"
  code <<-EOS
    echo "export PATH=$PATH:#{home_dir}/local/bin" >> #{home_dir}/.bashrc
  EOS
  not_if "ls #{home_dir}/local/bin | grep npm"
end

script "install_node_from_source" do
  interpreter "bash"
  flags "-e"
  user user_name
  cwd "#{home_dir}/tmp"
  code <<-EOS
    wget http://nodejs.org/dist/#{node[:node][:version]}/node-#{node[:node][:version]}.tar.gz
    tar xvfz node-#{node[:node][:version]}.tar.gz
    cd node-#{node[:node][:version]}
    ./configure --prefix=#{home_dir}/local
    make
    make install
  EOS
  not_if "ls #{home_dir}/local/bin/node"
end

script "install_npm" do
  interpreter "bash"
  flags "-e"
  user user_name
  cwd "#{home_dir}/tmp"
  code <<-EOS
    PATH=$PATH:#{home_dir}/local/bin curl https://npmjs.org/install.sh | sh
  EOS
  not_if "ls #{home_dir}/local/bin/npm"
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  owner "root"

  notifies :restart, "service[nginx]"
end

service "nginx" do
  action [:enable,  :start]
end
