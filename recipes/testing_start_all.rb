include_recipe 'hadoop::default'
include_recipe 'hadoop::hadoop_hdfs_checkconfig'

# This is a hack, but it works
# Very loosely based on https://github.com/continuuity/hadoop_cookbook/wiki/Wrapping-this-cookbook#example-creating-directories-in-hdfs

ruby_block 'start-all' do
  block do
    resources(:execute => 'hdfs-namenode-format').run_action(:run)

    resources('service[hadoop-hdfs-namenode]').run_action(:start)
    resources('service[hadoop-hdfs-datanode]').run_action(:start)
    resources('service[hadoop-yarn-resourcemanager]').run_action(:start)
    resources('service[hadoop-yarn-nodemanager]').run_action(:start)
  end
end

