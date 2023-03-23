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
    hidden [int32]$width = $label_width + $control_width + (2 * $margin)
    hidden [int32]$row_height = 25
    hidden [int32]$margin = 5

    # constructor
    QuickForm(
        [string]$Title,
        [int32]$LabelWidth = 200,
        [int32]$ControlWidth = 400,
        [int32]$RowHeight = 25
    ) {
        $this.Form = New-Object system.Windows.Forms.Form
        $this.label_width = $LabelWidth
        $this.control_width = $ControlWidth
        $this.width = $LabelWidth + $ControlWidth + (2 * $this.margin)
        $this.row_height = $RowHeight
        $this.Form.ClientSize = "$($this.width), 0"
        $this.Form.text = $Title
        $this.Form.BackColor = "#ffffff"
        $this.Form.TopMost = $false
        $this.Form.FormBorderStyle = 3 # FixedDialog 
        $this.Form.MaximizeBox = $false
    }

    # show the dialog
    Show() { $this.Form.ShowDialog() }

    # hide the dialog
    Hide() { $this.Form.Hide() }

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

        Default - 200 pixels.

        .PARAMETER ControlWidth
        Width of the controls column in pixels.

        Default - 400 pixels.

    #>

    param (
        [string]$Title = "My Form",
        [int32]$LabelWidth = 200,
        [int32]$ControlWidth = 400,
        [int32]$RowHeight = 25,
        [switch]$NoControlBox
    )

    $form = New-Object QuickForm($Title, $LabelWidth, $ControlWidth, $RowHeight)

    if ( $NoControlBox ) {
        $form.Form.ControlBox = $false
    }

    return $form

}

# 
# Internal - Add Row panel, to contain label(s) and control(s)
# 
function Add-Panel {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [string]$Rows = 1
    )

    $Panel = New-Object System.Windows.Forms.Panel

    $Panel.Location = New-Object System.Drawing.Point(
        ($Form.margin),
        ($Form.row_height * $Form.slot)
    )
    $Panel.width = $Form.Width - (2 * $Form.margin)
    $Panel.Height = $Form.row_height * $Rows

    $Form.slot += $Rows
    $Form.Form.ClientSize = "$($Form.width), $($Form.Form.ClientSize.height + ($Form.row_height * $Rows))"

    $Form.Form.Controls.Add($Panel)

    return $Panel
}

# 
# Internal - add Label to panel
# 
function Add-Label {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [Parameter(Mandatory=$true)][object]$Panel,
        [string]$Label
    )
    $LabelControl = New-Object System.Windows.Forms.Label
    $LabelControl.text = $label
    $LabelControl.AutoSize = $false
    $LabelControl.Location = New-Object System.Drawing.Point(0, 0)
    $LabelControl.Width = $Form.label_width
    $LabelControl.Height = $Form.row_height
    $Panel.Controls.Add($LabelControl)
}

# 
# External - add panel containing title row (form width label)
# 
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

    $Panel = Add-Panel -Form $Form -Rows 1

    $LabelControl = New-Object System.Windows.Forms.Label

    $LabelControl.AutoSize = $false
    $LabelControl.Location = New-Object System.Drawing.Point(0, 0)
    $LabelControl.Width = $Panel.Width
    $LabelControl.Height = $Panel.Height

    $LabelControl.text = $label

    if ($Bold -or $Italic) {
        if ($Bold) { $Style += [System.Drawing.FontStyle]::Bold }
        if ($Italic) { $Style += [System.Drawing.FontStyle]::Italic }
        $LabelControl.Font = [System.Drawing.Font]::new(
            $LabelControl.Font.FontFamily, 
            $LabelControl.Font.Size, 
            $Style
        )
    }

    $Panel.Controls.Add($LabelControl)

    return $LabelControl

}

# 
# External - add panel containing label & textbox
# 
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
        .PARAMETER ActionButton
        Optionally add a button control to the right of the textbox and bind this callback to its Click event.
        .PARAMETER ActionButtonText
        Text for button control (defaults to '>')
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
        [Switch]$Lockable,
        [scriptblock]$ActionButton,
        [string]$ActionButtonText = ">"
    )

    if ($Mask) { $Rows = 1 } # multiline ignored with mask param

    $Panel = Add-Panel -Form $Form -Rows $Rows

    $TextBoxLeftOffset = 0
    $TextBoxRightOffset = 0

    if ($Lockable) {
        $Lock = New-Object system.Windows.Forms.CheckBox
        $Lock.Location = New-Object System.Drawing.Point($Form.label_width, 0)
        if (!$Disabled) { $Lock.Checked = $true }
        $Lock.AutoSize = $true
        $Panel.Controls.Add($Lock)
        $TextBoxLeftOffset += $Lock.Width
        $Lock.Add_CheckedChanged({
            $TextBox = $this.parent.Controls | Where-Object { 
                $_.GetType().Name -eq "TextBox" -or
                $_.GetType().Name -eq "MaskedTextBox" 
            }
            $TextBox.Enabled = !$TextBox.Enabled
        })
    }

    if ($ActionButton) {
        $ButtonControl = New-Object system.Windows.Forms.Button
        $Panel.Controls.Add($ButtonControl) # autosize can't calc width unless added
        $ButtonControl.AutoSize = $true
        $ButtonControl.AutoSizeMode = "GrowAndShrink"
        $ButtonControl.Height = $Form.row_height
        $ButtonControl.Text = $ActionButtonText
        $ButtonControl.Location = New-Object System.Drawing.Point(
            ($Panel.Width - $ButtonControl.Width),
            0
        )
        $ButtonControl.Add_Click($ActionButton)
        $TextBoxRightOffset += $ButtonControl.Width
    }

    if ($Mask) {
        $Control = New-Object system.Windows.Forms.MaskedTextBox
        $Control.Mask = $Mask
    } else {
        $Control = New-Object system.Windows.Forms.TextBox
    }

    $Control.Location = New-Object System.Drawing.Point(
        ($Form.label_width + $TextBoxLeftOffset), 
        0
    )
    
    $Control.width = $Form.control_width - $TextBoxLeftOffset - $TextBoxRightOffset
    
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

    if ($Label) { $Form | Add-Label -Panel $Panel -Label $Label }

    return $Control

}

# 
# External - add panel containing checkbox
# 
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

    $Panel = Add-Panel -Form $Form -Rows 1

    $Control = New-Object system.Windows.Forms.CheckBox

    $Control.Width = $Form.control_width
    $Control.Height = $Form.row_height
    $Control.Location = New-Object System.Drawing.Point(
        $Form.label_width, 
        0
    )

    $Control.text = $label

    if ($Disabled) { $Control.Enabled = $false }

    if ($Checked) { $Control.Checked = $true }

    if ($null -ne $callback) {
        $Control.Add_CheckedChanged($callback)
    }

    $Panel.Controls.Add($Control)

    return $Control

}

# 
# External - add panel containing combobox
# 
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

    $Panel = Add-Panel -Form $Form -Rows 1

    $Control = New-Object System.Windows.Forms.ComboBox

    $Control.width = $Form.control_width
    $Control.Height = $Form.row_height
    $Control.Location = New-Object System.Drawing.Point($Form.label_width, 0)
    
    $options | ForEach-Object{ [void] $Control.Items.Add($_) }
    
    if ($Disabled) { $Control.Enabled = $false }
    
    if ($SelectedItem) { $Control.SelectedItem = $SelectedItem }
    
    if ($SelectedIndex -gt -1) { $Control.SelectedIndex = $SelectedIndex }
    
    if ($null -ne $callback) {
        $Control.Add_SelectedValueChanged( $callback )
    }
    
    $Panel.Controls.Add($Control)

    if ($Label) { $Form | Add-Label -Panel $Panel -Label $Label }

    return $Control

}

# 
# External - add panel containing radiobuttons
# 
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

    if ($Horizontal) { $Rows = 1 } else { $Rows = $Options.Count }

    $Panel = Add-Panel -Form $Form -Rows $Rows

    if ($Horizontal) {

        $x = $Form.label_width

        $options | ForEach-Object {

            $Control = New-Object System.Windows.Forms.RadioButton

            $Control.Location = New-Object System.Drawing.Point($x, 0)
            $Control.height = $Form.row_height
            # sets own width to maximise horizontal space utilisation

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

    } else { # default vertical layout

        $index = 0

        $options | ForEach-Object {

            $Control = New-Object System.Windows.Forms.RadioButton

            $Control.Location = New-Object System.Drawing.Point(
                $Form.label_width, 
                ($Form.row_height * $index)
            )
            $Control.width = $Form.control_width
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

            $index += 1

        }

    }

    if ($Label) { $Form | Add-Label -Panel $Panel -Label $Label }

    return $Panel

}

# 
# External - add panel containing listbox
# 
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

    if ($Buttons) {
        $Panel = Add-Panel -Form $Form -Rows ($Rows + 1)
    } else {
        $Panel = Add-Panel -Form $Form -Rows $Rows
    }

    if ($Checkable) {
        $Control = New-Object System.Windows.Forms.CheckedListBox
        $Control.CheckOnClick = $true
    } else {
        $Control = New-Object System.Windows.Forms.ListBox
    }

    $Control.Location = New-Object System.Drawing.Point(
        $Form.label_width, 
        0
    )
    $Control.width = $Form.control_width
    $Control.Height = $Form.row_height * $Rows

    $options | ForEach-Object{ [void] $Control.Items.Add($_) }

    if ($SelectedItem) { $Control.SelectedItem = $SelectedItem }

    if ($SelectedIndex -gt -1) { $Control.SelectedIndex = $SelectedIndex }

    if ($null -ne $callback) {
        $Control.Add_SelectedValueChanged( $callback )
    }

    $Panel.Controls.Add($Control)

    if ($Label) { $Form | Add-Label -Panel $Panel -Label $Label }

    if ($buttons) {

        $x = $Form.label_width

        $buttons | ForEach-Object{

            $ButtonControl = New-Object System.Windows.Forms.Button

            $ButtonControl.Location = New-Object System.Drawing.Point(
                $x,
                ($Form.row_height * $Rows)
            )
            $ButtonControl.AutoSize = $true
            $ButtonControl.AutoSizeMode = "GrowAndShrink"    
            $ButtonControl.Height = $Form.row_height

            $ButtonControl.Text = $_.name

            if ($null -ne $_.callback) {
                $ButtonControl.Add_Click( $_.callback )
            }

            $Panel.Controls.Add($ButtonControl)

            $x += $ButtonControl.Size.Width

        }

    }

    return $Control

}

# 
# External - add panel containing date time picker
# 
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

    $Panel = Add-Panel -Form $Form -Rows 1

    $Control = New-Object system.Windows.Forms.DateTimePicker

    $Control.Location = New-Object System.Drawing.Point($Form.label_width, 0)
    $Control.Height = $Form.row_height

    if ( $Type -eq "Time" ) {
        $Control.Format = "Custom"
        $Control.CustomFormat = (Get-Culture).DateTimeFormat.ShortTimePattern
        $Control.ShowUpDown = $true
    } elseif ( $Type -eq "DateTime" ) {
        $Control.Format = "Custom"
        $Control.CustomFormat = (Get-Culture).DateTimeFormat.FullDateTimePattern
        # setting width appears only required for long date-time format
        $Control.width = $Form.control_width
    } # Date is control default

    if ( $DateTime ) { $Control.Value = $DateTime }

    if ($Disabled) { $Control.Enabled = $false }

    if ($null -ne $callback) {
        $Control.Add_ValueChanged($callback)
    }

    $Panel.Controls.Add($Control)

    if ($Label) { $Form | Add-Label -Panel $Panel -Label $Label }

    return $Control

}

# 
# External - add panel containing disabled filename text box and button for file dialog
# 
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

    $Panel = Add-Panel -Form $Form -Rows 1

    $ButtonControl = New-Object system.Windows.Forms.Button

    $Panel.Controls.Add($ButtonControl) # autosize can't calc width unless added

    $ButtonControl.AutoSize = $true
    $ButtonControl.AutoSizeMode = "GrowAndShrink"
    $ButtonControl.Height = $Form.row_height

    $ButtonControl.Text = "..."

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
                $TextBox = $this.parent.Controls | Where-Object { 
                    $_.GetType().Name -eq "TextBox"
                }
                $TextBox.Text = $Dialog.FileName
            }
        })
    } else { # SaveAs
        $ButtonControl.Add_Click({
            $Dialog = New-Object System.Windows.Forms.SaveFileDialog
            if ($this.FileFilter -ne "") { $Dialog.Filter = $this.FileFilter }
            if ( $Dialog.ShowDialog() -eq "OK" ) {
                $TextBox = $this.parent.Controls | Where-Object { 
                    $_.GetType().Name -eq "TextBox"
                }
                $TextBox.Text = $Dialog.FileName
            }
        })
    }

    $Control = New-Object system.Windows.Forms.TextBox

    $Control.Enabled = $false
    $Control.Multiline = $false

    $Control.Location = New-Object System.Drawing.Point($Form.label_width, 0)
    $Control.Height = $Form.row_height
    $Control.width = $Panel.Width - $ButtonControl.Width

    if ($null -ne $callback) {
        $Control.Add_TextChanged($callback)
    }

    $Panel.Controls.Add($Control)

    if ($Label) { $Form | Add-Label -Panel $Panel -Label $Label }

    return $Control

}

# 
# External - add panel containing buttons
# 
function Add-Buttons {

    <#
        .SYNOPSIS
        Add a row of buttons, with callbacks, to the form.
        .DESCRIPTION
        Returns nothing.
        .EXAMPLE
        Add-Buttons -Form $demo -Align "Right" -Buttons @(
            @{ name="Add"; callback={},
            @{ name="Remove"; callback={}
        )
        .PARAMETER Buttons
        Array of buttons to display below the list e.g.
        @( @{name="Add"; callback={}}, @{name="Remove"; callback={}})
        .PARAMETER Align
        Optionally align the buttoms to the Left of the form, with the Label column or to the Right of the form. 
    #>

    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][object]$Form,
        [Parameter(Mandatory=$true)][array]$Buttons,
        [ValidateNotNullOrEmpty()][ValidateSet('Left','Label', 'Right')][string]$Align = "Label"
    )

    $Panel = Add-Panel -Form $Form -Rows 1

    switch ($Align) {
        "Left" { $x = 0 }
        "Right" { 
            $x = $Panel.Width 
            # reverse button array order in this case
            function Reverse { [System.Collections.Stack]::new(@($input)) }
            $Buttons = $Buttons | Reverse
        }
        "Label" { $x = $Form.label_width }
    }

    $Buttons | ForEach-Object{

        $ButtonControl = New-Object System.Windows.Forms.Button

        $ButtonControl.Text = $_.name
        $ButtonControl.AutoSize = $true
        $ButtonControl.AutoSizeMode = "GrowAndShrink"    
        $ButtonControl.Height = $Form.row_height
        $Panel.Controls.Add($ButtonControl)

        if ( $Align -eq "Right" ) { $x -= $ButtonControl.Width }

        $ButtonControl.Location = New-Object System.Drawing.Point($x, 0)

        if ($null -ne $_.callback) {
            $ButtonControl.Add_Click( $_.callback )
        }

        if ( $Align -in "Left", "Label" ) { $x += $ButtonControl.Size.Width }

    }

}

# 
# External - std Ok Cancel buttons (no panel so $this.parent.close makes sense)
# 
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

    $ButtonWidth = 60

    $Form.Form.ClientSize = "$($Form.width), $($Form.Form.ClientSize.height + $Form.row_height)"

    $ok = New-Object system.Windows.Forms.Button
    $ok.text = "OK"

    $ok.location = New-Object System.Drawing.Point(
        ($Form.width - ($ButtonWidth * 2) - ($Form.margin * 2)),
        ($Form.row_height * $Form.slot)
    )
    $ok.Width = $ButtonWidth
    $ok.Height = $Form.row_height
    
    if ($null -ne $callback) {
        $ok.Add_Click($callback)
    } else {
        $ok.Add_Click({ $this.parent.Close() })
    }
    
    $Form.Form.Controls.Add($ok)

    $cancel = New-Object system.Windows.Forms.Button
    $cancel.text = "Cancel"

    $cancel.location = New-Object System.Drawing.Point(
        ($Form.width - $ButtonWidth - $Form.margin),
        ($Form.row_height * $Form.slot)
    )
    $cancel.Width = $ButtonWidth
    $cancel.Height = $Form.row_height

    $cancel.Add_Click({ $this.parent.Close() })

    $Form.Form.Controls.Add($cancel)

}