function Connect-SCCM {
    #config
    $Config = Get-SCCMSlackConfig
    $SCCMSiteCode = $Config.SCCMSiteCode
    $PrimarySCCMServer = $Config.PrimarySCCMServer
    # Customizations
    $initParams = @{}
    #$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
    #$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

    # Do not change anything below this line

    # Import the ConfigurationManager.psd1 module 
    if((Get-Module ConfigurationManager) -eq $null) {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
    }

    # Connect to the site's drive if it is not already present
    if((Get-PSDrive -Name $SCCMSiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
        New-PSDrive -Name $SCCMSiteCode -PSProvider CMSite -Root $PrimarySCCMServer @initParams
    }

    # Set the current location to be the site code.
    Set-Location "$($SCCMSiteCode):\" @initParams

}

function Get-SCCMSlackRules {
    Begin {
        #Config
        $Config = Get-SCCMSlackConfig
        $SCCMSiteCode = $Config.SCCMSiteCode
        $PrimarySCCMServer = $Config.PrimarySCCMServer
        #Connect to SCCM
        Write-Verbose "Connecting to SCCM"
        If (!(Get-PSDrive -Name $SCCMSiteCode -ErrorAction SilentlyContinue)) {
            Connect-SCCM
        }
        Else {
            Set-Location "$($SCCMSiteCode):\"
        }
    
    }
    Process {
        Get-CMStatusFilterRule | Where-Object {$_.PropertyListName -like "*SLACK-Notification*"}
    }
    End {

    }

}

function New-SCCMSlackRule {
    [CmdletBinding()]
    Param (
        [String]$RuleName,
        [Int]$MessageID,
        [String]$SlackChannel = "#ak-test"
    )

    Begin {
        #Config
        $Config = Get-SCCMSlackConfig
        $SCCMSiteCode = $Config.SCCMSiteCode
        #$PrimarySCCMServer = $Config.PrimarySCCMServer
        $PSPath = $Config.PSPath

        If (!(Get-PSDrive -Name $SCCMSiteCode -ErrorAction SilentlyContinue)) {
            Connect-SCCM
        }
        Else {
            Set-Location "$($SCCMSiteCode):\"
        }
    }

    Process {
        $NewRule = @{
            "SiteCode" = "$SCCMSiteCode";
            "Name" = "[SLACK-Notification]:$RuleName";
            "MessageId" = $MessageID;
            "RunProgram" = $True;
            "ProgramPath" = "$PSPath -ExecutionPolicy Bypass -Command Send-SlackTSNotification -ComputerName '%msgsys' -MessageID %msgid -MessageDescription '%msgdesc' -SlackChannel '$SlackChannel' -Component '%msgcomp' -Severity '%msgsev'"
        }
        New-CMStatusFilterRule @NewRule
    }

    End {

    }

}

<#function Remove-SCCMSlackRule {

}#>