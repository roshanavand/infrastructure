# Where to start?

### Create an AWS stack
Create an [AWS](http://docs.aws.amazon.com/lambda/latest/dg/setting-up.html) account with sufficient permissions to create the following resources:
  - CloudFormation::Stack
  - ElasticLoadBalancing::LoadBalancer
  - EC2::SecurityGroup
  - RDS::DBSecurityGroup
  - RDS::DBInstance
  - AutoScaling::LaunchConfiguration
  - AutoScaling::AutoScalingGroup

Generate a [keypair](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair) for the newly created AWS Account.
Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) then [Install](https://aws.amazon.com/sdk-for-ruby/) and [configure](http://docs.aws.amazon.com/sdk-for-ruby/v2/developer-guide/setup-config.html) `aws-sdk` for Ruby. The script assumes that you use environment variables to configure AWS login.

Change variable data accordingly in `cloudformation/helloworld_former.rb`:
```sh
parameters = [{ parameter_key: 'KeyName', parameter_value: 'NAME_OF_THE_CREATED_KEYPAIR' }
```
Example:
```sh
parameters = [{ parameter_key: 'KeyName', parameter_value: 'mos-roshanavand-aws' }
```
Run the `helloworld_former.rb` script to create a new stack.
```sh
$ cd cloudformation
$ ruby helloworld_former.rb
```

The stack creation could take up to 30 minutes. meanwhile you can see the creation progress on the screen, wait untill it's finished:
```sh
AWS::CloudFormation::Stack                                            CREATE_IN_PROGRESS
AWS::ElasticLoadBalancing::LoadBalancer                               CREATE_IN_PROGRESS
AWS::EC2::SecurityGroup                                               CREATE_IN_PROGRESS
AWS::ElasticLoadBalancing::LoadBalancer                               CREATE_COMPLETE
AWS::EC2::SecurityGroup                                               CREATE_COMPLETE
AWS::RDS::DBSecurityGroup                                             CREATE_COMPLETE
AWS::RDS::DBInstance                                                  CREATE_IN_PROGRESS
AWS::RDS::DBInstance                                                  CREATE_COMPLETE
AWS::AutoScaling::LaunchConfiguration                                 CREATE_IN_PROGRESS
AWS::AutoScaling::LaunchConfiguration                                 CREATE_COMPLETE
AWS::AutoScaling::AutoScalingGroup                                    CREATE_IN_PROGRESS
AWS::CloudFormation::Stack                                            CREATE_COMPLETE
AWS::AutoScaling::AutoScalingGroup                                    CREATE_COMPLETE
```
When the cration is done, you will get some output:
```sh
OUTPUT DATA:
        EC2 Public DNS names, use this address to bootstrap with knife
***             ec2-54-174-207-9.compute-1.amazonaws.com
***             ec2-54-210-247-10.compute-1.amazonaws.com

        URL for newly created Rails application
***             http://HelloWorl-ElasticL-15M53DC16BDAB-865072088.us-east-1.elb.amazonaws.com/
````
If you don't change the default value for `WebServerCapacity` parameter in the script, then you will have two outputs for EC2 instances, just like above. You'll need them to bootstrap with knife tool.
The second output is the address for `ElasticLoadBalancer`, this address points to out 'Hello World' web page.

### Apply Chef cookbooks
Creation of a ChefServer is not done by our stack creator script.
I have used a [chef.io](http://chef.io) account, you can use any other ways as you like.

Create a [chef.io](https://www.chef.io/account/login) account.
Install and configure [`chefdk`](https://docs.chef.io/install_dk.html) and configure [`knife`](https://docs.chef.io/knife_configure.html)

Upload `hello_world` cookbook to your ChefSerer:
```sh
$ cd cookbooks/hello_world
$ berks install
$ berks upload
```

Use the output data from stack cration to bootstrap the nodes:
```sh
$ knife bootstrap <PUBLIC_DNS_FOR_EC2> --ssh-user ec2-user --sudo --identity-file <PATH_TO_YOUR_AWS_KEYPAIR_PEM> --run-list hello_world -N <NAME_OF_THE_NODE>
```
Example:
```sh
knife bootstrap ec2-54-174-207-9.compute-1.amazonaws.com --ssh-user ec2-user --sudo --identity-file mos-roshanavand-aws.pem --run-list hello_world -N hello_world_1
```
Run this for all the ec2 instances. (Remember to name them differently)

---

Visit the application URL :)
