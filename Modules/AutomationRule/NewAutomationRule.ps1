#------ Create General Service Offering ------#

function New-AutomationRule($ServiceOfferingId, $ServiceName) {
    # Get ticket designated asignee
    Enter-SeUrl "https://langara.teamdynamix.com/SBTDClient/81/askit/Requests/TicketRequests/PreviewForm?id=$ServiceOfferingId&previewMode=1&requestInitiator=ServiceOffering" -Driver $Driver
    $Assignee = Find-SeElement -Driver $Driver -Id "select2-chosen-7"
    $Assignee = $Assignee.Text

    Enter-SeUrl "https://langara.teamdynamix.com/SBTDAdmin/1cc3ff6f-33a6-4148-b145-f5581a4f32bd/82/AutomationRules/Index?Component=9" -Driver $Driver
    $NewBtn = Find-SeElement -Wait -Timeout 60 -Driver $Driver -XPath '//a[@class="btn btn-primary"]'
    Invoke-SeClick -Element $NewBtn

    # $Prompt = New-AnyBoxPrompt -Name "Name" -Message 'Rule name' -ValidateNotEmpty
    # $RuleNameInput = Show-AnyBox -Prompt $Prompt -Buttons 'Submit', 'Cancel' -DefaultButton 'Submit' -CancelButton 'Cancel'
    # $RuleName = $RuleNameInput.Name

    $Prompt = New-AnyBoxPrompt -Name "Num" -Message 'Rule evaluation order' -ValidateNotEmpty
    $EvalOrderInput = Show-AnyBox -Prompt $Prompt -Buttons 'Submit', 'Cancel' -DefaultButton 'Submit' -CancelButton 'Cancel'
    $EvalOrder = $EvalOrderInput.Num

    $CurrentField = Find-SeElement -Driver $Driver -Id "Name"
    Send-SeKeys -Element $CurrentField -Keys "GTS $ServiceName - Assign to $Assignee"

    $CurrentField = Find-SeElement -Driver $Driver -Id "Order"
    $CurrentField.SendKeys([OpenQA.Selenium.Keys]::Backspace)
    Send-SeKeys -Element $CurrentField -Keys $EvalOrder

    $CurrentField = Find-SeElement -Driver $Driver -Id "Description"
    Send-SeKeys -Element $CurrentField -Keys "This rule assigns General Technical Support tickets created under the $ServiceName service to $Assignee."
}