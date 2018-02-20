# POSH Examples

- `Set-ADUser -Identity ArjunShrinivas -Title "Admin"`

- `Get-ADUser -Filter {Enabled -eq $false}`

- `Add-Printer -Connect \\Server3\Printer03`

- `Restart-Computer`

- `Disable-WindowsOptionalFeature -Feature WindowsMediaPlayer`

# Discovering Commands

- To find out the cmdlets for printers

	`Get-Command *printer*`