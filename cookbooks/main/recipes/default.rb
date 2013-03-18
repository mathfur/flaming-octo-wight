user_name = "ec2-user"
home_dir = "/home/#{user_name}"

%w{make gcc gcc-c++ git vim zsh nginx}.each do |name|
  package name do
    action :install
  end
end

directory "/home/#{user_name}/tmp" do
  action :create
end

script "install_node_and_npm_from_source" do
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
    echo "export PATH=$PATH:#{home_dir}/local/bin" >> #{home_dir}/.bashrc
    PATH=$PATH:#{home_dir}/local/bin curl https://npmjs.org/install.sh | sh
  EOS
  not_if "which node && which npm"
  notifies :restart, "service[nginx]"
end

cookbook_file "/etc/yum.repos.d/nginx.repo" do
  source "nginx.repo"
  owner "root"
  notifies :restart, "service[nginx]"
end

service "nginx" do
  action [:enable,  :start]
end
