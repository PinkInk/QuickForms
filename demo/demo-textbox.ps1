import-module ..\QuickForms.psd1

$demo = New-QuickForm -Title "Various Textboxes"

Add-Title -Form $demo -Label 'Add-TextBox -Form $form -Label "Textbox"'
$TextBox = Add-TextBox -Form $demo -Label "Textbox"

Add-Title -Form $demo -Label 'Add-TextBox -Form $form -Label "Password" -Password'
$Password = Add-TextBox -Form $demo -Label "Password" -Password

Add-Title -Form $demo -Label 'Add-TextBox -Form $form -Label "Mask" -Mask "00/00/0000"'
$Mask = Add-TextBox -Form $demo -Label "Mask" -Mask "00/00/0000"

Add-Title -Form $demo -Label 'Add-TextBox -Form $form -Label "Lockable" -Disabled -Text "Calculated value"'
$Lockable = Add-TextBox -Form $demo -Label -Lockable -Disabled -Text "Calculated value"

Add-Title -Form $demo -Label 'Add-TextBox -Form $form -Label "Multi row" -Rows 2'
$MultiRow = Add-TextBox -Form $demo -Label "Multi row" -Rows 2

$demo.Show()