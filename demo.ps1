import-module .\QuickForms.psd1

$demo = New-QuickForm -Title "Demo Form" -LabelWidth 200 -ControlWidth 400

# add ExitCode property
$demo | Add-Member -NotePropertyName ExitCode -NotePropertyValue 0

# pipeline form
$MyFirstName = $demo | Add-TextBox -Label "First name:" -Callback {
    $MyUserID.Text = "$($MyFirstName.Text[0]).$($MySurname.Text)"
}

$MySurName = Add-TextBox -Form $demo -Label "Surname:" -Callback {
    $MyUserID.Text = "$($MyFirstName.Text[0]).$($MySurname.Text)"
}

$MyUserID = Add-TextBox -Form $demo -Label "User ID:"
$MyUserID.Enabled = $false

$MyPassword = Add-TextBox -Form $demo -Label "Password:" -Password

$MyConfirmPassword = Add-TextBox -Form $demo -Label "Confirm Password:" -Password -Callback {
    Write-Host "Passwords match: $($MyPassword.Text -eq $this.Text)"
}

$MyDateTime = Add-DateTimePicker -Form $demo `
                -Label "Date Time:" `
                -Type DateTime `
                -DateTime (Get-Date -Year 1999 -Month 12 -Day 3 -Hour 12 -Minute 23) `
                -Callback { Write-Host "Date Time: $($this.Value)" }

$MyDate = Add-TextBox -Form $demo `
                -Label "Date:" `
                -Mask "00/00/0000" `
                -Callback { Write-Host "Date: $($this.Text)"}

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

$MyList = Add-ListBox -Form $demo `
            -Label "List:" `
            -Rows 3 `
            -Options @("Item the first") `
            -Callback { Write-Host "List Item: $($MyList.SelectedItem)" } `
            -Buttons @(
                @{ name="Add"; callback={ $MyList.Items.Add("Item another") } },
                @{ name="Remove"; callback={
                        if ( $MyList.SelectedIndex -ne -1 ) {
                            $MyList.Items.RemoveAt( $MyList.SelectedIndex )
                        }
                    }
                }
            )

$MySaveFile = Add-FileBox -Form $demo `
                -Label "Save as:" `
                -Type "SaveAs" `
                -FileFilter "txt files (*.txt)|*.txt|All files (*.*)|*.*" `
                -Callback { Write-Host "Save as: $($MySaveFile.Text)" }
            
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
    Write-Host "Name: $($MyFirstName.Text) $($MySurname.Text)"
    Write-Host "UserID: $($MyUserID.Text)"
    Write-Host "Password: $($MyPassword.Text)"
    Write-Host "Date-time: $($MyDateTime.Value)"
    Write-Host "Gender: $($MyOptions.SelectedItem)"
    Write-Host "Save-as: $($MySaveFile.Text)"
} else {
    Write-Host "Form cancelled"
}
