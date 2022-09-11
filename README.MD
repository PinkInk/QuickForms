# QuickForms
Simple 2 column (label, control) PowerShell form module, 
supporting the following control types:

- ```TextBox```
- ```PasswordBox``` (shortcut for a TextBox with *'d out input)
- ```CheckBox```
- ```ComboBox``` (drop-down list)
- ```ListBox``` (with optional user specified Buttons)

Callbacks can be attached to the most common control events e.g. ```TextChanged``` for ```TextBox``` and ```PasswordBox```, ```SelectedValueChange``` for ```ComboBox``` and ```ListBox```.

Form layout is managed by the module in order to reduce the
time required to strap a GUI onto existing scripts and improve
readibility by requiring only terse initialisation and logic.

## Install
Copy QuickForms.psm1 and QuickForms.psd1 to your module path.

## Use
The general workflow is;

- Import module
- Initialise form
- Add control rows (in order)
- Add action (OK, Cancel buttons)
- Show form

### Import module
If installed in your module path

``` PowerShell
Import-Module QuickForms
```

If installed in the same directory as your script

``` PowerShell
Import-Module .\QuickForms.psd1
```

### Initialise form

```New-QuickForm``` is used to initialise a new form

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

Callback is optional.  Callback is bound to ```TextChanged``` event.

#### Control : PasswordBox

``` PowerShell
$Password = $MyForm.AddRow("PasswordBox", "Password:" { Write-Host $Password.Text })
```

Callback is optional.  Callback is bound to ```TextChanged``` event.

#### Control : CheckBox

``` PowerShell
$Enabled = $MyForm.AddRow("CheckBox", "Enabled:")
```

Callback is optional.  Callback is bound to ```CheckedChanged``` event.

#### Control : ComboBox

``` PowerShell
$Gender = $MyForm.AddRow("ComboBox", "Gender:", @("Male", "Female"), { Write-Host $Gender.SelectedItem })
```

Options and Callback are optional.  Callback is bound to ```SelectedValueChanged``` event.

```.SelectedItem``` contains the text of the currently selected item.

```.SelectedIndex``` contains the index of the currently selected item, or ```-1``` if a selection hasn't yet been made.

#### Control : ListBox

``` PowerShell
$MyList = $MyForm.AddRow("ListBox", 3, "List:", @("Item 1", "Item 2"), { Write-Host $MyList.SelectedItem })
```

or add a row of buttons underneath, normally used for interacting with the list; 

``` PowerShell
$MyList = $MyForm.AddRow("ListBox", 3, "List:", @("Item 1", "Item 2"), {}, 
    @( @{name="Add"; callback={}}, @{name="Remove"; callback={}})
)
```
Options, Callback and Buttons are optional.  Callback is bound to ```SelectedValueChanged``` event.

```.SelectedItem``` contains the text of the currently selected item.

```.SelectedIndex``` contains the index of the currently selected item, or ```-1``` if a selection hasn't yet been made.

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