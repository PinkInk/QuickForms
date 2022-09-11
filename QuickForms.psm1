#
# QuickForms.psm1
# ===============
# Quick and dirty 2 column powershell forms
#
# History
# -------
# 25/08/2022 - v7 - Tim Pelling - adopt system default font
# 17/08/2022 - v6 - Tim Pelling - remove control name requirement
# 01/07/2022 - v5 - Tim Pelling - return rather than magically create objects
#                                 unhide child form object
#                                 modified argument order for AddRow(s), bring type to front
#                                 added listbox, with buttons
# 30/06/2022 - v4 - Tim Pelling - allow different label and column widths
# 29/08/2019 - v3 - Tim Pelling - update AddAction behaviour for flexibility
# 29/08/2019 - v2 - Tim Pelling - added module manifest, PasswordBox as discrete type
# 28/08/2019 - v1 - Tim Pelling - make widget variable declarations global
# 26/08/2019 - v0 - Tim Pelling - First Issue

[System.Windows.Forms.Application]::EnableVisualStyles()

enum ControlTypes {
    TextBox
    PasswordBox
    Checkbox
    ComboBox
    ListBox
}

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

    #
    # add-row templates
    #
    [object]AddRow(
        [ControlTypes]$ControlType,
        [string]$label
    ) { return $this.DoAddRow($ControlType, $label, $null, $null, $null, $null) }

    # callback
    [object]AddRow( 
        [ControlTypes]$ControlType,
        [string]$label,
        [scriptblock]$callback
    ) { return $this.DoAddRow($ControlType, $label, $callback, $null, $null, $null) }

    # combo box, without callback
    [object]AddRow(
        [ControlTypes]$ControlType,
        [string]$label,
        [array]$options
    ) { return $this.DoAddRow($ControlType, $label, $null, $options, $null, $null) }

    # combo box, with callback
    [object]AddRow(
        [ControlTypes]$ControlType,
        [string]$label,
        [array]$options,
        [scriptblock]$callback
    ) { return $this.DoAddRow($ControlType, $label, $callback, $options, $null, $null) }

    # list box, options ( may be empty e.g. @() ), callback, no buttons
    [object]AddRow(
        [ControlTypes]$ControlType,
        [int32]$rows,
        [string]$label,
        [array]$options,
        [scriptblock]$callback
    ) { return $this.DoAddRow($ControlType, $label, $callback, $options, $rows, $null)}

    # list box, options ( may be empty e.g. @() ), callback, buttons
    [object]AddRow(
        [ControlTypes]$ControlType,
        [int32]$rows,
        [string]$label,
        [array]$options,
        [scriptblock]$callback,
        [array]$buttons
    ) { return $this.DoAddRow($ControlType, $label, $callback, $options, $rows, $buttons)}

    hidden [object]DoAddRow(
        [ControlTypes]$ControlType,
        [string]$label,
        [scriptblock]$callback,
        [array]$options,
        [int32]$rows,
        [array]$buttons
    ){

        # parser doesn"t think $c is defined when referred to after switch without this!
        $c = $null 

        Switch($ControlType) {

            "TextBox" {
                $c = New-Object system.Windows.Forms.TextBox
                $c.Multiline = $false
                $c.Location = New-Object System.Drawing.Point(($this.label_width + $this.margin), ($this.row_height * $this.slot))
                $c.width = $this.control_width - (2*$this.margin)
                if ($null -ne $callback) { $c.Add_TextChanged($callback) }
                $l = New-Object System.Windows.Forms.Label
                $l.text = $label
                $l.AutoSize = $false
                $l.Location = New-Object System.Drawing.Point(($this.margin), ($this.row_height * $this.slot))
                $l.Width = $this.label_width - (2*$this.margin)
                $l.Height = $c.Height = $this.row_height
                $this.Form.Controls.Add($l)
                $rows = 1
            }

            "PasswordBox" {
                $c = New-Object system.Windows.Forms.TextBox
                $c.Multiline = $false
                $c.Location = New-Object System.Drawing.Point(($this.label_width + $this.margin), ($this.row_height * $this.slot))
                $c.PasswordChar = "*"
                $c.width = $this.control_width - (2*$this.margin)
                if ($null -ne $callback) { $c.Add_TextChanged($callback) }
                $l = New-Object System.Windows.Forms.Label
                $l.text = $label
                $l.AutoSize = $false
                $l.Location = New-Object System.Drawing.Point(($this.margin), ($this.row_height * $this.slot))
                $l.Width = $this.label_width - (2*$this.margin)
                $l.Height = $c.Height = $this.row_height
                $this.Form.Controls.Add($l)
                $rows = 1
            }

            "CheckBox" {
                $c = New-Object system.Windows.Forms.CheckBox
                $c.text = $label
                $c.Width = $this.control_width - (2*$this.margin)
                $c.Height = $this.row_height
                $c.Location = New-Object System.Drawing.Point(($this.label_width + $this.margin), ($this.row_height * $this.slot))
                if ($null -ne $callback) { $c.Add_CheckedChanged($callback) }
                $rows = 1
            }

            "ComboBox" {
                $c = New-Object System.Windows.Forms.ComboBox
                $options | ForEach-Object{ [void] $c.Items.Add($_) }
                $c.Location = New-Object System.Drawing.Point(($this.label_width + $this.margin), ($this.row_height * $this.slot))
                $c.width = $this.control_width - (2*$this.margin)
                if ($null -ne $callback) { $c.Add_SelectedValueChanged( $callback ) }
                $l = New-Object System.Windows.Forms.Label
                $l.text = $label
                $l.AutoSize = $false
                $l.Location = New-Object System.Drawing.Point(($this.margin), ($this.row_height * $this.slot))
                $l.Width = $this.label_width - (2*$this.margin)
                $l.Height = $c.Height = $this.row_height
                $this.Form.Controls.Add($l)
                $rows = 1
            }

            "ListBox" {
                $c = New-Object System.Windows.Forms.ListBox
                $options | ForEach-Object{ [void] $c.Items.Add($_) }
                $c.Location = New-Object System.Drawing.Point(($this.label_width + $this.margin), ($this.row_height * $this.slot))
                $c.width = $this.control_width - (2*$this.margin)
                if ($null -ne $callback) { $c.Add_SelectedValueChanged( $callback ) }
                $c.Height = $this.row_height * $rows
                $l = New-Object System.Windows.Forms.Label
                $l.text = $label
                $l.AutoSize = $false
                $l.Location = New-Object System.Drawing.Point(($this.margin), ($this.row_height * $this.slot))
                $l.Width = $this.label_width - (2*$this.margin)
                $l.Height = $this.row_height
                $this.Form.Controls.Add($l)
                
                if ($buttons) {
                    $x = $this.label_width + $this.margin
                    $buttons | ForEach-Object{
                        $b = New-Object System.Windows.Forms.Button
                        $b.Location = New-Object System.Drawing.Point($x, ($this.row_height * ($this.slot + $rows)))
                        $b.Height = $this.row_height
                        $b.Text = $_.name
                        if ($null -ne $_.callback) { $b.Add_Click( $_.callback ) }
                        $this.Form.Controls.Add($b)
                        $x += $b.Size.Width
                    }
                    $rows += 1
                }
            }
        }

        $this.slot += $rows
        $this.Form.Controls.Add($c)
        $this.Form.ClientSize = "$($this.width), $($this.Form.ClientSize.height + ($this.row_height * $rows))"

        return $c

    }

    # 
    # OK (action) and Cancel buttons
    # 
    [void]AddAction() { $this.DoAddAction($null) }
    [void]AddAction( [scriptblock]$callback) { $this.DoAddAction($callback) }
    hidden [void]DoAddAction(
        [scriptblock]$callback
    ) {
        $ok = New-Object system.Windows.Forms.Button
        $ok.text = "OK"
        $ok.location = New-Object System.Drawing.Point(($this.width - 120 - ($this.margin *2)   ), ($this.row_height * $this.slot))
        $cancel = New-Object system.Windows.Forms.Button
        $cancel.text = "Cancel"
        $cancel.location = New-Object System.Drawing.Point(($this.width - 60 - $this.margin), ($this.row_height * $this.slot))
        $cancel.Width = $ok.Width = 60
        $cancel.Height = $ok.Height = $this.row_height
        $this.Form.Controls.Add($ok)
        $this.Form.Controls.Add($cancel)
        if ($null -ne $callback) { 
            $ok.Add_Click($callback) 
        } else {
            $ok.Add_Click({ $this.parent.Close() }) 
        }
        $cancel.Add_Click({ $this.parent.Close() })
    }

}

function New-QuickForm {
    <#
        .SYNOPSIS
        Create a new simple 2 column form
        .DESCRIPTION
        Returns a QuickForm object, having methods;

        .AddRow(<type>, [<rows>,] <name>, <label>, [<options>], [<callback>], [<buttons>])
            Add a control to the form in a new row (controls/rows appear in the order added)
            and return the control.

            <type> - either TextBox, PasswordBox, CheckBox, ComboBox, ListBox
            [<rows>] - number of rows to display for listbox controls
            <label> - label for the control, displayed in left column for all except
                      CheckBox
            [<options>] - optional array of items for a ComboBox e.g. @(1,2,3)
                          listboxes must have options - but may be empty array i.e. @()
            [<callback>] - optional scriptblock called when control value changes
                           refer to the control itself via $this or $<name> e.g. $this.Text or $<name>.Text
                           refer to the form as $this.parent
                           listboxes must have a callback
            [<buttons>] - optional array of buttons for listboxes e.g.
                          @( @{name="<name>"; callback={}}, @{name="<name>"; callback={}}, etc. )
            
            The value of each control type can be accessed through its properties
            either via $this (within the controls own callback) or by assigning the returned
            control to a variable.

                TextBox and Password - via $this.Text
                CheckBox - via $this.Checked
                ComboBox - via $this.SelectedItem
                ListBox - via $this.SelectedItem

        .AddAction([<callback>])
            Add OK and Cancel buttons to the form.

            [<callback>] - optional scriptblock called when the OK button is pressed
                           to e.g. validate values before submission
                           If specified it is the callbacks responsibility to close the
                           form if necessary e.g. via $this.parent.close()
        
        .Show()
            Display the form            

        .EXAMPLE
        import-module QuickForms

        $demo = New-QuickForm -Title "Demo Form" -LabelWidth 200 -ControlWidth 400

        $myFirstName = $demo.AddRow("TextBox", "First Name:", { Write-Host $this.Text })
        $MySurname = $demo.AddRow("TextBox", "Surname:", { Write-Host $this.Text })
        $MyPassword = $demo.AddRow("PasswordBox", "Password:")
        $MyConfirmPassword = $demo.AddRow("PasswordBox", "Confirm Password:", { Write-Host "$($MyPassword.Text -eq $this.Text)" })
        $MySex = $demo.AddRow("CheckBox", "Male", { Write-Host $this.Checked })
        $MyOptions = $demo.AddRow("ComboBox", "Sex:", @("Male", "Female"), { Write-Host $this.SelectedItem })

        $demo.AddAction({ 
            if ($MyPassword.Text -eq $MyConfirmPassword.Text) {
                $this.parent.close()
            } else {
                Write-Host "Password & Confirm Password do not match!"
            }
        })

        $demo.Show()
        
        Write-Host $MyFirstName.Text, $MySurname.Text, $MyPassword.Text

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
        [int32]$ControlWidth = 200
    )
    $form = New-Object QuickForm($Title, $LabelWidth, $ControlWidth)
    return $form    
}
