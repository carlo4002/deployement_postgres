# Goal
This code is intented to deploy a cluster postgres in aws using patroni and etcd in each node.
This code will cover from:
  - OS preparation
  - ETCD instalation and configuration
  - Postgresql instalation and configuration
  - Patroni instalation and configuration

# Roles
The playbook divide the task in 4 roles
* common
* etcd
* postgres
* patroni

# Running desing 
The playbook is desing to run on local, but will have the information of all the nodes in the cluster (IPS).
Onces the instance is launch, aws data user will prepare the inventory dynamically and run the ansible. The installation will be run on parallel in every node.
Each of them will have the same code running at the same time, therefore the leader is gonna be aleatory. 

# Not intented to do
  - Infra deployment
  - Health verifications after installation
  - Pick a particular leader

# Work to do 
* add role for monitoring and observility
* add role to verify health of cluster after installation.
