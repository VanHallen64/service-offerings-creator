function Test-Function {
# Get form name
    Enter-SeUrl "https://langara.teamdynamix.com/SBTDClient/81/askit/Login.aspx?ReturnUrl=%2fSBTDClient%2f81%2faskit%2fRequests%2fServiceOfferingDet%3fID%3d647" -Driver $Driver
    # Enter-SeUrl ("$Domain"+"TDClient/81/askit/Requests/ServiceOfferingDet?ID=647") -Driver $Driver

    $EditBtn = Find-SeElement -Wait -Timeout 60 -Driver $Driver -XPath "//span[@id='ctl00_ctl00_cpContent_cpContent_lnkEdit']//a"
    Invoke-SeClick -Element $EditBtn
    $GoToForm = Find-SeElement -Driver $Driver -XPath "//ul[@class='nav nav-shelf']//li//a[contains(@href,'Form')]"
    Invoke-SeClick -Element $GoToForm
    $FormName = Find-SeElement -Driver $Driver -XPath "//div[@id='ctl00_ctl00_ctl00_cpContent_cpContent_cpContent_divSettingsPanel']/h2"
    $FormName = $FormName.Text
    Write-Host $FormName
    
    # Get responsible ID
    Enter-SeUrl ("$Domain"+"TDAdmin/1CC3FF6F-33A6-4148-B145-F5581A4F32BD/82/Service/Forms.aspx?ComponentID=9") -Driver $Driver
    $CurrentField = Find-SeElement -Driver $Driver -Id "txtSearch"
    Send-SeKeys -Element $CurrentField -Keys $FormName
    $SearchBtn = Find-SeElement -Driver $Driver -Id "btnSearch"
    Invoke-SeClick -Element $SearchBtn
    $SelectForm = Find-SeElement -Driver $Driver -XPath "//td//a[contains(text(),'2FA Token Request Form')]"
    Invoke-SeClick -Element $SelectForm
    $Windows = Get-SeWindow -Driver $Driver
    Switch-SeWindow -Driver $Driver -Window $Windows[1]
    $ResponsibleId = Find-SeElement -Driver $Driver -Id "a_1279-value"
    $ResponsibleId = Get-SeElementAttribute -Element $ResponsibleId -Attribute "value"
    Write-Host $ResponsibleId

    # Get responsible name
    try {
        $Responsible = Invoke-RestMethod -Method 'Get' -Uri ("$Domain" + "TDWebApi/api/groups/$ResponsibleId") -Headers $auth_headers
    }
    catch {
        $Responsible = Invoke-RestMethod -Method 'Get' -Uri ("$Domain" + "TDWebApi/api/people/$ResponsibleId") -Headers $auth_headers
    }
    $Responsible = $Responsible.Name
    Write-Host ($Responsible | Format-List -Force | Out-String)

    $Driver.Close()
    Switch-SeWindow -Driver $Driver -Window $Windows[0]
}
