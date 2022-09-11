# QuickForms

Quick and simple 2 column (label, control) PowerShell forms module, 
supporting the following controls:

- ```TextBox```
- ```PasswordBox``` (shortcut for a TextBox with hidden input)
- ```CheckBox```
- ```ComboBox``` (drop-down list)
- ```ListBox``` (with optional user specified Buttons)

Example (the included **demo.ps1** form):

![demo form](./demo.png)

Callbacks can be easily attached to the most common control events e.g. 
```TextChanged``` event for ```TextBox``` and ```PasswordBox``` controls.

Form layout is managed by the module in order to reduce the
time required to strap a GUI onto existing scripts and improve
readibility by requiring only terse initialisation and logic.

## Install

Copy **QuickForms.psm1** and **QuickForms.psd1** to your module path, or place 
in same directory as your script for portability.

## Use

The general workflow is;

- Import module
- Initialise form
- Add control rows (in display order)
- Add action (OK, Cancel buttons)
- Show form

### Import module

If installed in your module path:

``` PowerShell
Import-Module QuickForms
```

If installed in the same directory as your script:

``` PowerShell
Import-Module .\QuickForms.psd1
```

### Initialise form

```New-QuickForm``` is used to initialise a new form.

``` PowerShell
$MyForm = New-QuickForm -Title "Demo Form" -LabelWidth 200 -ControlWidth 400
```

| Argument | Description |
| --- | --- |
| [-Title \<value>] | Title to be displayed in the forms title bar (default: "My Form") |
| [-LabelWidth \<value>] | Width of the label column in pixels (default: 200) |
| [-ControlWidth \<value>] | Width of the control column in pixels (default)

### Add controls rows

Add a control, and it's label to a form.

``` PowerShell
.AddRow(<type>, [<rows>,] <label>, [<options>,][<callback>,][<buttons>]  )
```

| Argument | Description | 
| --- | --- |
| \<type> | TextBox, PasswordBox, CheckBox, ComboBox or ListBox |
| [\<rows>] | Optional number of rows to display for ListBox |
| \<label> | Label for the control |
| [\<options>] | Optional array of items to initialise ComboBox or ListBox with |
| [\<callback>] | Optional Scriptblock to be executed on ```TextChanged``` for ```TextBox``` and ```PasswordBox```, ```CheckedChanged``` for ```CheckBox```, ```SelectedValueChange``` for ```ComboBox``` and ```ListBox``` |
| [\<buttons>] | Optional array of buttons and callbacks for ```ListBox``` controls |

#### Control : TextBox

``` PowerShell
$Firstname = $MyForm.AddRow("TextBox", "Firstname:", { $Firstname.Text = $Firstname.Text.ToUpper() })
```

Callback is optional and bound to ```TextChanged``` event if supplied.

Access the value of the control via its ```.Text``` property. 

#### Control : PasswordBox

``` PowerShell
$Password = $MyForm.AddRow("PasswordBox", "Password:" { Write-Host $Password.Text })
```

Callback is optional and bound to ```TextChanged``` event if supplied.

Access the value of the control via its ```.Text``` property. 

#### Control : CheckBox

``` PowerShell
$Enabled = $MyForm.AddRow("CheckBox", "Enabled:")
```

Callback is optional and bound to ```CheckedChanged``` event if supplied.

Checkbox labels appear to the right of the checkbox in the 
control column of the form, not the left label column.

Access the boolean value of the control via its ```.Checked``` property. 

#### Control : ComboBox

``` PowerShell
$Gender = $MyForm.AddRow("ComboBox", "Gender:", @("Male", "Female"), { Write-Host $Gender.SelectedItem })
```

Options and callback are optional, callback is bound to its 
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

#### Control : ListBox

``` PowerShell
.AddRow("ListBox", <number_of_rows>, <label>, <items>, <callback>[, <buttons>])
```

e.g.

``` PowerShell
$MyList = $MyForm.AddRow("ListBox", 3, "List:", @("Item 1", "Item 2"), { Write-Host $MyList.SelectedItem })
```

... or add a row of buttons underneath, normally used for interacting with the 
list:

``` PowerShell
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
```

```Buttons``` are optional.  ```Items``` and ```Callback``` are not optional but
can be empty e.g. ```@()``` and ```{}``` respectively (see example above).  

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
Add the customary OK and Cancel buttons to the form, optionally 
with a callback for the OK button, which is commonly used to
verify validity of entered data before closing the form and
proceeding.

This is typically called after all controls are added to a form,
before it is shown.

If Callback is specified for the OK button it will be required
to explicitly close the form (if waranted) e.g. via ```$this.parent.close()```

You likely want to set some value in the Callback to inform
latter code that the form was closed via OK, rather than
Cancelled.

``` PowerShell
$MyForm.AddAction({
    # verify values
    $ExitCode = 1
    $this.parent.close()
})
```

### Show form
Display the form.

```PowerShell
$MyForm.Show()
```

## Tips and tricks

### Form logic

For brevity it's probably preferable to author one ```Update-Fields``` function
to manage control logic and bind it to the callback of all (or most) enabled
controls. 

### Mimic radio buttons

To work around the absence of radio button control functionality you can use
multiple ```CheckBox``` controls with callbacks to maintain a single checked
control.

### Additional properties

It can be useful to add properties to the form to e.g. replace the functionality
of hidden fields, or record an exit code.

``` PowerShell
$form = New-QuickForm -Title "Test Form"

# add fields
$form | Add-Member -NotePropertyName "ExitCode" -NotePropertyValue 0
$form | Add-Member -NotePropertyName "HiddenCalculatedValue" -NotePropertyValue ""

# add controls

$form.AddAction({
    $form.ExitCode = 1
    $this.parent.Close()
})

if ($form.ExitCode -eq 1) {
    # do work
} else { Write-Host "Form Cancelled" }

```