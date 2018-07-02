function Set-SCCMSlackConfig {
    [CmdletBinding()]
    Param (
        [String]$PrimarySCCMServer,
        [String]$SCCMSiteCode,
        [String]$PSPath

    )
    Begin {
        $Config = Import-Clixml -Path "$PSScriptRoot\Config.xml"
    }

    Process {
        Write-Verbose "Setting Config.xml to new values"
        If ($PrimarySCCMServer) {
            $Config.PrimarySCCMServer = $PrimarySCCMServer
        }
        If ($SCCMSiteCode) {
            $Config.SCCMSiteCode = $SCCMSiteCode
        }
        If ($PSPath) {
            $Config.PSPath = $PSPath
        }
    }

    End {
        Write-Verbose "Overwriting Config File"
        $config | Export-Clixml -Path $PSScriptRoot\Config.xml -Force
    }
    
    
}

function Get-SCCMSlackConfig {

    Begin {
        $Config = Import-Clixml -Path $PSScriptRoot\Config.xml
    }

    Process {
        Write-Output $Config
    }

    End {

    }

}

function Set-SCCMSlackToken {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True)][String]$Token
    )
    Begin {
        $SlackTokenFile = "$PSScriptRoot\slack.txt"
        $Token = $Token.Trim()
    }
    Process {
        Write-Host "Writing token to $SlackTokenFile. Ensure 'System' has read access - lock down other permissions as is appropriate."
        $Token | Out-File -FilePath "$SlackTokenFile" -Force
    }
    End {

    }
}