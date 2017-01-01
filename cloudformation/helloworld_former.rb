#!/usr/bin/env ruby

require 'rubygems'
require 'aws-sdk'
require 'securerandom'

Aws.use_bundled_cert! #Fixes the cert issue for windows users
client = Aws::CloudFormation::Client.new(region: 'us-east-1')

template_body = File.read 'Rails_Multi_AZ_template.json'

client.validate_template({ template_body: template_body })

stack_name = 'HelloWorld'

parameters = [{ parameter_key: 'KeyName', parameter_value: 'AWS_KEYPAIR_NAME' },
              { parameter_key: 'DBName', parameter_value: 'helloworld' },
              { parameter_key: 'DBUser', parameter_value: 'user' },
              { parameter_key: 'DBPassword', parameter_value: SecureRandom.base64(12) },
              { parameter_key: 'DBAllocatedStorage', parameter_value: '5' },
              { parameter_key: 'DBInstanceClass', parameter_value: 'db.t2.small' },
              { parameter_key: 'MultiAZDatabase', parameter_value: 'true' },
              { parameter_key: 'SecretKeyBase', parameter_value: SecureRandom.hex(64) },
              { parameter_key: 'SSHLocation', parameter_value: '0.0.0.0/0' },
              { parameter_key: 'WebServerCapacity', parameter_value: '2' }]

begin
  create_stack = client.create_stack({
    stack_name: stack_name,
    template_body: template_body,
    parameters: parameters,
    capabilities: ['CAPABILITY_IAM'],
    on_failure: 'ROLLBACK',
  })

  if create_stack.successful?
    stack_events = Thread.new do
      response = client.describe_stack_events({ stack_name: stack_name })
      events = {}
      while true do
        response.stack_events.each do |event|
          if !events[event.resource_type]
            events[event.resource_type] = event.resource_status
            puts "#{event.resource_type.ljust(70)}#{event.resource_status}"
          elsif events[event.resource_type] == 'CREATE_IN_PROGRESS' &&
            ['CREATE_FAILED', 'CREATE_COMPLETE'].include?(event.resource_status)
            events[event.resource_type] = event.resource_status
            puts "#{event.resource_type.ljust(70)}#{event.resource_status}"
          end
        end
        new_token = response.next_token
        response = client.describe_stack_events({ stack_name: stack_name, next_token: new_token })
        sleep 5
      end
    end
    client.wait_until(:stack_create_complete)
    sleep 6 #just to be sure stack_events prints the last message before kill
    Thread.kill(stack_events)
    description = client.describe_stacks({ stack_name: stack_name })
    puts "\n\n OUTPUT DATA:\n"
    description.stacks[0].outputs.each do |output|
      if output.output_key == 'LoadBalancerName'
        # Couldn't get the output directly as EC2s are created by LaunchConfiguration
        load_balancer_name = output.output_value.split('-')[0..2].join('-')
        #LoadBalancer does not output Name attribute, processing it's DNS name
        elb = Aws::ElasticLoadBalancing::Client.new(region: 'us-east-1')
        ec2 = Aws::EC2::Client.new(region: 'us-east-1')
        puts "\tEC2 Public DNS names, use this address to bootstrap with knife\n"
        elb.describe_load_balancers({load_balancer_names: [ load_balancer_name ]}).
        to_h[:load_balancer_descriptions][0][:instances].each do |instance|
          puts "***\t\t#{ec2.describe_instances({ instance_ids: [instance[:instance_id]] }).
          reservations[0].instances[0].public_dns_name}"
        end
        puts "\n"
        next
      end
      puts "\t#{output.description}\n"
      puts "***\t\t#{output.output_value}\n"
    end
  end
rescue Aws::CloudFormation::Errors::ServiceError => error
  puts error
end
