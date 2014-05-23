
include_recipe 'hadoop::default'


# This is a hack to fix the hostname/localhost association in /etc/hosts
# This is bad, but I don't know a better way
# Without this the yarn web interfaces will be listening on 127.0.0.1 
ruby_block 'fix-hosts' do
  block do
    host=node['host']['name']
    ip=node['host']['ip']
    `cp /etc/hosts /etc/hosts.tmp && (sed "s/#{host}//" /etc/hosts.tmp && echo "#{ip} #{host}") > /etc/hosts && mv /etc/hosts.tmp /etc/hosts.bak`
  end
  not_if { File.exist? '/etc/hosts.bak' }
end
