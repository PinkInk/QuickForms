import-module .\QuickForms.psd1

$demo = New-QuickForm -Title "Demo Form" -LabelWidth 200 -ControlWidth 400

# add ExitCode property to the form
$demo | Add-Member -NotePropertyName ExitCode -NotePropertyValue 0

# pipeline form
$MyFirstName = $demo | Add-TextBox -Label "First name:" -Callback {
    if (!$MyUserID.Enabled) { # only update locked UserID
        $MyUserID.Text = "$($MyFirstName.Text[0]).$($MySurname.Text)"
    }
}

$MySurName = Add-TextBox -Form $demo -Label "Surname:" -Callback {
    if (!$MyUserID.Enabled) { # only update locked UserID
        $MyUserID.Text = "$($MyFirstName.Text[0]).$($MySurname.Text)"
    }
}

$MyUserID = Add-TextBox -Form $demo -Label "User ID:" -Lockable -Disabled

$MyPassword = Add-TextBox -Form $demo -Label "Password:" -Password

$MyConfirmPassword = Add-TextBox -Form $demo -Label "Confirm Password:"

$MyDateTime = Add-DateTimePicker -Form $demo -Label "Date Time:" -Type DateTime

$MyDate = Add-TextBox -Form $demo -Label "Date:" -Mask "00/00/0000" `

$MySex = Add-CheckBox -Form $demo -Label "Male" -Callback {
    if ( $this.Checked ) {
        $MyOptions.SelectedItem = "Male"
        $MyRadios.Controls | %{ if ($_.Text -eq "Male") { $_.PerformClick() } }
    } else {
        $MyOptions.SelectedItem = "Female"
        $MyRadios.Controls | %{ if ($_.Text -eq "Female") { $_.PerformClick() } }
    }
}

$MyOptions = Add-ComboBox -Form $demo -Label "Sex:" -Options @("Male", "Female") -Callback {
    $MySex.Checked = if ($this.SelectedItem -eq "Male") {$true} else {$false}
    $MyRadios.Controls | %{ if ($_.Text -eq $this.SelectedItem) { $_.PerformClick() } }
}

$MyRadios = Add-RadioBox -Form $demo -Label "Gender:" -Options @("Male", "Female") -Callback {
    if ($this.Checked) {
        $MyOptions.SelectedItem = $this.Text
        $MySex.Checked = if ($this.Text -eq "Male") {$true} else {$false}
    }
}

$MyList = Add-ListBox -Form $demo -Label "List:" -Rows 3 `
            -Options @("Item the first", "Item the second") `
            -Buttons @(
                @{ 
                    name = "Add"; 
                    callback = { $MyList.Items.Add("Item another") } 
                }
                @{
                    name = "Remove"; 
                    callback = {
                        if ( $MyList.SelectedIndex -ne -1 ) {
                            $MyList.Items.RemoveAt( $MyList.SelectedIndex )
                        }
                    }
                }
            )

$MySaveFile = Add-FileBox -Form $demo -Label "Save as:" -Type "SaveAs" `
                -FileFilter "txt files (*.txt)|*.txt|All files (*.*)|*.*"

$MyNotes = Add-TextBox -Form $demo -Label "Notes:" -Rows 2

Add-Action -Form $demo -Callback {
    if ($MyPassword.Text -eq $MyConfirmPassword.Text) {
        $demo.ExitCode = 1
        $this.parent.close()
    } else {
        Write-Host "Password & Confirm Password do not match!"
    }
}

$demo.Show()

if ( $demo.ExitCode -eq 1 ) {
    Write-Host "Create $($MyUserID.Text) ..."
} else {
    Write-Host "Form cancelled"
}
