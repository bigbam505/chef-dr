#!/usr/bin/env ruby

require 'rubygems'
require 'chef/knife'

rest = Chef::ServerAPI.new(Chef::Config[:chef_server_url])

Chef::Node.list.each do |node|
  %w{read update delete grant}.each do |perm|
    ace = rest.get("nodes/#{node[0]}/_acl")[perm]
    ace['actors'] << node[0] unless ace['actors'].include?(node[0])
    rest.put("nodes/#{node[0]}/_acl/#{perm}", perm => ace)
  end

  puts "Client \"#{node[0]}\" granted All Permissions on node \"#{node[0]}\""
end
