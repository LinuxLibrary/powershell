# Remote Control

`Invoke-Command -ComputerName PC3,PC4,PC9 -ScriptBlock {Disable-WindowsOptionalFeature -Feature WindowsMediaPlayer}`
`Invoke-Command -ComputerName (type C:\pcs.txt) -ScriptBlock {Disable-WindowsOptionalFeature -Feature WindowsMediaPlayer}`
`Invoke-Command -ComputerName (Get-ADComputer -Filter *).Name -ScriptBlock {Disable-WindowsOptionalFeature -Feature WindowsMediaPlayer}`