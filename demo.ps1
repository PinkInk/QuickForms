import-module .\QuickForms.psd1

$demo = New-QuickForm -Title "Demo Form" -LabelWidth 200 -ControlWidth 400
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

$MyPassword = Add-PasswordBox -Form $demo -Label "Password:"

$MyConfirmPassword = Add-PasswordBox -Form $demo -Label "Confirm Password:" -Callback {
        Write-Host "$($MyPassword.Text -eq $this.Text)"
    }

$MyDateTime = Add-DateTimePicker -Form $demo `
        -Label "Date Time:" `
        -Type DateTime `
        -DateTime (Get-Date -Year 1999 -Month 12 -Day 3 -Hour 12 -Minute 23) `
        -Callback { Write-Host $this.Value }

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
        $MyRadios.Controls | %{  if ($_.Text -eq $this.SelectedItem) { $_.PerformClick() } }
    }

$MyRadios = Add-RadioBox -Form $demo -Label "Sex:" -Options @("Male", "Female") -Horizontal -Callback {
        if ($this.Checked) {
            $MyOptions.SelectedItem = $this.Text
            $MySex.Checked = if ($this.Text -eq "Male") {$true} else {$false}
        }
    }

$MyList = Add-ListBox -Form $demo `
            -Label "List:" `
            -Rows 3 `
            -Options @("Item the first") `
            -Callback { Write-Host $MyList.SelectedItem } `
            -Buttons @(
                @{ name="Add"; callback={ $MyList.Items.Add("Item another") } },
                @{ name="Remove"; callback={
                        if ( $MyList.SelectedIndex -ne -1 ) {
                            $MyList.Items.RemoveAt( $MyList.SelectedIndex )
                        }
                    }
                }
            )


$MyOpenFile = Add-FileBox -Form $demo `
                -Label "Save as:" `
                -Type "SaveAs" `
                -FileFilter "txt files (*.txt)|*.txt|All files (*.*)|*.*" `
                -Callback { Write-Host $MyOpenFile.Text }

            
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
    Write-Host $MyFirstName.Text, $MySurname.Text, $MyUserID.Text, $MyPassword.Text
} else {
    Write-Host "Form cancelled"
}
