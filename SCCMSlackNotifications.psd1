@{
    ModuleVersion = '1.0'
    Author = 'Andy Kuehner'
    CompanyName = 'Zipcar'
    Description = 'SCCM Slack Notifications'
    NestedModules = @(
        ".\ModuleConfig.psm1",
        ".\SlackNotifications.psm1",
        ".\StatusFilterRules.psm1"
    )
    FunctionsToExport = '*'
    CmdletsToExport = '*'
    VariablesToExport = '*'
    AliasesToExport = '*'
    
}
    
