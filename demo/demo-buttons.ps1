import-module ..\QuickForms.psd1

$demo = New-QuickForm -Title "Various Buttons" -LabelWidth 100 -ControlWidth 450

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-Buttons -Form $demo -Buttons @(' -Bold | Out-Null
Add-Title -Form $demo -Label '                @{Name="Add"; Callback={...}},' -Bold | Out-Null
Add-Title -Form $demo -Label '                @{Name="Remove"; Callback={...}}' -Bold | Out-Null
Add-Title -Form $demo -Label '            )' -Bold | Out-Null
Add-Buttons -Form $demo -Buttons @(
    @{Name="Add"; Callback={ Write-Host "Add" }},
    @{Name="Remove"; Callback={ Write-Host "Remove"}}
)

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-Buttons -Form $demo -Align Left -Buttons @(' -Bold | Out-Null
Add-Title -Form $demo -Label '                @{Name="Add"; Callback={...}},' -Bold | Out-Null
Add-Title -Form $demo -Label '                @{Name="Remove"; Callback={...}}' -Bold | Out-Null
Add-Title -Form $demo -Label '            )' -Bold | Out-Null
Add-Buttons -Form $demo -Align Left -Buttons @(
    @{Name="Add"; Callback={ Write-Host "Add" }},
    @{Name="Remove"; Callback={ Write-Host "Remove"}},
    @{Name="Start"; Callback={ Write-Host "Start"}}
)

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-Buttons -Form $demo -Align Right -Buttons @(' -Bold | Out-Null
Add-Title -Form $demo -Label '                @{Name="Add"; Callback={...}},' -Bold | Out-Null
Add-Title -Form $demo -Label '                @{Name="Remove"; Callback={...}}' -Bold | Out-Null
Add-Title -Form $demo -Label '            )' -Bold | Out-Null
Add-Buttons -Form $demo -Align Right -Buttons @(
    @{Name="Add"; Callback={ Write-Host "Add" }},
    @{Name="Remove"; Callback={ Write-Host "Remove"}},
    @{Name="Stop"; Callback={ Write-Host "Stop"}}
)

Add-Title -Form $demo | Out-Null
Add-Action -Form $demo

$demo.Show()
