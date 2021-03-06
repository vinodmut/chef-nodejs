include_recipe "build-essential"

node_packages = value_for_platform(
  [ "debian", "ubuntu" ]                      => { "default" => [ "libssl-dev" ] },
  [ "amazon", "centos", "fedora", "centos" ]  => { "default" => [ "openssl-devel" ] },
  "default"   => [ "libssl-dev" ]
)

node_packages.each do |node_package|
  package node_package do
    action :install
  end
end

remote_file "#{Chef::Config[:file_cache_path]}/node-v#{node["nodejs"]["version"]}.tar.gz" do
  source node["nodejs"]["url"]
  checksum node["nodejs"]["checksum"]
end

bash "install-node" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar -xzf node-v#{node["nodejs"]["version"]}.tar.gz
    (cd node-v#{node["nodejs"]["version"]} && ./configure --prefix=#{node["nodejs"]["dir"]} && make && make install)
  EOH
  action :run
  not_if "#{node["nodejs"]["dir"]}/bin/node --version 2>&1 | grep #{node["nodejs"]["version"]}"
end
