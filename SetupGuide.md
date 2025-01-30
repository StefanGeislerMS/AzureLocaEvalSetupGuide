# Azure Local Install Step-By-Step Setup Checklist

## Summary

This document offers a comprehensive step-by-step checklist for deploying a two-node Azure Local 23H2 cluster on a Hyper-V host within your local, on-premises environment. This Azure Local cluster is designed for evaluation and demonstration purposes. The cluster's performance will depend on the capabilities of your Hyper-V host, but it should be adequate for experimentation and self-learning. Deploying multiple smaller virtual machines should not pose any issues.

## Requirements and prerequisites

### On-premisses
* You will need a Windows Server or Windows Client that supports Hyper-V, with at least 64GB of RAM and 1-2TB of free SSD disk space.
* The CPU must support nested virtualization in Hyper-V.
* An on-premises Active Directory is required; you can use an existing one or set up a new one specifically for Azure Local. The Active Directory does not need to be synced with Azure.
Internet connectivity is necessary.
* A minimum of 14 static IPv4 addresses must be available for the cluster itself and internal appliances. Additional IP addresses will be needed for the VMs you deploy on Azure Local.
* For this checklist, an on-premises network with the range 10.0.0.0/24 was used. IP addresses 10.0.0.220 to 10.0.0.227 were assigned for cluster nodes, and IP addresses 10.0.0.180 to 10.0.0.185 were designated for VMs/appliances created and used internally by the cluster. If your network uses a different IP address range, you will need to individually adjust the IP addresses in the PrepVMNetwork.ps1 script.

### In Azure
•	Azure Subscription (MSDN Subscription is sufficient)
•	Account with contributor permissions to this subscription

### Online Documentation
•	Online Documentation for setting up a virtual eval environment can be found here: [Deploy a virtual Azure Local, version 23H2 system - Azure Local | Microsoft Learn](https://learn.microsoft.com/en-us/azure/azure-local/deploy/deployment-virtual)

## Installation - Step-by-Step
### Prepare local Active Directory
* Create a new Organizational Unit (OU) for Azure Local – e.g. “AzureLocal”
* 
