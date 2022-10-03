import-module ..\QuickForms.psd1

$demo = New-QuickForm -Title "Various FileBoxes" -LabelWidth 100 -ControlWidth 450

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-FileBox -Form $demo -Label "Open"' -Bold | Out-Null
$Open = Add-FileBox -Form $demo -Label "Open"

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-FileBox -Form $demo -Label "Open" -Type SaveAs' -Bold | Out-Null
$SaveAs = Add-FileBox -Form $demo -Label "SaveAs" -Type SaveAs

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-FileBox -Form $demo -Label "FileFilter" `' -Bold | Out-Null
Add-Title -Form $demo -Label '            -FileFilter "txt files (*.txt)|*.txt|All files (*.*)|*.*"' -Bold | Out-Null
$FileFilter = Add-FileBox -Form $demo -Label "FileFilter" -FileFilter "txt files (*.txt)|*.txt|All files (*.*)|*.*"

Add-Title -Form $demo | Out-Null
Add-Action -Form $demo

$demo.Show()