import-module ..\QuickForms.psd1

$demo = New-QuickForm -Title "Various ListBoxes" -LabelWidth 100 -ControlWidth 450

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-RadioBox -Form $demo -Label "RadioBox" -Options @("One","Two","Three")' -Bold | Out-Null
$RadioBox = Add-RadioBox -Form $demo -Label "RadioBox" -Options @("One","Two","Three")

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-RadioBox -Form $demo -Label "Horizontal" -Options @("One","Two","Three") -Horizontal' -Bold | Out-Null
$Horizontal = Add-RadioBox -Form $demo -Label "Horizontal" -Options @("One","Two","Three") -Horizontal

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-RadioBox -Form $demo -Label "SelectedItem" -Options @("One","Two","Three")' -Bold | Out-Null
Add-Title -Form $demo -Label '             -Horizontal -SelectedItem "Two"' -Bold | Out-Null
$SelectedItem = Add-RadioBox -Form $demo -Label "SelectedItem" -Options @("One","Two","Three") -Horizontal -SelectedItem "Two"

Add-Title -Form $demo | Out-Null
Add-Action -Form $demo

$demo.Show()