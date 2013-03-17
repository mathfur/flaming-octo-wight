%w{build-essential libssl-dev make gcc* git vim zsh nginx}.each do |name|
  package name
end

script "install_node_and_npm_from_source" do
  interpreter "bash"
  flags "-e"
  user "root"
  code <<-EOS
    wget http://nodejs.org/dist/#{node[:node][:version]}/node-#{node[:node][:version]}.tar.gz
    tar xvfz node-#{node[:node][:version]}.tar.gz
    cd node-#{node[:node][:version]}
    ./configure --prefix=~/local
    make
    make install
    echo "export PATH=$PATH:~/local/bin" >> ~/.bashrc
    curl https://npmjs.org/install.sh | sh
  EOS
  only_if "test ! -f #{node[:node][:src_cachedir]}/redis-#{node[:node][:version]}.tar.gz"
  notifies :restart, "service[node-server]"
end

cookbook_file "/etc/yum.repos.d/nginx.repo" do
  source "nginx.repo"
  owner "root"
  notifies :restart,  "service[redis-server]"
end
