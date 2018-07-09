function Send-SCCMSlackNotification {
    [CmdletBinding()]
    Param (
        [String]$MessageID, #%msgid
        [String]$ComputerName, #%msgsys
        [String]$Component, #%msgcomp
        [String]$Severity,#%msgsev
        [String]$MessageDescription, #%msgdesc
        [String]$SlackChannel = "#general"
    )

    Begin {
        $SlackWebHook = "https://slack.com/api/chat.postMessage"
        $Config = Get-SCCMSlackConfig
        $SlackToken = Get-Content "$PSScriptRoot\slack.txt"

        If ($Severity) {
            $Severity = $Severity.Trim()
        }
        #Severity icons
        If ($Severity -like "E") {
            $SeverityIcon =  ":x:" #Error
            $AttachmentColor = "danger"
        }
        Elseif ($Severity -like "W") {
            $SeverityIcon = ":warning:" #Warning
            $AttachmentColor = "warning"
        }
        Elseif ($Severity -like "I") {
            $SeverityIcon = ":information_source:" #Information
            $AttachmentColor = "good"
        }
    }
    Process {
        $SlackMessage = "$SeverityIcon $($Component):"
        $Attachments = @(
            @{
                title = "$ComputerName reports:";
                color = "$AttachmentColor";
                text = "$MessageDescription"
            }
        )
        $SlackPost = @{
            channel="$SlackChannel";
            text="$SlackMessage";
            attachments = $Attachments;
            username = "SCCM Notifications"
        }
        $SlackHeader = @{
            Authorization = "Bearer $SlackToken";
        }
        $SlackPostJson = $SlackPost | ConvertTo-Json
        Invoke-WebRequest -Body $SlackPostJson -Method Post -Uri $SlackWebHook -Headers $SlackHeader -ContentType "application/json"
    }
     End {

     }

}


Set-Alias -Name Send-SlackTSNotification -Value Send-SCCMSlackNotification
Export-ModuleMember -Alias * -Function * 