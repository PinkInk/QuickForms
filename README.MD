# QuickForms

Quick and simple 2 column (label, control) PowerShell forms module, 
supporting the following controls:

- ```TextBox```
- ```PasswordBox``` (TextBox with hidden input)
- ```CheckBox```
- ```ComboBox```
- ```ListBox``` (with optional user specified Buttons)

Example (the included **demo.ps1** form):

![demo form](./demo.png)

Callbacks can be easily attached to the most common control events e.g. 
```TextChanged``` event for ```TextBox``` and ```PasswordBox``` controls.

Form layout is managed by the module in order to reduce the
time required to strap a GUI onto existing scripts and improve
readability by requiring only terse initialisation and logic.

## Install

Install from PSGallery;

``` PowerShell
Install-Module QuickForms
```

Or copy **QuickForms.psm1** and **QuickForms.psd1** to your script path for 
portability.

## Use

The general workflow is;

- Import module
- Initialise form
- Add control rows (in display order)
- Add action (OK, Cancel buttons)
- Show form

### Import module

If installed:

``` PowerShell
Import-Module QuickForms
```

If installed in the same directory as your script:

``` PowerShell
Import-Module .\QuickForms.psd1
```

Note: if installed in the same directory as script you must import the .psd1
file (not the .psm1 file) in order to satisfy a dependency on the 
System.Windows.Forms assemblies.

### Initialise form

```New-QuickForm``` is used to initialise a new form.

``` PowerShell
$MyForm = New-QuickForm -Title "Demo Form" -LabelWidth 200 -ControlWidth 400
```

| Argument | Description |
| --- | --- |
| [-Title \<value>] | Title to be displayed in the forms title bar (default: "My Form") |
| [-LabelWidth \<value>] | Width of the label column in pixels (default: 200) |
| [-ControlWidth \<value>] | Width of the control column in pixels (default: 400)

### Add controls rows

#### TextBox

``` PowerShell
$Firstname = Add-TextBox -Form $MyForm -Label "Firstname:" -Callback { $Firstname.Text = $Firstname.Text.ToUpper() }
```

Callback is optional and bound to ```TextChanged``` event if supplied.

Access the value of the control via its ```.Text``` property. 

#### PasswordBox

``` PowerShell
$Password = Add-PasswordBox -Form $MyForm -Label "Password:" -Callback { Write-Host $Password.Text }
```

Callback is optional and bound to ```TextChanged``` event if supplied.

Access the value of the control via its ```.Text``` property. 

#### CheckBox

``` PowerShell
$Enabled = Add-CheckBox -Form $MyForm -Label "Enabled:" -Callback { Write-Host $this.Checked }
```

Callback is optional and bound to ```CheckedChanged``` event if supplied.

Checkbox labels appear to the right of the checkbox in the 
control column of the form, not the left label column.

Access the boolean value of the control via its ```.Checked``` property. 

#### ComboBox

``` PowerShell
$Gender = Add-ComboBox -Form $MyForm -Label "Gender:" -Options @("Male", "Female") -Callback { Write-Host $Gender.SelectedItem }
```

Options and Callback are optional, Callback is bound to its 
```SelectedValueChanged``` event if supplied.

```.SelectedItem``` property contains the text of the currently selected item.

```.SelectedIndex``` property contains the index of the currently selected item, 
or ```-1``` if a selection hasn't yet been made.

```.Items``` property contains the list of items.

Call ```.Items.Add("<value>")``` method to add a new item.

Call ```.Items.Remove("<value>")``` method to remove an item by name (randomly 
where multiple items with the same name appear in the list).

Call ```.Items.RemoveAt("<index>")``` method to remove an item by index 
e.g. ```.SelectedIndex``` property.

#### ListBox

``` PowerShell
$MyList = Add-ListBox -Form $MyForm -Label "List:" -Rows 4 -Options @("Item 1", "Item 2") -Callback { Write-Host $MyList.SelectedItem }
```

... or add a row of buttons underneath, normally used for interacting with the 
list:

``` PowerShell
$MyList = Add-ListBox -Form $MyForm `
    -Label "List:" `
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
```

```Rows```, ```Options```, ```Callback``` and ```Buttons``` are optional.

```Rows``` defaults to 3.  

```Buttons``` is an array of dictionary's containing ```name``` (button text) 
and ```callback``` (called when button pressed) properties e.g.

``` PowerShell
@(
    @{ name="Add"; callback={} },
    @{ name="Remove"; callback={} }
)
```

Callback is bound to ```SelectedValueChanged``` event.

```.SelectedItem``` property contains the text of the currently selected item.

```.SelectedIndex``` property contains the index of the currently selected item, 
or ```-1``` if a selection hasn't yet been made.

```.Items``` property contains the list of items.

Call ```.Items.Add("<value>")``` method to add a new item.

Call ```.Items.Remove("<value>")``` method to remove an item by name (randomly 
where multiple items with the same name appear in the list).

Call ```.Items.RemoveAt("<index>")``` method to remove an item by index 
e.g. ```.SelectedIndex``` property.

### Add action

``` Powershell
Add-Action -Form $MyForm -Callback { $this.parent.Close(); Write-Host "OK Selected" }
```

Add the customary OK and Cancel buttons to the form, optionally 
with a callback for the OK button, which is commonly used to
verify validity of entered data before closing the form and
proceeding.

This is typically called after all controls are added to a form,
before it is shown.

If Callback is specified for the OK button it will be required
to explicitly close the form (if warranted) e.g. via ```$this.parent.close()```

You likely want to set some value in the Callback to inform
latter code that the form was closed via OK, rather than
Cancelled.

``` PowerShell
Add-Action -Form $MyForm -Callback {
    # verify values
    $ExitCode = 1
    $this.parent.close()
}
```

### Show form
Display the form.

```PowerShell
$MyForm.Show()
```

## Tips and tricks

### Pipeline
Add-<Control> and Add-Action cmdlets accept a form on the pipeline e.g.

``` Password
$MyTextBox = $MyForm | Add-TextBox -Label "Text entry:"
```

### $this
You can refer to the current control as ```$this``` within its Callback e.g.

``` PowerShell
$MyCheckbox = Add-CheckBox -Form $MyForm -Callback { Write-Host $this.Checked }
```

### Form logic

For brevity it's probably preferable to author one ```Update-Fields``` function
to manage control logic and bind it to the callback of all (or most) enabled
controls. 

### Mimic radio buttons

To work around the absence of radio button control functionality you can use
multiple ```CheckBox``` controls with callbacks to maintain a single checked
control.

### Add form properties

It can be useful to add properties to the form to e.g. replace the functionality
of hidden fields, or record an exit code.

``` PowerShell
$form = New-QuickForm -Title "Test Form"

# add fields
$form | Add-Member -NotePropertyName "ExitCode" -NotePropertyValue 0
$form | Add-Member -NotePropertyName "HiddenCalculatedValue" -NotePropertyValue ""

# add controls

Add-Action -Form $MyForm -Callback {
    $form.ExitCode = 1
    $this.parent.Close()
}

if ($form.ExitCode -eq 1) {
    # do work
} else { Write-Host "Form Cancelled" }

```