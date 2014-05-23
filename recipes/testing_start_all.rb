include_recipe 'hadoop::default'
include_recipe 'hadoop::hadoop_hdfs_checkconfig'
include_recipe 'hadoop::hive_metastore'

# This is a hack, but it works
# Very loosely based on https://github.com/continuuity/hadoop_cookbook/wiki/Wrapping-this-cookbook#example-creating-directories-in-hdfs

ruby_block 'start-all' do
  block do

    # The basics
    resources('service[hadoop-hdfs-namenode]').run_action(:start)
    resources('service[hadoop-hdfs-datanode]').run_action(:start)
    resources('service[hadoop-yarn-resourcemanager]').run_action(:start)
    resources('service[hadoop-yarn-nodemanager]').run_action(:start)

    # Setup a few other basics
    resources(:execute => 'hdfs-tmpdir').run_action(:run)
    resources(:execute => 'hive-hdfs-warehousedir').run_action(:run)

    resources('service[hive-server2]').run_action(:start)

    # Pick one of these
    #resources('service[hive-metastore]').run_action(:start)
    resources('service[hive-hcatalog-server]').run_action(:start)

  end
end

