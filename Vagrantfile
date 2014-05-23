# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # We *need* vagrant-omnibus for these box images
  config.omnibus.chef_version = :latest

  # Enable berkshelf plugin
  config.berkshelf.enabled = true

  # Run Multi-Machine environment to test both OSs
  # http://docs.vagrantup.com/v2/multi-machine/index.html

  %w(
    centos-6.4
  ).each do |platform|

    config.vm.define platform do |c|
      c.vm.box       = "opscode-#{platform}"
      c.vm.box_url   = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_#{platform}_chef-provisionerless.box"
      c.vm.host_name = "singlenode"
      
      # This allows access from the local machine
      c.vm.network :private_network, ip: "192.168.99.2"
    end
  end

  config.vm.provider :virtualbox do |vb|
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  # Ubuntu needs this, but global provisioners run first
  config.vm.provision :shell, :inline => 'test -x /usr/bin/apt-get && sudo apt-get update ; exit 0'

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      :host => {
        # TODO: There has to be a better way to do this
        :name => "singlenode",
        :ip => "192.168.99.2"
      },
      :mysql => {
        :server_root_password => 'rootpass',
        :server_debian_password => 'debpass',
        :server_repl_password => 'replpass'
      },
      :java => {
        :install_flavor => 'oracle',
        :jdk_version => "7",
        :oracle => {
          :accept_oracle_download_terms => true
        }
      },
      :hadoop => {
        :distribution => 'cdh',
        :distribution_version => '5',
        :container_executor => {
          'banned.users' => 'hdfs,yarn,mapred,bin'
        },
        :core_site => {
          'fs.defaultFS' => 'hdfs://localhost:9000'
        },
        :hdfs_site => {
          'dfs.datanode.max.transfer.threads' => 4096
        }
      },
      :hbase => {
        :hbase_site => {
          'hbase.rootdir' => 'hdfs://localhost:8020/hbase',
          'hbase.zookeeper.quorum' => 'localhost',
          'hbase.cluster.distributed' => true
        }
      },
      :hive => {
        :hive_site => {
          'hive.support.concurrency' => 'true',
          'hive.zookeeper.quorum' => 'localhost',
          'hive.metastore.uris' => 'thrift://localhost:9083'
        }
      },
      :zookeeper => {
        :zoocfg => {
          :dataLogDir => '/tmp/zookeeper/logs'
        }
      }
    }

    chef.run_list = [
      # Fix some basic OS level things
      "recipe[hadoop::fix_hosts]",

      # Install all the software
      "recipe[minitest-handler::default]",
      "recipe[java::default]",
      "recipe[hadoop::default]",
      "recipe[hadoop::hadoop_hdfs_namenode]",
      "recipe[hadoop::hadoop_hdfs_datanode]",
      "recipe[hadoop::hadoop_hdfs_secondarynamenode]",
      "recipe[hadoop::hadoop_yarn_resourcemanager]",
      "recipe[hadoop::hadoop_yarn_nodemanager]",
      "recipe[hadoop::zookeeper_server]",
      #"recipe[hadoop::hbase_master]",
      #"recipe[hadoop::hbase_regionserver]",
      "recipe[hadoop::hive_server2]",
      #"recipe[hadoop::hive_metastore]",
      #"recipe[hadoop::hcatalog]",
      "recipe[hadoop::hive_hcatalog_server]",
      #"recipe[hadoop::oozie]",
      "recipe[hadoop::pig]",

      # Run things
      "recipe[hadoop::hadoop_hdfs_namenode_init]",
      "recipe[hadoop::testing_start_all]"
    ]
  end
end
