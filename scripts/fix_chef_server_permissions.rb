#!/usr/bin/env ruby

require 'rubygems'
require 'chef/knife'

rest = Chef::ServerAPI.new(Chef::Config[:chef_server_url])

failed_nodes = []

Chef::Node.list.each do |node|
  %w{read update delete grant}.each do |perm|
    begin
      ace = rest.get("nodes/#{node[0]}/_acl")[perm]
      ace['actors'] << node[0] unless ace['actors'].include?(node[0])
      rest.put("nodes/#{node[0]}/_acl/#{perm}", perm => ace)
    rescue
      failed_nodes.push(node[0])
    end
  end

  puts "Updated Permissions: #{node[0]}"
end

failed_nodes.each do |failed_node|
  puts "Failed Updating Permissions: #{failed_node}"
end
