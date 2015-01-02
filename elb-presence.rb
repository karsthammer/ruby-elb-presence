#!/usr/bin/env ruby

require 'net/http'
require 'aws-sdk-core'
require 'optparse'

options = {
	access_key_id: ENV["AWS_ACCESS_KEY"],
	secret_access_key: ENV["AWS_SECRET_KEY"],
	region: ENV["AWS_REGION"],
	load_balancer_name: ENV["ELB_NAME"],
}

OptionParser.new do |opts|
  opts.banner = "Usage: elb-presence.rb [options]"

  opts.on("--access-key-id", :REQUIRED, "AWS access key id") do |v|
    options[:access_key_id] = v
  end

  opts.on("--secret-access-key", :REQUIRED, "AWS secret access key") do |v|
    options[:secret_access_key] = v
  end

  opts.on("--region", :REQUIRED, "AWS region") do |v|
    options[:region] = v
  end

  opts.on("--load-balancer-name", :REQUIRED, "Load balancer name") do |v|
    options[:load_balancer_name] = v
  end

  opts.on("--instance-id", :REQUIRED, "Instance ID") do |v|
    options[:instance_id] = v
  end
end.parse!

if !options[:instance_id]
	options[:instance_id] = Net::HTTP.get(URI('http://169.254.169.254/latest/meta-data/instance-id'))
end

elasticloadbalancing = Aws::ElasticLoadBalancing::Client.new(
  region: options[:region],
  access_key_id: options[:access_key_id],
  secret_access_key: options[:secret_access_key],
)

puts "Registering instance #{options[:instance_id]} with loadbalancer #{options[:load_balancer_name]}"
elasticloadbalancing.register_instances_with_load_balancer(
  load_balancer_name: options[:load_balancer_name],
  instances: [
    {
      instance_id: options[:instance_id],
    },
  ],
)

def deregister(options)
	elasticloadbalancing = Aws::ElasticLoadBalancing::Client.new(
	  region: options[:region],
	  access_key_id: options[:access_key_id],
	  secret_access_key: options[:secret_access_key],
	)

	puts "Deregistering instance #{options[:instance_id]} with loadbalancer #{options[:load_balancer_name]}"
	elasticloadbalancing.deregister_instances_from_load_balancer(
	  load_balancer_name: options[:load_balancer_name],
	  instances: [
	    {
	      instance_id: options[:instance_id],
	    },
	  ],
	)
end
	

trap("INT") do
	Thread.new do
		deregister(options)
		exit
	end
end

trap("TERM") do
	Thread.new do
		deregister(options)
		exit
	end
end


while(true) do
end
