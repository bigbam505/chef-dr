current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "test"
client_key               "#{current_dir}/chef/master/test.pem"
validation_client_name   "test-validator"
validation_key           "#{current_dir}/chef/master/test-validator.pem"
chef_server_url          "https://192.168.50.2/organizations/test"
cache_type               'BasicFile'
cache_options( :path => "#{current_dir}/checksums" )
cookbook_path            ["#{current_dir}/cookbooks"]
ssl_verify_mode :verify_none

knife[:secret_file] = "#{current_dir}/encrypted_data_bag_secret"
