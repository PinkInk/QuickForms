import-module ..\QuickForms.psd1

$demo = New-QuickForm -Title "Various DateTimePickers" -LabelWidth 100 -ControlWidth 450

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-DateTimePicker -Form $demo -Label "Date" -Type Date' -Bold | Out-Null
$Date = Add-DateTimePicker -Form $demo -Label "Date" -Type Date

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-DateTimePicker -Form $demo -Label "Time" -Type Time' -Bold | Out-Null
$Time = Add-DateTimePicker -Form $demo -Label "Time" -Type Time

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-DateTimePicker -Form $demo -Label "DateTime" -Type DateTime' -Bold | Out-Null
$DateTime = Add-DateTimePicker -Form $demo -Label "DateTime" -Type DateTime

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-DateTimePicker -Form $demo -Label "Set" -Type Date `' -Bold | Out-Null
Add-Title -Form $demo -Label '                   -DateTime (Get-Date -Year 1999 -Month 12 -Day 1)' -Bold | Out-Null
$Set = Add-DateTimePicker -Form $demo -Label "Set" -Type Date -DateTime (Get-Date -Year 1999 -Month 12 -Day 1)

Add-Title -Form $demo | Out-Null
Add-Action -Form $demo

$demo.Show()