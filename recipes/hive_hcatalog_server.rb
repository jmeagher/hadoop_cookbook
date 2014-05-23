include_recipe 'hadoop::hive'

package 'hive-hcatalog-server' do
  action :install
end

service 'hive-hcatalog-server' do
  status_command 'service hive-hcatalog-server status'
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end
