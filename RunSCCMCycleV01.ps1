
<#
.SYNOPSIS
Runs SCCM Cycle

.DESCRIPTION
Runs SCCM Cycle from SCM_Client Action

.EXAMPLE
Start-SMSCycle -Action cycleName -ErrorLogPath "Path to Error Log"

.NOTES
Author: Austin Vargason
Date Modified: 3/05/2018
#>

#parameters to pass to function
#these will be passed to the function when the script is called with arguments
param(
    [Parameter(Mandatory=$true)]
    [String]$LogPath,
    [Parameter(Mandatory=$true)]
    [ValidateSet("Application_Deployment_Evaluation",
                "Discovery_Data_Collection",
                "File_Collection",
                "Hardware_Inventory",
                "Machine_Policy_Retrieval_and_Evaluation",
                "Software_Inventory",
                "Software_Metering_Usage_Report",
                "Software_Updates_Deployment_Evaluation",
                "Software_Updates_Scan")]
    [String]$Action
)

function Start-SMSCycle () {

    # Parameter help description
    param (
        [Parameter(Mandatory=$true)]
            [String]$LogPath,
        [Parameter(Mandatory=$true)]
            [ValidateSet("Application_Deployment_Evaluation",
                        "Discovery_Data_Collection",
                        "File_Collection",
                        "Hardware_Inventory",
                        "Machine_Policy_Retrieval_and_Evaluation",
                        "Software_Inventory",
                        "Software_Metering_Usage_Report",
                        "Software_Updates_Deployment_Evaluation",
                        "Software_Updates_Scan")]
            [String]$Action
    )

    #namespace to connect to
    $namespace = "root\ccm"

    #set error variable
    $errorExists = $false

    #get the date
    $date = Get-Date

    #switch to store action
    #strAction is code for action
    #actionDesc is Cycle Description
    switch ($Action) {
        "Application_Deployment_Evaluation"{
            $strAction = "{00000000-0000-0000-0000-000000000121}"
            $actionDesc = "Application Deployment Evaluation Cycle"
        }
        "Discovery_Data_Collection" {
            $strAction = "{00000000-0000-0000-0000-000000000003}"
            $actionDesc = "Discovery Data Collection Cycle"
        }
        "File_Collection" {
            $strAction = "{00000000-0000-0000-0000-000000000104}"
            $actionDesc = "File Collection Cycle"
        }
        "Hardware_Inventory" {
            $strAction = "{00000000-0000-0000-0000-000000000001}"
            $actionDesc = "Hardware Inventory Cycle"
        }
        "Machine_Policy_Retrieval_and_Evaluation" {
            $strAction = "{00000000-0000-0000-0000-000000000021}"
            $actionDesc = "Machine Policy Retrieval and Evaluation Cycle"
        }
        "Software_Inventory" {
            $strAction = "{00000000-0000-0000-0000-000000000002}"
            $actionDesc = "Software Inventory Cycle"
        }
        "Software_Metering_Usage_Report" {
            $strAction = "{00000000-0000-0000-0000-000000000031}"
            $actionDesc = "Software Metering Usage Report Cycle"
        }
        "Software_Updates_Deployment_Evaluation" {
            $strAction = "{00000000-0000-0000-0000-000000000108}"
            $actionDesc = "Software Updates Deployment Evaluation Cycle"
        }
        "Software_Updates_Scan" {
            $strAction = "{00000000-0000-0000-0000-000000000113}"
            $actionDesc = "Software Updates Scan Cycle"
        }
        Default {
            Write-Host "Unknown Action Provided"
        }
    }

    #top of log file
    $logString = "Start-SMSCycle Invoked `r`n"
    $logString += "Action: " + $actionDesc + "`r`n"
    $logString += "Date: " + $date + "`r`n"
    $logString += "---------------------------------------------------------------`r`n" 
    #perform chosen action with invoke-wmimethod
    #if an error when initiating cycle, an error log will be created
    Try {
        Write-Host "Performing Action: " $actionDesc
        Invoke-WmiMethod -Namespace $namespace -Class SMS_Client -Name TriggerSchedule -ArgumentList $strAction -ErrorAction Stop | Out-Null
    }
    Catch {
        $errorExists = $true
        $logString += "Error Trying to initiate Action $actionDesc`r`n"
        $logString += "---------------------------------------------------------------`r`n" 
    }
    Finally {
        #if an error exists, let the user know
        if ($errorExists) {
            $logString += "Operation: " + $actionDesc + "Completed With Error`r`n"
        }
        else {
            $logString += "Operation Completed Successfully`r`n"
        }

        $logString += "---------------------------------------------------------------`r`n" 
    }

    $logString| Add-Content -Path $LogPath

}

#invoke the function
Start-SMSCycle -Action $Action -LogPath $LogPath
