<#
#          Script: NSG creation and mapping to a NIC or subnet                                       
#            Date: January 10, 2019                                                                     
#          Author: Prakhar Sharma
#

DESCRIPTION: 
This script is used to create a security rule and add it to a NSG and then ask user whether we need to map it to
a subnet or NIC

#>

Param
(
[String]$location = "westUS",
[Parameter(Mandatory = $true)][String]$RG,
[Parameter(Mandatory = $true)][String]$Vnetname
)


#Associate a NSG to a NIC
function NSGforNIC
{
Param([String]$NICName, [String]$RG)

$nic = Get-AzureRmNetworkInterface -ResourceGroupName $RG -Name $NICName
$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $RG -Name "NSG"
$nic.NetworkSecurityGroup = $nsg
$nic | Set-AzureRmNetworkInterface
}


#Associate a NSG to a subnet
function NSGforsubnet
{
Param([String]$SubnetName, [String]$RG, [String]$Vnetname)

$VNET = Get-AzureRmVirtualNetwork -Name $Vnetname -ResourceGroupName $RG
Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $VNET -Name $SubnetName`
    -AddressPrefix 10.0.1.0/24 -NetworkSecurityGroup "NSG"
Set-AzureRmVirtualNetwork -VirtualNetwork $VNET
}


try{

$CSVPath = Read-Host -Prompt "Provide the path of input csv (like C:\temp\abc.csv)"


#Checking if CSV is valid
if(!(Test-Path $CSVPath))
{
throw "$CSVPath does not exists"
}

$Input = Import-Csv $CSVPath
Login-AzureRmAccount
$RG=Read-Host -Prompt "Please provide the Resource Group Name"


#Creating a blank NSG
New-AzureRmNetworkSecurityGroup -ResourceGroupName $RG -Location $location -Name "NSG"


#Looping into the input CSV
foreach($input_iterator in $input)
{

$Param = @{
"RuleName" = $input_iterator.RuleName
"Description" = $input_iterator.Description
"Access" = $input_iterator.Access	
"Protocol" = $input_iterator.Protocol	
"Direction" = $input_iterator.Direction	
"Priority" = $input_iterator.Priority
"SourceAddressPrefix" = $input_iterator.SourceAddressPrefix
"SourcePortRange" = $input_iterator.SourcePortRange	
"DestinationAddressPrefix" = $input_iterator.DestinationAddressPrefix
"DestinationPortRange" = $input_iterator.DestinationPortRange
}


#Creating security rules and mapping to NSG
Get-AzureRmNetworkSecurityGroup -Name NSG -ResourceGroupName TestRG | Add-AzureRmNetworkSecurityRuleConfig -Name $Param.RuleName`
-Description $Param.Description -Access $Param.Access -Protocol $Param.Protocol -Direction $Param.Direction -Priority $Param.Priority`
-SourceApplicationSecurityGroup $Param.SourceApplicationSecurityGroup -SourcePortRange $Param.SourcePortRange` 
-DestinationApplicationSecurityGroup $destAsg -DestinationPortRange $Param.DestinationPortRange | Set-AzureRmNetworkSecurityGroup
}


#Getting choice to map NSG to either NIC or subnet
$Choice= Read-Host -Prompt "Please provide choices from below in integer format
1. To attach NSG to a NIC
2. To attach NSG to a subnet"


#Calling respective function on basis of choices entered
if($Choice -eq 1)
{
$NICName= Read-Host -Prompt "Please provide the NIC name on which you want to map NSG"
NSGforNIC -NIC $NICName -RG $RG
}
elseif($Choice -eq 2)
{
$SubnetName= Read-Host -Prompt "Please provide the subnet name on which you want to map NSG"
NSGforsubnet -SubnetName $SubnetName -RG $RG -Vnetname $Vnetname
}
else
{
throw "$Choice is a Wrong choice please select any valid option i.e. 1 or 2"

}

}

catch
{
throw $_
}