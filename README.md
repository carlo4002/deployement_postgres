# Goal
This code deploys a PostgreSQL cluster on AWS using Patroni and etcd, with each node running its own components. The automation covers the following tasks:
  - OS preparation
  - ETCD instalation and configuration
  - Postgresql instalation and configuration
  - Patroni instalation and configuration

# Roles
The Ansible playbook is structured into four roles:
* common
* etcd
* postgres
* patroni

# Execution Design 
The playbook is intended to run locally on each instance, but it uses knowledge of all cluster node IPs. 
Once an instance is launched, AWS user data scripts dynamically generate the Ansible inventory and trigger the playbook execution.

Deployment occurs in parallel across all nodes. Each node runs the same code simultaneously, resulting in a randomly elected cluster leader. 

# Not intented to do
  - Infra deployment
  - Health verifications after installation
  - Pick a particular leader

# Future improvements 
* Add a role for monitoring and observability
* Add a role to verify cluster health after installation
