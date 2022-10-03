import-module ..\QuickForms.psd1

$demo = New-QuickForm -Title "Various ComboBoxes" -LabelWidth 100 -ControlWidth 450

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-ComboBox -Form $demo -Label "ComboBox" -Options (1..9)' -Bold | Out-Null
$ComboBox = Add-ComboBox -Form $demo -Label "ComboBox" -Options (1..9)

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-ComboBox -Form $demo -Label "SelectedItem" -Options @("One","Two") -SelectedItem "One"' -Bold | Out-Null
$SelectedItem = Add-ComboBox -Form $demo -Label "SelectedItem" -Options @("One","Two") -SelectedItem "One"

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-ComboBox -Form $demo -Label "SelectedIndex" -Options @("One","Two") -SelectedIndex 1' -Bold | Out-Null
$SelectedIndex = Add-ComboBox -Form $demo -Label "SelectedIndex" -Options @("One","Two") -SelectedIndex 1

Add-Title -Form $demo | Out-Null
Add-Action -Form $demo

$demo.Show()