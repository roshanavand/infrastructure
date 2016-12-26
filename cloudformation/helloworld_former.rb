#!/usr/bin/env ruby

require 'rubygems'
require 'aws-sdk'

client = Aws::CloudFormation::Client.new(region: 'us-east-1')

template_body = File.read 'Rails_Multi_AZ_template.json'

client.validate_template({ template_body: template_body })

stack_name = 'HelloWorld'

parameters = [
  {
    parameter_key: 'KeyName',
    parameter_value: 'mos-roshanavand-aws'
  },
  {
    parameter_key: 'DBName',
    parameter_value: 'helloworld'
  },
  {
    parameter_key: 'DBUser',
    parameter_value: 'user'
  },
  {
    parameter_key: 'DBPassword',
    parameter_value: 'password'
  },
  {
    parameter_key: 'DBAllocatedStorage',
    parameter_value: '5'
  },
  {
    parameter_key: 'DBInstanceClass',
    parameter_value: 'db.t2.small'
  },
  {
    parameter_key: 'MultiAZDatabase',
    parameter_value: 'true'
  },
  {
    parameter_key: 'SSHLocation',
    parameter_value: '0.0.0.0/0'
  },
]

begin
  create_stack = client.create_stack({
    stack_name: stack_name, # required
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
            puts "#{event.resource_type}\t#{event.resource_status}"
          elsif events[event.resource_type] == 'CREATE_IN_PROGRESS' && ['CREATE_FAILED', 'CREATE_COMPLETE'].include?(event.resource_status)
            events[event.resource_type] = event.resource_status
            puts "#{event.resource_type}\t#{event.resource_status}"
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
    description.stacks[0].outputs[0].each do |output|
      puts "#{output.description}\n"
      puts "***\t#{output.output_value}\n\n"
    end
  end
rescue Aws::CloudFormation::Errors::ServiceError => error
  puts error
end
