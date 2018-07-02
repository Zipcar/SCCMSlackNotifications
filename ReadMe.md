# SCCMSlackNotifications PowerShell Module ReadMe

This module will help enable and maintain Slack alerts from SCCM.

## PREREQUISITES

A Slack app will need to be created to properly run this module. Apps can be created for your tenant [here](https://api.slack.com/apps).

* The app will need the "chat:write:bot" permissions, and the OAuth Access Token will then be needed for the module.
* It's also recommended to whitelist the public IP address that the SCCM primary server will be communicating from.
  * [Slack API Whitelisting](https://api.slack.com/docs/oauth-safety#ip_whitelisting)
  * This will ensure if the token is ever compromised, posts will still only be able to come from within the domain.
* Install the app in Slack tenant.

## INSTALLATION

* Install the module by copying the entire "__SCCMSlackNotifications__" folder (the folder this readme is in) to your global PowerShell modules folder on the primary site server.
  * Should be: _"C:\Windows\System32\WindowsPowerShell\v1.0\Modules\"_
* Run `Set-SCCMSlackConfig` with the following parameters:
  * `-PrimarySCCMServer` - The FQDN of the primary site server
  * `-SCCMSiteCode` - The SCCM site code for the primary site
  * `-PSPath` - Optional, defaults to _"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"_ if not manually set.
* Run `Set-SCCMSlackToken -Token [InsertAppTokenHere]`.
  * This will save your private token to a "slack.txt" file in the module folder.
  * If wanted, modify the "slack.txt" file security by limiting permissions on the file. The _SYSTEM_ account will need access.

## CREATING ALERTS

* Alerts can be created to correspond to any status message queries. To find some queries, from the SCCM Console go to:
  * __Monitoring > System Status > Status Message Queries > All Status Messages > Show Messages__
  * Set an appropriate time frame to browse messages - 12 hours should be a good example window. Find the criteria needed to properly alert on the messages you want.
  * Some examples:
    * __MessageID:__ _11171_ - Task Sequence Completion Success
    * __MessageID:__ _11170_ -  Task Sequence Completion Failure
    * __Source:__ _Site Server_, __Severity:__ _Error_ - All error alerts directly generated from SCCM (won't find client-side and other errors.)
* The `New-SCCMSlackRule` command will properly generate a Slack alert based on some of these rules, but is currently limited to only using the "MessageID" field. If a more granular rule is required create the rule using a code, and then modify. The rule can be modified via standard SCCM PowerShell commands (`Set-CMSTatusFilterRule`), or from the SCCM console:
  * __Administration > Sites > Primary Site > Status Filter Rules__

* To create an alert, run `New-SCCMSlackRule`. These are the available parameters:
  * `-RuleName` - Name for the rule, will pre prefixed with `[SLACK-Notification]:`
  * `-MessageID` - The ID of the status message to be monitored for
  * `-SlackChannel` - The name of the channel where you want messages to post, example: `#general`

* Alerts can also be manually created in Status Filter Rules in the SCCM console.
  * Name the rule with the prefix `[SLACK-Notification]:` followed by whatever you want to name the rule.
  * In the general tab, select whichever notification criteria you desire (see above).
  * Under actions, select "Run a Program", set the following line as that program:
    * `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -Command Send-SCCMSlackNotification -ComputerName '%msgsys' -MessageID %msgid -MessageDescription '%msgdesc' -SlackChannel '#SLACKCHANNEL' -Component '%msgcomp' -Severity '%msgsev'`
  * Change the powershell location at the beginning if powershell.exe is running from a different computer location
  * Change `#SLACKCHANNEL` to match whichever channel you want the message posting to.

* The `New-SCCMSlackRule` requires the SCCM PowerShell module. If you're having issues with that command try running `Connect-SCCM` and/or troubleshooting that module.
  * [SCCM PowerShell Module Documentation](https://docs.microsoft.com/en-us/powershell/module/configurationmanager/?view=sccm-ps)
  * If the `New-CMStatusFilterRule` command isn't available in the PowerShell instance, a new Slack rule can't be created.
