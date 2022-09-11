import-module .\QuickForms.psd1 

$demo = New-QuickForm -Title "Demo Form" -LabelWidth 200 -ControlWidth 400

$myFirstName = $demo.AddRow('TextBox', 'First Name:', { $MyUserID.Text = "$($MyFirstName.Text[0]).$($MySurname.Text)" })

$MySurname = $demo.AddRow('TextBox', 'Surname:', { $MyUserID.Text = "$($MyFirstName.Text[0]).$($MySurname.Text)" })

$MyUserID = $demo.AddRow('TextBox', 'User ID:')
$MyUserID.Enabled = $false

$MyPassword = $demo.AddRow('PasswordBox', 'Password:')

$MyConfirmPassword = $demo.AddRow('PasswordBox', 'Confirm Password:', { Write-Host "$($MyPassword.Text -eq $this.Text)" })

$MySex = $demo.AddRow("CheckBox", 'Male', { Write-Host $this.Checked })

$MyOptions = $demo.AddRow("ComboBox", "Sex:", @("Male", "Female"), { Write-Host $this.SelectedItem })

$demo.AddAction({ 
    if ($MyPassword.Text -eq $MyConfirmPassword.Text) {
        $this.parent.close()
    } else {
        Write-Host 'Password & Confirm Password do not match!'
    }
})

$demo.Show()

Write-Host $MyFirstName.Text, $MySurname.Text, $MyUserID.Text, $MyPassword.Text
