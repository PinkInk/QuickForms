#
# QuickForms.psm1
# ===============
# Quick and dirty 2 column powershell forms
#
# History
# -------
# 27/09/2022 - v2.4.3 - Tim Pelling - let datetime set it's own width
# 27/09/2022 - v2.4.2 - Tim Pelling - fix size of FileBox button
# 25/09/2022 - v2.4.1 - Tim Pelling - factor out label placement from most cmdlets
# 25/09/2022 - v2.4.0 - Tim Pelling - render labels optional
# 25/09/2022 - v2.3.2 - Tim Pelling - bugfix Save-As FileBox scriptblock
# 19/09/2022 - v2.3.1 - Tim Pelling - bugfix date-time control.showupdown
# 19/09/2022 - v2.3.0 - Tim Pelling - add File Open/SaveAs control (FileBox)
# 19/09/2022 - v2.2.1 - Tim Pelling - refactor
# 17/09/2022 - v2.2.0 - Tim Pelling - add DateTimePicker control option
# 17/09/2022 - v2.1.0 - Tim Pelling - add RadioBox control option
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

# Internal
function Add-Label {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [string]$Label
    )
    $LabelControl = New-Object System.Windows.Forms.Label
    $LabelControl.text = $label
    $LabelControl.AutoSize = $false
    $LabelControl.Location = New-Object System.Drawing.Point(
        $Form.margin,
        ($Form.row_height * $Form.slot)
    )
    $LabelControl.Width = $Form.label_width - (2 * $Form.margin)
    $LabelControl.Height = $Form.row_height
    $Form.Form.Controls.Add($LabelControl)
}
function Add-TextBox {

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

    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [string]$Label,
        [scriptblock]$Callback
    )

    $Control = New-Object system.Windows.Forms.TextBox
    $Control.Location = New-Object System.Drawing.Point(
        ($Form.label_width + $Form.margin),
        ($Form.row_height * $Form.slot)
    )
    $Control.width = $Form.control_width - (2 * $Form.margin)
    $Control.Height = $Form.row_height
    $Control.Multiline = $false
    if ($null -ne $callback) {
        $Control.Add_TextChanged($callback)
    }
    $Form.Form.Controls.Add($Control)

    if ($Label) { $Form | Add-Label -Label $Label }

    $rows = 1
    $Form.slot += $rows
    $Form.Form.ClientSize = "$($Form.width), $($Form.Form.ClientSize.height + ($Form.row_height * $rows))"

    return $Control

}

function Add-PasswordBox {

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

    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [string]$Label,
        [scriptblock]$Callback
    )

    $Control = New-Object system.Windows.Forms.TextBox
    $Control.Location = New-Object System.Drawing.Point(
        ($Form.label_width + $Form.margin),
        ($Form.row_height * $Form.slot)
    )
    $Control.Height = $Form.row_height
    $Control.width = $Form.control_width - (2 * $Form.margin)
    $Control.PasswordChar = "*"
    $Control.Multiline = $false
    if ($null -ne $callback) {
        $Control.Add_TextChanged($callback)
    }
    $Form.Form.Controls.Add($Control)

    if ($Label) { $Form | Add-Label -Label $Label }

    $rows = 1
    $Form.slot += $rows
    $Form.Form.ClientSize = "$($Form.width), $($Form.Form.ClientSize.height + ($Form.row_height * $rows))"

    return $Control

}

function Add-CheckBox {

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

    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [Parameter(Mandatory=$true)][string]$Label,
        [scriptblock]$Callback
    )

    $Control = New-Object system.Windows.Forms.CheckBox
    $Control.Width = $Form.control_width - (2 * $Form.margin)
    $Control.Height = $Form.row_height
    $Control.Location = New-Object System.Drawing.Point(
        ($Form.label_width + $Form.margin),
        ($Form.row_height * $Form.slot)
    )
    $Control.text = $label
    if ($null -ne $callback) {
        $Control.Add_CheckedChanged($callback)
    }
    $Form.Form.Controls.Add($Control)

    $rows = 1
    $Form.slot += $rows
    $Form.Form.ClientSize = "$($Form.width), $($Form.Form.ClientSize.height + ($Form.row_height * $rows))"

    return $Control

}

function Add-ComboBox {

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

    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [string]$Label,
        [array]$Options = @(),
        [scriptblock]$Callback
    )

    $Control = New-Object System.Windows.Forms.ComboBox
    $Control.width = $Form.control_width - (2 * $Form.margin)
    $Control.Height = $Form.row_height
    $Control.Location = New-Object System.Drawing.Point(
        ($Form.label_width + $Form.margin),
        ($Form.row_height * $Form.slot)
    )
    $options | ForEach-Object{ [void] $Control.Items.Add($_) }
    if ($null -ne $callback) {
        $Control.Add_SelectedValueChanged( $callback )
    }
    $Form.Form.Controls.Add($Control)

    if ($Label) { $Form | Add-Label -Label $Label }

    $rows = 1
    $Form.slot += $rows
    $Form.Form.ClientSize = "$($Form.width), $($Form.Form.ClientSize.height + ($Form.row_height * $rows))"

    return $Control

}

function Add-RadioBox {

    <#
        .SYNOPSIS
        Add a group of RadioButton controls, and label, to an existing QuickForm.
        .DESCRIPTION
        Returns the Panel object that contains the RadioButtons - access RadioButton's through its .Controls property.
        .EXAMPLE
        $myRadioButtons = Add-RadioBox -Form $demo -Label "Radios:" -Options @("Male","Female") -Horizontal -Callback { if ($this.Checked) { Write-Host $this.Text } }
        .PARAMETER Form
        Form to add the panel, controls and label to.
        .PARAMETER Label
        Label for the panel.
        .PARAMETER Options
        Array of options - one RadioButton is added to the Panel for each option.
        .PARAMETER Callback
        Optional Scriptblock to call when the CheckedChange event occurs.

        This will be called for all RadioButtons in the set/Panel hence you must inspect the $this.Checked property to determine
        whether any particular RadioButton is currently selected.
        .PARAMETER Horizontal
        Layout the RadioButton's horizontally in a single control row, but may overflow form width.

        Default is vertical, one RadioButton form row per specified Option.
    #>

    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [string]$Label,
        [Parameter(Mandatory=$true)][array]$Options,
        [switch]$Horizontal,
        [scriptblock]$Callback
    )

    $Panel = New-Object System.Windows.Forms.Panel
    $Panel.Location = New-Object System.Drawing.Point(
        ($Form.label_width + $Form.margin),
        ($Form.row_height * $Form.slot)
    )
    $Panel.width = $Form.control_width - (2*$Form.margin)
    $Form.Form.Controls.Add($Panel)

    if ($Horizontal) {
        $x = 0
        $options | ForEach-Object {
            $Control = New-Object System.Windows.Forms.RadioButton
            $Control.Location = New-Object System.Drawing.Point($x, 0)
            $Control.height = $Form.row_height
            $Control.Text = $_
            if ($null -ne $callback) {
                $Control.Add_CheckedChanged( $callback )
            }
            $Panel.Controls.Add($Control)
            $x += $Control.width
        }
        $rows = 1
    } else { # default vertical layout
        $rows = 0
        $options | ForEach-Object {
            $Control = New-Object System.Windows.Forms.RadioButton
            $Control.Location = New-Object System.Drawing.Point(0, ($Form.row_height * $rows))
            $Control.width = $Form.control_width - (2 * $Form.margin)
            $Control.height = $Form.row_height
            $Control.Text = $_
            if ($null -ne $callback) {
                $Control.Add_CheckedChanged( $callback )
            }
            $Panel.Controls.Add($Control)
            $rows += 1
        }
    }

    if ($Label) {
        $LabelControl = New-Object System.Windows.Forms.Label
        $LabelControl.text = $label
        $LabelControl.AutoSize = $false
        $LabelControl.Location = New-Object System.Drawing.Point(
            $Form.margin,
            ($Form.row_height * $Form.slot)
        )
        $LabelControl.Width = $Form.label_width - (2 * $Form.margin)
        $LabelControl.Height = $Panel.Height = $Form.row_height * $rows
        $Form.Form.Controls.Add($LabelControl)
    }

    $Form.slot += $rows
    $Form.Form.ClientSize = "$($Form.width), $($Form.Form.ClientSize.height + ($Form.row_height * $rows))"

    return $Panel

}

function Add-ListBox {

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

    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [string]$Label,
        [int]$Rows = 3,
        [array]$Options = @(),
        [scriptblock]$Callback,
        [array]$Buttons
    )

    $Control = New-Object System.Windows.Forms.ListBox
    $Control.Location = New-Object System.Drawing.Point(
        ($Form.label_width + $Form.margin),
        ($Form.row_height * $Form.slot)
    )
    $Control.width = $Form.control_width - (2 * $Form.margin)
    $Control.Height = $Form.row_height * $rows
    $options | ForEach-Object{ [void] $Control.Items.Add($_) }
    if ($null -ne $callback) {
        $Control.Add_SelectedValueChanged( $callback )
    }
    $Form.Form.Controls.Add($Control)

    if ($Label) { $Form | Add-Label -Label $Label }

    if ($buttons) {
        $x = $Form.label_width + $Form.margin
        $buttons | ForEach-Object{
            $ButtonControl = New-Object System.Windows.Forms.Button
            $ButtonControl.Location = New-Object System.Drawing.Point(
                $x,
                ($Form.row_height * ($Form.slot + $rows))
            )
            $ButtonControl.Height = $Form.row_height
            $ButtonControl.Text = $_.name
            if ($null -ne $_.callback) {
                $ButtonControl.Add_Click( $_.callback )
            }
            $Form.Form.Controls.Add($ButtonControl)
            $x += $ButtonControl.Size.Width
        }
        $rows += 1
    }

    $Form.slot += $rows
    $Form.Form.ClientSize = "$($Form.width), $($Form.Form.ClientSize.height + ($Form.row_height * $rows))"

    return $Control

}

function Add-DateTimePicker {
    <#
        .SYNOPSIS
        Add a DateTimePicker control, and label, to an existing QuickForm.
        .DESCRIPTION
        Returns a DateTimePicker object.
        .EXAMPLE
        $MyDateTime = Add-DateTimePicker -Form $demo -Label "Date:" -Type Date -DateTime (Get-Date -Year 1999 -Month 12 -Day 3) -Callback { Write-Host $this.Value }
        .PARAMETER Form
        Form to add the control and label to.
        .PARAMETER Label
        Label for the control.
        .PARAMETER Type
        Date (default), Time or DateTime.
        .PARAMETER DateTime
        Initial DateTime for the control, via Get-Date.
        .PARAMETER Callback
        Optional Scriptblock to call when the ValueChanged event occurs.
    #>

    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [string]$Label,
        [ValidateNotNullOrEmpty()][ValidateSet('Date','Time','DateTime')][string]$Type = "Date",
        [datetime]$DateTime,
        [scriptblock]$Callback
    )

    $Control = New-Object system.Windows.Forms.DateTimePicker
    $Control.Location = New-Object System.Drawing.Point(
        ($Form.label_width + $Form.margin),
        ($Form.row_height * $Form.slot)
    )
    # $Control.width = $Form.control_width - (2 * $Form.margin)
    $Control.Height = $Form.row_height
    if ( $Type -eq "Time" ) {
        $Control.Format = "Custom"
        $Control.CustomFormat = (Get-Culture).DateTimeFormat.ShortTimePattern
        $Control.ShowUpDown = $true
    } elseif ( $Type -eq "DateTime" ) {
        $Control.Format = "Custom"
        $Control.CustomFormat = (Get-Culture).DateTimeFormat.FullDateTimePattern
    } # Date is control default
    if ( $DateTime ) {
        $Control.Value = $DateTime
    }
    if ($null -ne $callback) {
        $Control.Add_ValueChanged($callback)
    }
    $Form.Form.Controls.Add($Control)

    if ($Label) { $Form | Add-Label -Label $Label }

    $rows = 1
    $Form.slot += $rows
    $Form.Form.ClientSize = "$($Form.width), $($Form.Form.ClientSize.height + ($Form.row_height * $rows))"

    return $Control

}

function Add-FileBox {

    <#
        .SYNOPSIS
        Add a File Open or SaveAs control, and label, to an existing QuickForm.
        .DESCRIPTION
        Returns the TextBox object that is populated with selected file path & name when the corresponding Dialog boxes OK button is clicked.
        .EXAMPLE
        $myFileOpen = Add-FileBox -Form $demo -Label "Open file:" -Type "Open" -FileFilter "txt files (*.txt)|*.txt|All files (*.*)|*.*" -Callback { Write-Host $MyFileOpen.Text }
        .PARAMETER Form
        Form to add the panel, controls and label to.
        .PARAMETER Label
        Label for the panel.
        .PARAMETER Type
        Either "Open" (default) or "SaveAs"
        .PARAMETER FileFilter
        Optional FileFilter string as required by the OpenFileDialog and SaveFileDialog widgets.

        e.g. "txt files (*.txt)|*.txt|All files (*.*)|*.*"
        .PARAMETER Callback
        Optional Scriptblock to call when the TextBox's TextChanged event occurs.
    #>

    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [string]$Label,
        [ValidateNotNullOrEmpty()][ValidateSet('Open','SaveAs')][string]$Type = "Open",
        [String]$FileFilter,
        [scriptblock]$Callback
    )

    $Panel = New-Object System.Windows.Forms.Panel
    $Panel.Location = New-Object System.Drawing.Point(
        ($Form.label_width + $Form.margin),
        ($Form.row_height * $Form.slot)
    )
    $Panel.width = $Form.control_width - (2*$Form.margin)
    $Panel.Height = $Form.row_height
    $Form.Form.Controls.Add($Panel)

    $ButtonControl = New-Object system.Windows.Forms.Button
    $Panel.Controls.Add($ButtonControl)
    $ButtonControl.AutoSize = $true
    $ButtonControl.AutoSizeMode = "GrowAndShrink"
    $ButtonControl.Text = "..."
    $ButtonControl.Height = $Form.row_height
    $ButtonControl.Location = New-Object System.Drawing.Point(
        ($Panel.Width - $ButtonControl.Width),
        0
    )
    $ButtonControl | Add-Member -NotePropertyName FileFilter -NotePropertyValue $FileFilter
    if ($Type -eq "Open") {
        $ButtonControl.Add_Click({
            $Dialog = New-Object system.Windows.Forms.OpenFileDialog
            if ($this.FileFilter -ne "") { $Dialog.Filter = $this.FileFilter }
            if ( $Dialog.ShowDialog() -eq "OK" ) {
                $TextBox = $this.parent.Controls | Where-Object { $_.GetType().Name -eq "TextBox"}
                $TextBox.Text = $Dialog.FileName
            }
        })
    } else { # SaveAs
        $ButtonControl.Add_Click({
            $Dialog = New-Object System.Windows.Forms.SaveFileDialog
            if ($this.FileFilter -ne "") { $Dialog.Filter = $this.FileFilter }
            if ( $Dialog.ShowDialog() -eq "OK" ) {
                $TextBox = $this.parent.Controls | Where-Object { $_.GetType().Name -eq "TextBox"}
                $TextBox.Text = $Dialog.FileName
            }
        })
    }

    $Control = New-Object system.Windows.Forms.TextBox
    $Control.Location = New-Object System.Drawing.Point(0, 0)
    $Control.Height = $Form.row_height
    $Control.width = $Panel.Width - $ButtonControl.Width - $Form.margin
    $Control.Enabled = $false
    $Control.Multiline = $false
    if ($null -ne $callback) {
        $Control.Add_TextChanged($callback)
    }
    $Panel.Controls.Add($Control)

    if ($Label) { $Form | Add-Label -Label $Label }

    $rows = 1
    $Form.slot += $rows
    $Form.Form.ClientSize = "$($Form.width), $($Form.Form.ClientSize.height + ($Form.row_height * $rows))"

    return $Control
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
    $ok.location = New-Object System.Drawing.Point(
        ($Form.width - 120 - ($Form.margin * 2)),
        ($Form.row_height * $Form.slot)
    )
    if ($null -ne $callback) {
        $ok.Add_Click($callback)
    } else {
        $ok.Add_Click({ $this.parent.Close() })
    }
    $Form.Form.Controls.Add($ok)

    $cancel = New-Object system.Windows.Forms.Button
    $cancel.text = "Cancel"
    $cancel.location = New-Object System.Drawing.Point(
        ($Form.width - 60 - $Form.margin),
        ($Form.row_height * $Form.slot)
    )
    $cancel.Width = $ok.Width = 60
    $cancel.Height = $ok.Height = $Form.row_height
    $cancel.Add_Click({ $this.parent.Close() })
    $Form.Form.Controls.Add($cancel)

}