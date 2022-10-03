import-module ..\QuickForms.psd1

$demo = New-QuickForm -Title "Various Checkboxes" -LabelWidth 100

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-CheckBox -Form $demo -Label "Checkbox"' -Bold | Out-Null
$Checkbox = Add-CheckBox -Form $demo -Label "Checkbox"

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-CheckBox -Form $demo -Label "Checked" -Checked' -Bold | Out-Null
$Checked = Add-CheckBox -Form $demo -Label "Checked" -Checked

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-CheckBox -Form $demo -Label "Disabled" -Disabled' -Bold | Out-Null
$Disabled = Add-CheckBox -Form $demo -Label "Disabled" -Disabled


Add-Title -Form $demo | Out-Null
Add-Action -Form $demo

$demo.Show()