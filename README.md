# NSG-via-Powershell

## DESCRIPTION: 
This script is used to create a security rule and add it to a NSG and then ask user whether we need to map it to
a subnet or NIC

## INPUT:
Input to this script is provided using excel sheet. Below are the input parameters:
1. RuleName
2. Description
3. Access	
4. Protocol	
5. Direction	
6. Priority
7. SourceAddressPrefix
8. SourcePortRange	
9. DestinationAddressPrefix
10. DestinationPortRange
