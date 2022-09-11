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
readibility by requiring only terse control initialisation and
logic to be added.

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

| Argument | Description |
| --- | --- |
| [-Title <value>] | Title to be displayed in the forms title bar (default: "My Form") |
| [-LabelWidth <value>] | Width of the label column in pixels (default: 200) |
| [-ControlWidth <value>] | Width of the control column in pixels (default)

``` PowerShell
$MyForm = New-QuickForm -Title "Demo Form" -LabelWidth 200 -ControlWidth 400
```
### Add controls rows
``` PowerShell
.AddRow(<type>, <label>, )
```

#### TextBox
#### PasswordBox
#### CheckBox
#### ComboBox
#### ListBox

### Add action

### Show form