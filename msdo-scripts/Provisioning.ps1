# Search for Modules to install

Find-Module | Select-String -Pattern "<SomeName>" -SimpleMatch

# Create virtual machine from template

New-VM -Name <Some_Name> -Template <Template_Name> -VMHost <VM_Host_Name>

# Start virtual machine

Start-VM -Name <VM_Name>
