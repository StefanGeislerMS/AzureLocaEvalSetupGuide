# Azure Local Install Step-By-Step Setup Checklist

## Summary

This document offers a comprehensive step-by-step checklist for deploying a two-node Azure Local 23H2 cluster on a Hyper-V host within your local, on-premises environment. This Azure Local cluster is designed for evaluation and demonstration purposes. The cluster's performance will depend on the capabilities of your Hyper-V host, but it should be adequate for experimentation and self-learning. Deploying multiple smaller virtual machines should not pose any issues.


## Requirements and prerequisites

### On-premisses
* You will need a Windows Server or Windows Client that supports Hyper-V, with at least 1-2TB of free SSD disk space. The physical host must have a minimum of 64 GB RAM for two virtual node deployments. Each virtual host VM should have at least 24 GB RAM for deployment and 32 GB for applying updates.
* Intel VT-x or AMD-V CPU, with support for nested virtualization in your Hyper-V host.
* An on-premises Active Directory is required; you can use an existing one or set up a new one specifically for Azure Local. The Active Directory does not need to be synced with Azure.
* Internet connectivity is necessary
* A minimum of 14 static IPv4 addresses must be available for the cluster itself and internal appliances. Additional IP addresses will be needed for the VMs you deploy on Azure Local.
* For this checklist, an on-premises network with the range 10.0.0.0/24 was used. IP addresses 10.0.0.220 to 10.0.0.227 were assigned for cluster nodes, and IP addresses 10.0.0.180 to 10.0.0.185 were designated for VMs/appliances created and used internally by the cluster. **If your network uses a different IP address range, you will need to individually adjust the IP addresses in the <code>PrepVMNetwork.ps1</code> script.**

### In Azure
•	Azure Subscription (MSDN Subscription is sufficient)
•	Account with contributor permissions to this subscription

### Online Documentation
•	Online Documentation for setting up a virtual eval environment can be found here: [Deploy a virtual Azure Local, version 23H2 system - Azure Local | Microsoft Learn](https://learn.microsoft.com/en-us/azure/azure-local/deploy/deployment-virtual)

## Installation - Step-by-Step

### Prepare local Active Directory

* Use ADSI Edit to create a new Organizational Unit (OU) for Azure Local – e.g. “AzureLocal”  
![Image](/img/001.png)

*	Create a new user account – e.g. “AzureLocalSetup”. The account will be used as AD Azure Local installation account. You need to assign a strong password and note the password - you'll need it later. Also configure “password never expires” for the account.  
![Image](/img/002.png)

* Grant full access permissions to the Azure Local Installation Account on the Azure Local Organizational Unit (OU). This account must have the permissions to join computers into this OU.  
![Image](/img/003.png)

## Create, install and prepare the cluster node VMs
*	Creation of the Azure Local cluster node VMs is a four-step process:
  1. Create and configure the VMs on your Hyper-V host
  2. Install the initial Azure Stack HCI operating system in these VMs
  3. Configure the VMs and assign static IPs
  4. Onboard the VMs to Azure ARC

### Step 1: Create cluster node VMs in Hyper-V

* Make sure that you have a virtual switch in Hyper-V that is connected to your external network. In this guide we use a switch with the name "External 2500". If your virtual switch has a different name, you adjust the name in the need to edit the <code>CreateAzureLocalClusterNodeVM.ps1</code> script accordingly!  
![Image](/img/004.png)

### Step 2: Download the Azure Stack HCI Operating System Image and install the VMs

*	Documentation how to download an installation image can be found here: [Download Azure Stack HCI Operating System, version 23H2 software for Azure Local deployment - Azure Local | Microsoft Learn](https://learn.microsoft.com/en-us/azure/azure-local/deploy/download-23h2-software)
  
*	To download the install image, sign-in to the Azure portal and search for "Azure Local" - open "Host Environments" and select "Azure Local". Click the "Download Software" button.  
![Image](/img/005.png)

* Click “Choose Language”  
![Image](/img/006.png)

* Next you can chose to download a “preview” version of the install media. We use this version, because it supports easy, graphical ARC onboarding.  
![Image](/img/007.png)

•	Download the preview ISO and store it on your Hyper-V host, so we can use it for installation of VMs.
•	If you don’t want to use the preview version, download the released, "English" version. In this case you need to onboard the VMs using CLI or PowerShell.

### Step 3: Create and configure cluster node VMs in Hyper-V

*	We’ll use the <code>CreateAzureLocalClusterNodeVM.ps1</code> PowerShell Script to create the VMs
* Open the script and adjust the path, where you like to store the new VMs to your needs. In this checklist we create the VMs in <code>$VHDXPath = "E:\Hyper-V\AzureLocal"</code> – also adjust the path to the OS Install – in this checklist we assume the ISO is store here: <code>$OSInstallIsoPath = "E:\Hyper-V\AzureLocal\AZURESTACKHci23H2.25398.469.LCM.10.2408.0.3061.x64.en-us.iso"</code>
* Open a PowerShell commandline your Hyper-V host computer with administrative permissions and run the <code>CreateAzureLocalClusterNodeVM.ps1</code> script. In case everything works fine, you will find two new VMs in your Hyper-V Manager.

You may want to open the VM properties and verify the following properties:
1.	DVD with Install ISO is top of the boot order
2.	TPM is activated
3.	32GB memory assigned
4.	Boot disk and six additional disks assigned
5.	Four NICs assigned: NIC1-NIC4 - during initial installation the VMs will use DHCP - we'll change this to static IPs in a later step. 
6.	Timesync deactivated in Integration Services
7.	Checkpoints are disabled
   
*	Start the VMs and boot from the installation ISO to initially install both cluster nodes.  
![Image](/img/008.png)  
![Image](/img/009.png)  
![Image](/img/010.png)

*	Once the install finished, change the local administrator password on both VMs. Please use the same local administrator password on both VMs - otherwise the script that is used to configure the VMs will fail!  
![Image](/img/011.png)

*	Rename the VMs to a self explaining name using option “2”. Allow the VMs to restart after renaming. In our case we’ll rename the nodes to “ALNode1” and “ALNode2”.  
![Image](/img/012.png)
![Image](/img/013.png)

*	In a next step, we will configure networking and assign static IPs for both VMs. For this purpose, we will use the <code>PrepVMNetwork.ps1</code> script. We will assign 10.0.0.220-10.0.0.227 as static IP addresses to the cluster nodes, and we reserve 10.0.0.180-10.0.0.185 for cluster appliances and internal management purposes. Gateway IP address is 10.0.0.1, DNS is 10.0.0.2. If your IP addresses are differnet, you need to adjust them in the <code>PrepVMNetwork.ps1</code> script accordingly. 
*	The script will set the MAC addresses on the physical interfaces and rename them to NIC1-NIC4. After that it’ll disable DHCP and assign static the IP-Addresses. Finally, it’ll enable Hyper-V on the VMs and configures the time server settings.
*	Run the script on you hyper-v host computer – don’t run the script on the cluster nodes itself.
*	After starting the script, you need to enter local administrator credentials of your cluster nodes (user: "administrator" – "password" the one that you've assigned before).
•	Just to be sure, restart both VMs one’s the script finished successfully.

### Step 4: Onboard VMs to Azure ARC

* Your cluster node VMs need to be onborded to Azure ARC before they can be installed as Azure Local cluster nodes. To onboard both VMs to azure ARC connect with each VM using a browser [http://ALNode1.local](http://ALNode1.local) and [http://ALNode2.local](http://ALNode2.local)

* The Browser will present a warning that the connection is not safe.  
![Image](/img/014.png)

 * Select “Advanced” and continue to connect to the VM  
 ![Image](/img/015.png)

* Logon as Administrator  
![Image](/img/016.png)

* Setup the ARC Agent  
![Image](/img/017.png)  

* Choose NIC1 as network connection and configure Proxy if necessary. Then continue. Specify the subscription ID, a resource group name and region, where the Azure Local Cluster should be created. If the resource group does not exist, it will be created. Then specify the tenant ID. In case you’re using an ARC Gateway to connect, also specify the Gateway - otherwise leave the Gateway ID empty.  
![Image](/img/018.png)

* Verify your configuration settings and continue.  
![Image](/img/019.png)

* In the next step a device code will be presented. The code is random and generated dynamically. Copy your device code and click on the [https://microsoft.com/devicelogin](https://microsoft.com/devicelogin) link.  
![Image](/img/020.png)

* Enter the device code and continue to login.  
![Image](/img/021.png)

* Login to Azure with your Entra ID account to finalize the ARC onboarding.  
![Image](/img/022.png)

* Switch back to the ARC Agent Setup page and check for errors.  
![Image](/img/023.png)
 
*	Repeat the ARC Agent setup with the second node.  
  
*	To monitor ARC onboarding, open the Azure portal. Search for “Azure ARC” and open the “Machines” tab. Check if both nodes appear as “connected” – that can take some minutes.  
![Image](/img/024.png)

*	Once the servers are onboarded, Azure needs to install several extension on the machines. Select each machine and check the extension installation status. You cannot continue before all extensions have been installed successfully. This can take several Minutes.  
![Image](/img/025.png)

## Deploy the Azure Local cluster

*	In the Azure portal search for ARC and select “Azure Local” – click “Create instance” in “Depoly Azure Local”  
![Image](/img/026.png)  

*	Select the resource group (the one you specified, during ARC onbording) for you Azure Local Cluster and specify a new instance name. Press “Add machines" and select the two nodes that we added to ARC before. Press the “Validate selected machines” button to check if the machines are ready for install.  
![Image](/img/027.png)  

*	Validation will take some seconds. Validation will fail if not all ARC extensions haven been installed successfully. Once validation was success, continue to create a new key vault by pressing the “create a new key vault” link.  
![Image](/img/028.png)
* Chose a valid name for the new Key vault an press the "Create" Button  
![Image](/img/029.png)  

*	After the new key vault is created, the portal will complain, that access permissions are not configured correctly. Click the “Grant Key Vault Permissions” button to fix this.  
![Image](/img/030.png)

* Press the “Next” button to continue. Chose to create a new configuration and continue.  
![Image](/img/031.png) 

*	Configure Networking – select “Network Switch for storage” and select “Group all traffic” for the sake of simplicity. Assign NIC1 to the Compute_Management_Storage network.  
![Image](/img/032.png)

* Select “Manual” IP assignment and specify a range of minimum number of six IP addresses in addition with Gateway and DNS IP. After that press the “Validate Subnet” button for a check on your network details.  
![Image](/img/033.png)

* Specify a name for the cluster location and click the “create new” link to create a new storage account to be used for the cluster witness.
![Image](/img/033a.png)

* Specify a valid name for the storage account an create it. LRS is sufficient.  
![Image](/img/034.png)

* Enter the domain name of your on-premises Active Directory and the path to the OU used for Azure Local. Also enter the user account to be used for the cluster install and the local Administrator credentials.  
![Image](/img/035.png)

* Continue to the next step. Accept the recommended security settings and continue with the next step.  
![Image](/img/036.png)
 
*	Accept the default settings for volume creation and continue.  
![Image](/img/037.png)

*	Assign tags if needed and continue to the final validation. You need to wait until necessary resources have been created. Once this is done, press the “Start Validation” button.  
![Image](/img/038.png)

*	Validation is done in multiple steps and will take several minutes to finish. Leave the Azure portal page open.  
![Image](/img/039.png)  Once the validation ended successfully, press “next” to continue.

*	A summary for the new cluster is shown – press “Create” to start the deployment.  
![Image](/img/040.png) 

*	The deployment process will commence. Keep the Azure portal page open and periodically refresh the screen (use the refresh icon on the page – don’t use the browser page refresh) to view updates. Please note, the deployment may take several hours to complete. Do not power off your VMs or the Hyper-V host while the deployment is in progress.  
![Image](/img/041.png) 

*	Upon successful completion of the final deployment step 'Clean up temporary content', the Azure Local cluster deployment is complete, and you may proceed with configuring the cluster.  
![Image](/img/042.png)

# Configure the cluster for 1st use

The following steps are required to configure the cluster so it is ready for e.g. VM deployments. First, we will create an image to be used for VM deployment. Next, we will set up a logical network for the new VMs. Finally, we will create a VM and configure Admin Center for cluster management.

## Activate Azure Hybrid Benefits

*	Make sure you enable the “Hybrid Benefits” for the new Azure Local cluster nodes. This will allow you to utilize Windows Admin Center to administrate the cluster nodes easier. Otherwise you'll need to administrate the cluster from commandline using PowerShell.  

*	Open the Azure portal, search for Azure Local and select the "ALInstance01" that you’ve just created. An select the “Infrastructure” tab.  
![Image](/img/043.png)
 
*	Then select each machine and enable Azure Benefits for eac h machine as well.  
![Image](/img/044.png)  
 
*	It will take some minutes until this assignment is fully recognized in Azure.

*	You also need to activate Hybrid Benefit for the cluster itself. Select Azure Local, Cluster Instance and then “Settings” – Activate Azure Hybrid Benefit.  
![Image](/img/048.png)
![Image](/img/049.png)

* Check the box and press the “Activate” Button.  
![Image](/img/050.png)

## Create a VM image in Azure Local
*	T have an installation image available locally is a prerequisite if you plan to deploy VMs to your Azure Local cluster.
*	
*	On the “Resources” tag of your cluster instance, select the “VM Images” tab. Use “add image” to add a new image and select the "Marketplace" option.  
![Image](/img/045.png)  
 
*	We will add a "Windows Server 2022" image – double-check you’ve selected the right resource group. Assign a name for the new image and choose "Server 2022" from the list or Marketplace images. Finally create the new image.
![Image](/img/046.png)  
 
*	The deployment of an image to Azure Local may take anywhere from several minutes to several hours, depending on the network bandwidth between the Azure Local cluster on premisses and Azure in the internet. You can monitor the status of the deployment in the Azure portal.  ![Image](/img/047.png)  
 
## Create a logical network in Azure Local

*	A logical network is a prerequisite before VMs can be deployed to an Azure Local cluster. To create a new logical network, open Azure Local in the portal, select the cluster instance and under "Resources" create a new logical network.   
![Image](/img/051.png)

*	Select the right resource group, and name the new logical network. Select the virtual switch that was created during cluster deployment.  
![Image](/img/052.png)

*	Specify thje network information for the logical network, that maps to the on-premises network – we’ll use static IP address assignment.  
![Image](/img/053.png)

## Create a VM on Azure Local
*	When image and logical network creation finished, we can launch creation of a virtual machine on the cluster. Open Azure Local in the portal, select the cluster instance and under "Resources" create a new virtual machine.  
![Image](/img/054.png)

*	Specify the VM details  
![Image](/img/055.png)  
![Image](/img/056.png)

*	Press next, skip creation of a data disk and press next again to configure networking. Add a network interface to the VM.  
![Image](/img/057.png)
 
*	Specify a name for the interface and assign a static IP from the logical network we’ve created earlier.  
![Image](/img/058.png)  
 
*	Review the VM and click the “Create” button. The deployment of a VM can take up to multiple minutes. You can monitor the deployment process in the Azure console.
![Image](/img/059.png)   

## Enable Windows Admin Center for Azure Local cluster nodes

*	Windows Admin Center is a graphical tool that allows cluster node management from the Azure portal, remote, without a need for VPN.  
![Image](/img/060.png)   

* To activate Windows Admin Center for the Azure Local cluster select the cluster instance in Azure Local and under "Settings" select “Windows Admin Center” and chose to setup. Specify a listening port and click the "Install" button.
![Image](/img/061.png)
Deployment of the Windows Admin Center can take multiple minutes.

*	Once deployment is done, you can connect to Windows Admin Center  
![Image](/img/062.png)  

* You can use Windows Admin Center to configure cluster configuration.  
![Image](/img/063.png)  
![Image](/img/064.png)  
![Image](/img/065.png)

*	You can also use Windows Admin Center and connect to each cluster node individually. And manage the nodes instead of the cluster instance.





