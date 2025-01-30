# This script is used to configure the NICS s of your Azure Local cluster VMs, once they've been initially installed.
# In addition, this script enabled hyper-v in the VMs for nested virtualization and it configures time server

$arrVMNAme = @()
$arrVMNAme += "AzureLocalNode1"
$arrVMNAme += "AzureLocalNode2"

# Static IP addresses to be used by the two cluster node VMs - four each
# if you plan to use different IPs - you need to edit this block accordingly
$arrIPAddr = @()
$arrIPAddr += "10.0.0.220"
$arrIPAddr += "10.0.0.221"
$arrIPAddr += "10.0.0.222"
$arrIPAddr += "10.0.0.223"
$arrIPAddr += "10.0.0.224"
$arrIPAddr += "10.0.0.225"
$arrIPAddr += "10.0.0.226"
$arrIPAddr += "10.0.0.227"

$GatewayIP = "10.0.0.1"
$DNSIP = "10.0.0.2"

$index = 0
# Ask for the local administrator crfedentials
"Enter the local administrator credentials for your Azure Local VMs"
$cred = get-credential

foreach($VMName in $arrVMNAme) {
    "$VMName - Read MACs..."
    ""
    $Node1macNIC1 = Get-VMNetworkAdapter -VMName $VMNAme -Name "NIC1"
    #$Node1macNIC1.MacAddress
    $Node1finalmacNIC1=$Node1macNIC1.MacAddress|ForEach-Object{($_.Insert(2,"-").Insert(5,"-").Insert(8,"-").Insert(11,"-").Insert(14,"-"))-join " "}
    "$VMName - NIC1 MAC: $Node1finalmacNIC1"

    $Node1macNIC2 = Get-VMNetworkAdapter -VMName $VMNAme -Name "NIC2"
    #$Node1macNIC2.MacAddress
    $Node1finalmacNIC2=$Node1macNIC2.MacAddress|ForEach-Object{($_.Insert(2,"-").Insert(5,"-").Insert(8,"-").Insert(11,"-").Insert(14,"-"))-join " "}
    "$VMName - NIC2 MAC: $Node1finalmacNIC2"

    $Node1macNIC3 = Get-VMNetworkAdapter -VMName $VMNAme -Name "NIC3"
    #$Node1macNIC3.MacAddress
    $Node1finalmacNIC3=$Node1macNIC3.MacAddress|ForEach-Object{($_.Insert(2,"-").Insert(5,"-").Insert(8,"-").Insert(11,"-").Insert(14,"-"))-join " "}
    "$VMName - NIC3 MAC: $Node1finalmacNIC3"

    $Node1macNIC4 = Get-VMNetworkAdapter -VMName $VMNAme -Name "NIC4"
    #$Node1macNIC4.MacAddress
    $Node1finalmacNIC4=$Node1macNIC4.MacAddress|ForEach-Object{($_.Insert(2,"-").Insert(5,"-").Insert(8,"-").Insert(11,"-").Insert(14,"-"))-join " "}
    "$VMName - NIC4 MAC: $Node1finalmacNIC4"

    "$VMName - Set MAC on NIC1"
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {param($Node1finalmacNIC1) Get-NetAdapter -Physical | Where-Object {$_.MacAddress -eq $Node1finalmacNIC1} | Rename-NetAdapter -NewName "NIC1"} -ArgumentList $Node1finalmacNIC1
    "$VMName - Set MAC on NIC2"
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {param($Node1finalmacNIC2) Get-NetAdapter -Physical | Where-Object {$_.MacAddress -eq $Node1finalmacNIC2} | Rename-NetAdapter -NewName "NIC2"} -ArgumentList $Node1finalmacNIC2
    "$VMName - Set MAC on NIC3"
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {param($Node1finalmacNIC3) Get-NetAdapter -Physical | Where-Object {$_.MacAddress -eq $Node1finalmacNIC3} | Rename-NetAdapter -NewName "NIC3"} -ArgumentList $Node1finalmacNIC3
    "$VMName - Set MAC on NIC4"
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {param($Node1finalmacNIC4) Get-NetAdapter -Physical | Where-Object {$_.MacAddress -eq $Node1finalmacNIC4} | Rename-NetAdapter -NewName "NIC4"} -ArgumentList $Node1finalmacNIC4

    "$VMName - Disable DHCP on NIC1"
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {Set-NetIPInterface -InterfaceAlias "NIC1" -Dhcp Disabled}
    "$VMName - Disable DHCP on NIC2"
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {Set-NetIPInterface -InterfaceAlias "NIC2" -Dhcp Disabled}
    "$VMName - Disable DHCP on NIC3"
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {Set-NetIPInterface -InterfaceAlias "NIC3" -Dhcp Disabled}
    "$VMName - Disable DHCP on NIC4"
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {Set-NetIPInterface -InterfaceAlias "NIC4" -Dhcp Disabled}

    "$VMName - Set IP to NIC1"
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {param($arrIPAddr, $index, $GatewayIP) New-NetIPAddress -InterfaceAlias "NIC1" -IPAddress $arrIPAddr[$index] -PrefixLength 24 -AddressFamily IPv4 -DefaultGateway $GatewayIP} -ArgumentList ($arrIPAddr, $index, $GatewayIP)
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {param($DNSIP) Set-DnsClientServerAddress -InterfaceAlias "NIC1" -ServerAddresses "$DNSIP"} -ArgumentList ($DNSIP)
    $index++
    "$VMName - Set IP to NIC2"
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {param($arrIPAddr, $index, $GatewayIP) New-NetIPAddress -InterfaceAlias "NIC2" -IPAddress $arrIPAddr[$index] -PrefixLength 24 -AddressFamily IPv4 -DefaultGateway $GatewayIP} -ArgumentList ($arrIPAddr, $index, $GatewayIP)
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {param($DNSIP) Set-DnsClientServerAddress -InterfaceAlias "NIC2" -ServerAddresses "$DNSIP"} -ArgumentList ($DNSIP)
    $index++
    "$VMName - Set IP to NIC3"
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {param($arrIPAddr, $index, $GatewayIP) New-NetIPAddress -InterfaceAlias "NIC3" -IPAddress $arrIPAddr[$index] -PrefixLength 24 -AddressFamily IPv4 -DefaultGateway $GatewayIP} -ArgumentList ($arrIPAddr, $index, $GatewayIP)
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {param($DNSIP) Set-DnsClientServerAddress -InterfaceAlias "NIC3" -ServerAddresses "$DNSIP"} -ArgumentList ($DNSIP)
    $index++
    "$VMName - Set IP to NIC4"
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {param($arrIPAddr, $index, $GatewayIP) New-NetIPAddress -InterfaceAlias "NIC4" -IPAddress $arrIPAddr[$index] -PrefixLength 24 -AddressFamily IPv4 -DefaultGateway $GatewayIP} -ArgumentList ($arrIPAddr, $index, $GatewayIP)
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {param($DNSIP) Set-DnsClientServerAddress -InterfaceAlias "NIC4" -ServerAddresses "$DNSIP"} -ArgumentList ($DNSIP)
    $index++

    #enable Hyper-V
    "$VMName - Enable Hyper-V"
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All }
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {Install-WindowsFeature -Name Hyper-V -IncludeManagementTools}

    #configure timesync
    "$VMName - Configure timesync"
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {w32tm /config /manualpeerlist:"0.at.pool.ntp.org 1.at.pool.ntp.org 2.at.pool.ntp.org 3.at.pool.ntp.org" /syncfromflags:manual /update}
    Invoke-Command -VMName $VMNAme -Credential $cred -ScriptBlock {w32tm /query /status}
}