import-module ..\QuickForms.psd1

$demo = New-QuickForm -Title "Various ListBoxes" -LabelWidth 100 -ControlWidth 450

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-ListBox -Form $demo -Label "ListBox" -Options (1..5) -Rows 2' -Bold | Out-Null
$ListBox = Add-ListBox -Form $demo -Label "ListBox" -Options (1..5) -Rows 2

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-ListBox -Form $demo -Label "SelectedItem" -Options @("One","Two") `' -Bold | Out-Null
Add-Title -Form $demo -Label '            -Rows 2 -SelectedItem "One"' -Bold | Out-Null
$SelectedItem = Add-ListBox -Form $demo -Label "SelectedItem" -Options @("One","Two") -Rows 2 -SelectedItem "One"

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-ListBox -Form $demo -Label "Checkable" -Options (1..5) `' -Bold | Out-Null
Add-Title -Form $demo -Label '            -Checkable' -Bold | Out-Null
$Checkable = Add-ListBox -Form $demo -Label "Checkable" -Options (1..5) -Checkable -Callback {
    $this.Items | %{
        Write-Host "$_, $($_ -in $this.CheckedItems)"
    }
}

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-ListBox -Form $demo -Label "SelectedIndex" -Options (1..3) `' -Bold | Out-Null
Add-Title -Form $demo -Label '            -Rows 2 -SelectedItem 1' -Bold | Out-Null
$SelectedIndex = Add-ListBox -Form $demo -Label "SelectedIndex" -Options (1..3) -Rows 2 -SelectedIndex 1

Add-Title -Form $demo | Out-Null
Add-Title -Form $demo -Label 'Add-ListBox -Form $demo -Label "Buttons" -Options (1..3) -Rows 2 -Buttons @(' -Bold | Out-Null
Add-Title -Form $demo -Label '                @{Name="Add"; Callback={...}},' -Bold | Out-Null
Add-Title -Form $demo -Label '                @{Name="Remove"; Callback={...}}' -Bold | Out-Null
Add-Title -Form $demo -Label '            )' -Bold | Out-Null
$Buttons = Add-ListBox -Form $demo -Label "Buttons" -Options (1..3) -Rows 2 -Buttons @(
    @{Name="Add"; Callback={$Buttons.Items.Add(($Buttons.Items | Measure-Object -Maximum).Maximum+1)}},
    @{Name="Remove"; Callback={if ( $Buttons.SelectedIndex -ne -1 ) {$Buttons.Items.RemoveAt( $Buttons.SelectedIndex )}}}
)

Add-Title -Form $demo | Out-Null
Add-Action -Form $demo

$demo.Show()