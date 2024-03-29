import-module ..\QuickForms.psd1

$demo = New-QuickForm -Title "Various Textboxes" -LabelWidth 100

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-TextBox -Form $form -Label "Textbox"' -Bold | Out-Null
$TextBox = Add-TextBox -Form $demo -Label "Textbox"

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-TextBox -Form $form -Label "Password" -Password' -Bold | Out-Null
$Password = Add-TextBox -Form $demo -Label "Password" -Password

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-TextBox -Form $form -Label "Mask" -Mask "00/00/0000"' -Bold | Out-Null
$Mask = Add-TextBox -Form $demo -Label "Mask" -Mask "00/00/0000"

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-TextBox -Form $form -Label "Lockable" -Disabled -Text "Calculated value"' -Bold | Out-Null
$Lockable = Add-TextBox -Form $demo -Label "Lockable" -Lockable -Disabled -Text "Calculated value"

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-TextBox -Form $form -Label "Multi row" -Rows 2' -Bold | Out-Null
$MultiRow = Add-TextBox -Form $demo -Label "Multi row" -Rows 2

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-TextBox -Form $form -Label "Action" -ActionButton {$Action.Text = "Cleared"} -ActionButtonText "clear"' -Bold | Out-Null
$Action = Add-TextBox -Form $demo -Label "Textbox" -ActionButton { $Action.Text = "" } -ActionButtonText "clear"


Add-Title -Form $demo | Out-Null
Add-Action -Form $demo

$demo.Show()