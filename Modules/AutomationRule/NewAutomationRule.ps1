#------ Create General Service Offering ------#

function New-AutomationRule($ServiceOfferingId, $ServiceName, $EvalOrder) {
    # Get ticket designated asignee
    Enter-SeUrl "https://langara.teamdynamix.com/SBTDClient/81/askit/Requests/TicketRequests/PreviewForm?id=$ServiceOfferingId&previewMode=1&requestInitiator=ServiceOffering" -Driver $Driver
    $Assignee = Find-SeElement -Wait -Timeout 10 -Driver $Driver -Id "select2-chosen-7"
    Write-Host ($AssigneeId | Format-List -Force | Out-String)
    $Assignee = $Assignee.Text
    if ($Assignee.Contains("Group")) { # Remove the word '(Group)' from the name
        $AssigneeShort = $Assignee.Substring(0,$Assignee.Length-8)
    }

    Enter-SeUrl "https://langara.teamdynamix.com/SBTDAdmin/1cc3ff6f-33a6-4148-b145-f5581a4f32bd/82/AutomationRules/Index?Component=9" -Driver $Driver
    $NewBtn = Find-SeElement -Wait -Timeout 60 -Driver $Driver -XPath '//a[@class="btn btn-primary"]'
    Invoke-SeClick -Element $NewBtn

    # Name
    $CurrentField = Find-SeElement -Driver $Driver -Id "Name"
    Send-SeKeys -Element $CurrentField -Keys "GTS $ServiceName - Assign to $Assignee"

    # Order
    $CurrentField = Find-SeElement -Driver $Driver -Id "Order"
    $CurrentField.SendKeys([OpenQA.Selenium.Keys]::Backspace)
    Send-SeKeys -Element $CurrentField -Keys $EvalOrder

    # Stop on Match
    $Checkbox = Find-SeElement -Wait -Timeout 10 -Driver $Driver -Id "ShouldStopOnMatch"
    Invoke-SeClick -Element $Checkbox

    # Description
    $CurrentField = Find-SeElement -Driver $Driver -Id "Description"
    Send-SeKeys -Element $CurrentField -Keys "This rule assigns General Technical Support tickets created under the $ServiceName service to $Assignee."

    # Save
    $SaveBtn = Find-SeElement -Driver $Driver -XPath '//div[@id="divButtons"]//button//span[text()="Save"]'
    Invoke-SeClick -Element $SaveBtn

    # Edit
    $EditBtn = Find-SeElement -Wait -Timeout 60 -Driver $Driver -XPath '//button[@class="btn btn-primary"]'
    Invoke-SeClick -Element $EditBtn

    # Is Active
    $Checkbox = Find-SeElement -Wait -Timeout 10 -Driver $Driver -Id "Rule_IsActive"
    Invoke-SeClick -Element $Checkbox

    # Automation Conditions
    $Option = Find-SeElement -Driver $Driver -Id "filter_column_0"
    $SelectElement = [OpenQA.Selenium.Support.UI.SelectElement]::new($Option)
    $SelectElement.SelectByValue(5315)
    $CurrentField = Find-SeElement -Driver $Driver -Id "lu_text_0"

    # Automation Actions
    $CurrentField = Find-SeElement -Driver $Driver -Id "select2-chosen-7"
    Invoke-SeClick -Element $CurrentField
    $CurrentField = Find-SeElement -Driver $Driver -Id "s2id_autogen7_search"
    Send-SeKeys -Element $CurrentField -Keys $AssigneeShort
    $Selection = Find-SeElement -Driver $Driver -XPath "//div[@class='select2-result-label']//div[text()='$Assignee']"
    Invoke-SeClick -Element $Selection
}