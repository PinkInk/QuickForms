import-module .\QuickForms.psd1 

$demo = New-QuickForm -Title "Demo Form" -LabelWidth 200 -ControlWidth 400
$demo | Add-Member -NotePropertyName ExitCode -NotePropertyValue 0

$myFirstName = $demo.AddRow("TextBox", "First Name:", 
    { $MyUserID.Text = "$($MyFirstName.Text[0]).$($MySurname.Text)" }
)

$MySurname = $demo.AddRow("TextBox", "Surname:", 
    { $MyUserID.Text = "$($MyFirstName.Text[0]).$($MySurname.Text)" }
)

$MyUserID = $demo.AddRow("TextBox", "User ID:")
$MyUserID.Enabled = $false

$MyPassword = $demo.AddRow("PasswordBox", "Password:")

$MyConfirmPassword = $demo.AddRow("PasswordBox", "Confirm Password:", 
    { Write-Host "$($MyPassword.Text -eq $this.Text)" }
)

$MySex = $demo.AddRow("CheckBox", "Male", 
    { 
        if ( $this.Checked ) { 
            $MyOptions.SelectedItem = "Male" 
        } else { 
            $MyOptions.SelectedItem = "Female" 
        } 
    }
)

$MyOptions = $demo.AddRow("ComboBox", "Sex:", @("Male", "Female"), 
    { $MySex = if ($this.SelectedItem -eq "Male") {$true} else {$false} }
)

$MyList = $demo.AddRow("ListBox", 3, "List:", 
    @("Item the first"), 
    { Write-Host $MyList.SelectedItem }, 
    @(
        @{ name="Add"; callback={ $MyList.Items.Add("Item another") } },
        @{ name="Remove"; callback={
                if ( $MyList.SelectedIndex -ne -1 ) {
                    $MyList.Items.RemoveAt( $MyList.SelectedIndex )
                }
            } 
        }
    )
)

$demo.AddAction({ 
    if ($MyPassword.Text -eq $MyConfirmPassword.Text) {
        $demo.ExitCode = 1
        $this.parent.close()
    } else {
        Write-Host "Password & Confirm Password do not match!"
    }
})

$demo.Show()

if ( $demo.ExitCode -eq 1 ) {
    Write-Host $MyFirstName.Text, $MySurname.Text, $MyUserID.Text, $MyPassword.Text
} else {
    Write-Host "Form cancelled"
}
