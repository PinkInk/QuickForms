#
# QuickForms.psm1
# ===============
# Quick and dirty 2 column powershell forms
#

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

function Add-Title {

    <#
        .SYNOPSIS
        Add a title row, to an existing QuickForm.
        .DESCRIPTION
        Returns a Label object.
        .EXAMPLE
        Add-Title -Form $demo -Label "A new section of the form" | Out-Null
        .PARAMETER Form
        Form to add the control and label to, accepted on the pipeline.
        .PARAMETER Label
        Optional label text.
        .PARAMETER Bold
        Optionally render the label text as Bold.
        .PARAMETER Italic
        Optionally render the label text as Italic.
    #>

    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [string]$Label,
        [Switch]$Bold,
        [Switch]$Italic
    )

    $LabelControl = New-Object System.Windows.Forms.Label
    $LabelControl.text = $label
    $LabelControl.AutoSize = $false
    $LabelControl.Location = New-Object System.Drawing.Point(
        $Form.margin,
        ($Form.row_height * $Form.slot)
    )
    $LabelControl.Width = $Form.label_width + $Form.control_width
    $LabelControl.Height = $Form.row_height
    $Form.Form.Controls.Add($LabelControl)

    if ($Bold -or $Italic) {
        if ($Bold) { $Style += [System.Drawing.FontStyle]::Bold }
        if ($Italic) { $Style += [System.Drawing.FontStyle]::Italic }
        $labelControl.Font = [System.Drawing.Font]::new(
            $LabelControl.Font.FontFamily, 
            $LabelControl.Font.Size, 
            $Style
        )
    }

    $Rows = 1
    $Form.slot += $Rows
    $Form.Form.ClientSize = "$($Form.width), $($Form.Form.ClientSize.height + ($Form.row_height * $Rows))"

    return $LabelControl

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
        Form to add the control and label to, accepted on the pipeline.
        .PARAMETER Label
        Label for the control.
        .PARAMETER Mask
        Optional text input mask refer https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.maskedtextbox.mask?view=windowsdesktop-6.0 for syntax.
        .PARAMETER Callback
        Optional Scriptblock to call when the TextChanged event occurs.
        .PARAMETER Text
        Optionally set initial TextBox Text value.
        .PARAMETER Disabled
        Optional switch to disable control.
        .PARAMETER Lockable
        Optionally allow the textbox to be locked/unlocked via an accompanying checkbox, to allow overriding a normally calculated value.
        .PARAMETER Rows
        Optionally add a multiLine text box with specified number of rows.
        .PARAMETER Text
        Optionally initialise the controls .Text value.
    #>

    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [string]$Label,
        [string]$Mask,
        [switch]$Password,
        [int32]$Rows = 1,
        [scriptblock]$Callback,
        [Switch]$Disabled,
        [string]$Text,
        [Switch]$Lockable
    )

    if ($Mask) { $Rows = 1 } # multiline ignored with mask param

    $Panel = New-Object System.Windows.Forms.Panel
    $Panel.Location = New-Object System.Drawing.Point(
        ($Form.label_width + $Form.margin),
        ($Form.row_height * $Form.slot)
    )
    $Panel.width = $Form.control_width - (2*$Form.margin)
    $Panel.Height = $Form.row_height * $Rows
    $Form.Form.Controls.Add($Panel)

    $TextBoxOffset = 0
    if ($Lockable) {
        $Lock = New-Object system.Windows.Forms.CheckBox
        $Lock.Location = New-Object System.Drawing.Point(0,0)
        if (!$Disabled) { $Lock.Checked = $true }
        $Lock.AutoSize = $true
        $Panel.Controls.Add($Lock)
        $TextBoxOffset = $Lock.Width
        $Lock.Add_CheckedChanged({
            $TextBox = $this.parent.Controls | Where-Object { 
                $_.GetType().Name -eq "TextBox" -or
                $_.GetType().Name -eq "MaskedTextBox" 
            }
            $TextBox.Enabled = !$TextBox.Enabled
        })
    }

    if ($Mask) {
        $Control = New-Object system.Windows.Forms.MaskedTextBox
        $Control.Mask = $Mask
    } else {
        $Control = New-Object system.Windows.Forms.TextBox
    }
    $Control.Location = New-Object System.Drawing.Point($TextBoxOffset,0)
    $Control.width = $Form.control_width - (2 * $Form.margin) - $TextBoxOffset
    if ($Rows -gt 1 -and -not $Mask) { 
        $Control.Multiline = $true 
    } else { 
        $Control.Multiline = $false
    }
    $Control.Height = $Form.row_height * $Rows
    if ($Password) { $Control.PasswordChar = "*" }
    if ($Disabled) { $Control.Enabled = $false }
    if ($Text) { $Control.Text = $Text }
    if ($null -ne $callback) {
        $Control.Add_TextChanged($callback)
    }
    $Panel.Controls.Add($Control)

    if ($Label) { $Form | Add-Label -Label $Label }

    $Form.slot += $Rows
    $Form.Form.ClientSize = "$($Form.width), $($Form.Form.ClientSize.height + ($Form.row_height * $Rows))"

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
        .PARAMETER Disabled
        Optional switch to disable control.
        .PARAMETER Checked
        Optionally set the initial state of the checkBox to Checked (default state: Unchecked) 
    #>

    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [Parameter(Mandatory=$true)][string]$Label,
        [scriptblock]$Callback,
        [Switch]$Disabled,
        [Switch]$Checked
    )

    $Control = New-Object system.Windows.Forms.CheckBox
    $Control.Width = $Form.control_width - (2 * $Form.margin)
    $Control.Height = $Form.row_height
    $Control.Location = New-Object System.Drawing.Point(
        ($Form.label_width + $Form.margin),
        ($Form.row_height * $Form.slot)
    )
    $Control.text = $label
    if ($Disabled) { $Control.Enabled = $false }
    if ($Checked) { $Control.Checked = $true }
    if ($null -ne $callback) {
        $Control.Add_CheckedChanged($callback)
    }
    $Form.Form.Controls.Add($Control)

    $Rows = 1
    $Form.slot += $Rows
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
        .PARAMETER Disabled
        Optional switch to disable control.
        .PARAMETER SelectedItem
        Optionally set the selected item by name/text.
        .PARAMETER SelectedIndex
        Optionally set the selected item by index, takes precedence over .SelectedItem if both set.
    #>

    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [string]$Label,
        [array]$Options = @(),
        [scriptblock]$Callback,
        [Switch]$Disabled,
        [string]$SelectedItem,
        [int32]$SelectedIndex = -1
    )

    $Control = New-Object System.Windows.Forms.ComboBox
    $Control.width = $Form.control_width - (2 * $Form.margin)
    $Control.Height = $Form.row_height
    $Control.Location = New-Object System.Drawing.Point(
        ($Form.label_width + $Form.margin),
        ($Form.row_height * $Form.slot)
    )
    $options | ForEach-Object{ [void] $Control.Items.Add($_) }
    if ($Disabled) { $Control.Enabled = $false }
    if ($SelectedItem) { $Control.SelectedItem = $SelectedItem }
    if ($SelectedIndex -gt -1) { $Control.SelectedIndex = $SelectedIndex }
    if ($null -ne $callback) {
        $Control.Add_SelectedValueChanged( $callback )
    }
    $Form.Form.Controls.Add($Control)

    if ($Label) { $Form | Add-Label -Label $Label }

    $Rows = 1
    $Form.slot += $Rows
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
        .PARAMETER Disabled
        Optional switch to disable control.
        .PARAMETER SelectedItem
        Optionally set the selected item by name/text.
    #>

    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [string]$Label,
        [Parameter(Mandatory=$true)][array]$Options,
        [switch]$Horizontal,
        [scriptblock]$Callback,
        [Switch]$Disabled,
        [string]$SelectedItem
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
            if ($SelectedItem) { 
                if ($_ -eq $SelectedItem) { $Control.Checked = $true } 
            }
            if ($Disabled) { $Control.Enabled = $false }
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
            $Control.Location = New-Object System.Drawing.Point(
                0, 
                ($Form.row_height * $rows)
            )
            $Control.width = $Form.control_width - (2 * $Form.margin)
            $Control.height = $Form.row_height
            $Control.Text = $_
            if ($SelectedItem) { 
                if ($_ -eq $SelectedItem) { $Control.Checked = $true } 
            }
            if ($Disabled) { $Control.Enabled = $false }
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
        Returns a ListBox object, or CheckedListBox if -Checkable option specified.
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
        .PARAMETER Checkable
        Optionally show checkboxes next to each item.
        .PARAMETER Callback
        Optional Scriptblock to call when the SelectedValueChanged event occurs.
        .PARAMETER Buttons
        Optional array of buttons to display below the list e.g.
        @( @{name="Add"; callback={}}, @{name="Remove"; callback={}})
        .PARAMETER SelectedItem
        Optionally set the selected item by name/text.
        .PARAMETER SelectedIndex
        Optionally set the selected item by index, takes precedence over .SelectedItem if both set.
    #>

    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [string]$Label,
        [int]$Rows = 3,
        [array]$Options = @(),
        [switch]$Checkable,
        [scriptblock]$Callback,
        [array]$Buttons,
        [string]$SelectedItem,
        [int32]$SelectedIndex = -1
    )

    if ($Checkable) {
        $Control = New-Object System.Windows.Forms.CheckedListBox
        $Control.CheckOnClick = $true
    } else {
        $Control = New-Object System.Windows.Forms.ListBox
    }
    $Control.Location = New-Object System.Drawing.Point(
        ($Form.label_width + $Form.margin),
        ($Form.row_height * $Form.slot)
    )
    $Control.width = $Form.control_width - (2 * $Form.margin)
    $Control.Height = $Form.row_height * $rows
    $options | ForEach-Object{ [void] $Control.Items.Add($_) }
    if ($SelectedItem) { $Control.SelectedItem = $SelectedItem }
    if ($SelectedIndex -gt -1) { $Control.SelectedIndex = $SelectedIndex }
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
        .PARAMETER Disabled
        Optional switch to disable control. 
    #>

    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [string]$Label,
        [ValidateNotNullOrEmpty()][ValidateSet('Date','Time','DateTime')][string]$Type = "Date",
        [datetime]$DateTime,
        [scriptblock]$Callback,
        [Switch]$Disabled
    )

    $Control = New-Object system.Windows.Forms.DateTimePicker
    $Control.Location = New-Object System.Drawing.Point(
        ($Form.label_width + $Form.margin),
        ($Form.row_height * $Form.slot)
    )
    $Control.Height = $Form.row_height
    if ( $Type -eq "Time" ) {
        $Control.Format = "Custom"
        $Control.CustomFormat = (Get-Culture).DateTimeFormat.ShortTimePattern
        $Control.ShowUpDown = $true
    } elseif ( $Type -eq "DateTime" ) {
        $Control.Format = "Custom"
        $Control.CustomFormat = (Get-Culture).DateTimeFormat.FullDateTimePattern
        # setting width appears only required for long date-time format
        $Control.width = $Form.control_width - (2 * $Form.margin)
    } # Date is control default
    if ( $DateTime ) {
        $Control.Value = $DateTime
    }
    if ($Disabled) { $Control.Enabled = $false }
    if ($null -ne $callback) {
        $Control.Add_ValueChanged($callback)
    }
    $Form.Form.Controls.Add($Control)

    if ($Label) { $Form | Add-Label -Label $Label }

    $Rows = 1
    $Form.slot += $Rows
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

    $Rows = 1
    $Form.slot += $Rows
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