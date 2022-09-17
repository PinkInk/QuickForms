#
# QuickForms.psm1
# ===============
# Quick and dirty 2 column powershell forms
#
# History
# -------
# 17/09/2022 - v2.0.0 - Tim Pelling - switched from methods to cmdlets
# 25/08/2022 - v1.3.1 - Tim Pelling - adopt system default font
# 17/08/2022 - v1.3.0 - Tim Pelling - remove control name requirement
# 01/07/2022 - v1.2.0 - Tim Pelling - return rather than magically create objects
#                                       unhide child form object
#                                       modified argument order for AddRow(s), bring type to front
#                                       added listbox, with buttons
# 30/06/2022 - v1.1.2 - Tim Pelling - allow different label and column widths
# 29/08/2019 - v1.1.1 - Tim Pelling - update AddAction behaviour for flexibility
# 29/08/2019 - v1.1.0 - Tim Pelling - added module manifest, PasswordBox as discrete type
# 28/08/2019 - v1.0.1 - Tim Pelling - make widget variable declarations global
# 26/08/2019 - v1.0.0 - Tim Pelling - First Issue

[System.Windows.Forms.Application]::EnableVisualStyles()

class QuickForm {

    # properties
    [System.Windows.Forms.Form]$Form
    hidden [int32]$slot = 0
    hidden [int32]$label_width = 200
    hidden [int32]$control_width = 400
    hidden [int32]$width = $label_width + $control_width
    hidden [int32]$row_height = 25
    hidden [int32]$margin = 10

    # constructor
    QuickForm(
        [string]$Title,
        [int32]$LabelWidth = 200,
        [int32]$ControlWidth = 400
    ) {
        $this.Form = New-Object system.Windows.Forms.Form
        $this.label_width = $LabelWidth
        $this.control_width = $ControlWidth
        $this.width = $LabelWidth + $ControlWidth
        $this.Form.ClientSize = "$($this.width), $($this.row_height)"
        $this.Form.text = $Title
        $this.Form.BackColor = "#ffffff"
        $this.Form.TopMost = $false
    }

    # show the dialog
    Show() { $this.Form.ShowDialog() }

}

function New-QuickForm {
    <#
        .SYNOPSIS
        Create a new simple 2 column form
        .DESCRIPTION
        Returns a QuickForm object having a single method:

        .Show()
            Display the form

        .EXAMPLE
        import-module QuickForms
        $demo = New-QuickForm -Title "Demo Form" -LabelWidth 200 -ControlWidth 400
        $myFirstName = Add-TextBox -Form $demo -Label "First Name:" -Callback { Write-Host $this.Text })
        $demo.Show()
        Write-Host $MyFirstName.Text

        .PARAMETER Title
        Title of the form, displayed in the title bar along with standard form controls.

        .PARAMETER LabelWidth
        Width of the labels column in pixels.

        .PARAMETER ControlWidth
        Width of the controls column in pixels.
    #>
    param (
        [string]$Title = "My Form",
        [int32]$LabelWidth = 200,
        [int32]$ControlWidth = 400
    )
    $form = New-Object QuickForm($Title, $LabelWidth, $ControlWidth)
    return $form
}

function Add-TextBox {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [Parameter(Mandatory=$true)][string]$Label,
        [scriptblock]$Callback
    )
    <#
        .SYNOPSIS
        Add a TextBox control, and label, to an existing QuickForm.
        .DESCRIPTION
        Returns a TextBox object.
        .EXAMPLE
        $myFirstName = Add-TextBox -Form $demo -Label "First Name:" -Callback { Write-Host $this.Text }
        .PARAMETER Form
        Form to add the control and label to.
        .PARAMETER Label
        Label for the control.
        .PARAMETER Callback
        Optional Scriptblock to call when the TextChanged event occurs.
    #>
    $c = New-Object system.Windows.Forms.TextBox
    $c.Multiline = $false
    $c.Location = New-Object System.Drawing.Point(($Form.label_width + $Form.margin), ($Form.row_height * $Form.slot))
    $c.width = $Form.control_width - (2*$Form.margin)
    if ($null -ne $callback) { $c.Add_TextChanged($callback) }
    $l = New-Object System.Windows.Forms.Label
    $l.text = $label
    $l.AutoSize = $false
    $l.Location = New-Object System.Drawing.Point(($Form.margin), ($Form.row_height * $Form.slot))
    $l.Width = $Form.label_width - (2*$Form.margin)
    $l.Height = $c.Height = $Form.row_height
    $Form.Form.Controls.Add($l)
    $rows = 1
    $Form.slot += $rows
    $Form.Form.Controls.Add($c)
    $Form.Form.ClientSize = "$($Form.width), $($Form.Form.ClientSize.height + ($Form.row_height * $rows))"
    return $c
}

function Add-PasswordBox {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [Parameter(Mandatory=$true)][string]$Label,
        [scriptblock]$Callback
    )
    <#
        .SYNOPSIS
        Add a Password Entry control, and label, to an existing QuickForm.
        .DESCRIPTION
        Returns a TextBox object.
        .EXAMPLE
        $myPassword = Add-PasswordBox -Form $demo -Label "Password:" -Callback { Write-Host $this.Text }
        .PARAMETER Form
        Form to add the control and label to.
        .PARAMETER Label
        Label for the control.
        .PARAMETER Callback
        Optional Scriptblock to call when the TextChanged event occurs.
    #>
    $c = New-Object system.Windows.Forms.TextBox
    $c.Multiline = $false
    $c.Location = New-Object System.Drawing.Point(($Form.label_width + $Form.margin), ($Form.row_height * $Form.slot))
    $c.PasswordChar = "*"
    $c.width = $Form.control_width - (2*$Form.margin)
    if ($null -ne $callback) { $c.Add_TextChanged($callback) }
    $l = New-Object System.Windows.Forms.Label
    $l.text = $label
    $l.AutoSize = $false
    $l.Location = New-Object System.Drawing.Point(($Form.margin), ($Form.row_height * $Form.slot))
    $l.Width = $Form.label_width - (2*$Form.margin)
    $l.Height = $c.Height = $Form.row_height
    $Form.Form.Controls.Add($l)
    $rows = 1
    $Form.slot += $rows
    $Form.Form.Controls.Add($c)
    $Form.Form.ClientSize = "$($Form.width), $($Form.Form.ClientSize.height + ($Form.row_height * $rows))"
    return $c
}

function Add-CheckBox {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [Parameter(Mandatory=$true)][string]$Label,
        [scriptblock]$Callback
    )
    <#
        .SYNOPSIS
        Add a CheckBox control, and label, to an existing QuickForm.
        .DESCRIPTION
        Returns a CheckBox object.
        .EXAMPLE
        $myCheckBox = Add-CheckBox -Form $demo -Label "Male?" -Callback { Write-Host $this.Checked }
        .PARAMETER Form
        Form to add the control and label to.
        .PARAMETER Label
        Label for the control (in the right-hand controls column, unlike other control types).
        .PARAMETER Callback
        Optional Scriptblock to call when the CheckedChanged event occurs.
    #>
    $c = New-Object system.Windows.Forms.CheckBox
    $c.text = $label
    $c.Width = $Form.control_width - (2*$Form.margin)
    $c.Height = $Form.row_height
    $c.Location = New-Object System.Drawing.Point(($Form.label_width + $Form.margin), ($Form.row_height * $Form.slot))
    if ($null -ne $callback) { $c.Add_CheckedChanged($callback) }
    $rows = 1
    $Form.slot += $rows
    $Form.Form.Controls.Add($c)
    $Form.Form.ClientSize = "$($Form.width), $($Form.Form.ClientSize.height + ($Form.row_height * $rows))"
    return $c
}

function Add-ComboBox {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [Parameter(Mandatory=$true)][string]$Label,
        [array]$Options = @(),
        [scriptblock]$Callback
    )
    <#
        .SYNOPSIS
        Add a ComboBox control, and label, to an existing QuickForm.
        .DESCRIPTION
        Returns a ComboBox object.
        .EXAMPLE
        $myCombo = Add-ComboBox -Form $demo -Label "Gender" -Options @("Male", "Female") -Callback { Write-Host $this.SelectedItem }
        .PARAMETER Form
        Form to add the control and label to.
        .PARAMETER Label
        Label for the control.
        .PARAMETER Options
        Optional Array of options to populate the combo box with.
        .PARAMETER Callback
        Optional Scriptblock to call when the SelectedValueChanged event occurs.
    #>
    $c = New-Object System.Windows.Forms.ComboBox
    $options | ForEach-Object{ [void] $c.Items.Add($_) }
    $c.Location = New-Object System.Drawing.Point(($Form.label_width + $Form.margin), ($Form.row_height * $Form.slot))
    $c.width = $Form.control_width - (2*$Form.margin)
    if ($null -ne $callback) { $c.Add_SelectedValueChanged( $callback ) }
    $l = New-Object System.Windows.Forms.Label
    $l.text = $label
    $l.AutoSize = $false
    $l.Location = New-Object System.Drawing.Point(($Form.margin), ($Form.row_height * $Form.slot))
    $l.Width = $Form.label_width - (2*$Form.margin)
    $l.Height = $c.Height = $Form.row_height
    $Form.Form.Controls.Add($l)
    $rows = 1
    $Form.slot += $rows
    $Form.Form.Controls.Add($c)
    $Form.Form.ClientSize = "$($Form.width), $($Form.Form.ClientSize.height + ($Form.row_height * $rows))"
    return $c
}

function Add-ListBox {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [Parameter(Mandatory=$true)][string]$Label,
        [int]$Rows = 3,
        [array]$Options = @(),
        [scriptblock]$Callback,
        [array]$Buttons
    )
    <#
        .SYNOPSIS
        Add a ListBox control, label and optionally buttons, to an existing QuickForm.
        .DESCRIPTION
        Returns a ListBox object.
        .EXAMPLE
        $myList = Add-ListBox -Form $demo -Label "List:" -Rows 4 -Options @("First item") -Callback { Write-Host $this.SelectedItem } -Buttons @( @{name="Add"; callback={}}, @{name="Remove"; callback={}})
        .PARAMETER Form
        Form to add the control and label to.
        .PARAMETER Label
        Label for the control.
        .PARAMETER Options
        Optional Array of options to populate the list box with.
        .PARAMETER Rows
        Optional number of list rows to display (Default = 3).
        .PARAMETER Callback
        Optional Scriptblock to call when the SelectedValueChanged event occurs.
        .PARAMETER Buttons
        Optional array of buttons to display below the list e.g.
        @( @{name="Add"; callback={}}, @{name="Remove"; callback={}})
    #>
    $c = New-Object System.Windows.Forms.ListBox
    $options | ForEach-Object{ [void] $c.Items.Add($_) }
    $c.Location = New-Object System.Drawing.Point(($Form.label_width + $Form.margin), ($Form.row_height * $Form.slot))
    $c.width = $Form.control_width - (2*$Form.margin)
    if ($null -ne $callback) { $c.Add_SelectedValueChanged( $callback ) }
    $c.Height = $Form.row_height * $rows
    $l = New-Object System.Windows.Forms.Label
    $l.text = $label
    $l.AutoSize = $false
    $l.Location = New-Object System.Drawing.Point(($Form.margin), ($Form.row_height * $Form.slot))
    $l.Width = $Form.label_width - (2*$Form.margin)
    $l.Height = $Form.row_height
    $Form.Form.Controls.Add($l)
    if ($buttons) {
        $x = $Form.label_width + $Form.margin
        $buttons | ForEach-Object{
            $b = New-Object System.Windows.Forms.Button
            $b.Location = New-Object System.Drawing.Point($x, ($Form.row_height * ($Form.slot + $rows)))
            $b.Height = $Form.row_height
            $b.Text = $_.name
            if ($null -ne $_.callback) { $b.Add_Click( $_.callback ) }
            $Form.Form.Controls.Add($b)
            $x += $b.Size.Width
        }
        $rows += 1
    }
    $Form.slot += $rows
    $Form.Form.Controls.Add($c)
    $Form.Form.ClientSize = "$($Form.width), $($Form.Form.ClientSize.height + ($Form.row_height * $rows))"
    return $c
}

function Add-Action {
   <#
        .SYNOPSIS
        Add OK & Cancel buttons to an existing QuickForm.
        .DESCRIPTION
        Returns nothing.
        .EXAMPLE
        Add-Action -Form $demo -Callback {Write-Host "OK pressed"}
        .PARAMETER Form
        Form to add the controls to.
        .PARAMETER Callback
        Optional Scriptblock to call when the OK button is clicked.
    #>
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [scriptblock]$Callback
    )
    $ok = New-Object system.Windows.Forms.Button
    $ok.text = "OK"
    $ok.location = New-Object System.Drawing.Point(($Form.width - 120 - ($Form.margin *2)   ), ($Form.row_height * $Form.slot))
    $cancel = New-Object system.Windows.Forms.Button
    $cancel.text = "Cancel"
    $cancel.location = New-Object System.Drawing.Point(($Form.width - 60 - $Form.margin), ($Form.row_height * $Form.slot))
    $cancel.Width = $ok.Width = 60
    $cancel.Height = $ok.Height = $Form.row_height
    $Form.Form.Controls.Add($ok)
    $Form.Form.Controls.Add($cancel)
    if ($null -ne $callback) {
        $ok.Add_Click($callback)
    } else {
        $ok.Add_Click({ $Form.parent.Close() })
    }
    $cancel.Add_Click({ $Form.parent.Close() })
}