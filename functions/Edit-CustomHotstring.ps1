function Edit-CustomHotstring
{
	<#
	.SYNOPSIS
	Edit the list of custom hotstrings for use by PSExpandLine.

	.DESCRIPTION
	Edit the list of custom hotstrings for use by PSExpandLine.
	This command will open a list of user-defined hotstring definitions with the default editor associated with .csv files (on Linux machines, the file object will be written to the pipeline).
	If the file does not exist, the command will first create it.
	The command can be run as often as required by the user.
	The command will wait until the file has been closed, and then reload the module so that the hotstrings are available immediately.
	In order to see the effect of a change without closing the file, simply run:

	PS C:\> Import-Module -Name PSExpandLine -Force

	.EXAMPLE
	Edit-CustomHotstring

	.INPUTS
	None.

	.OUTPUTS
	[System.Void]
	The function does not return anything.

	.NOTES
	Author : nmbell

	.LINK
	Save-AliasAsHotstring
	.LINK
	about_PSExpandLine
	#>

	# Function alias
	[Alias('Edit-CustomAlias')]

	# Use cmdlet binding
	[CmdletBinding(
		HelpURI = 'https://github.com/nmbell/PSExpandLine/blob/main/help/Edit-CustomHotstring.md'
	)]

	# Declare output type
	[OutputType([System.Void])]

	# Declare parameters
	Param ()

	BEGIN
	{
		# Common BEGIN:
		Set-StrictMode -Version 3.0
		$start            = Get-Date
		$thisFunctionName = $MyInvocation.MyCommand
		Write-Verbose "[$thisFunctionName]Started: $($start.ToString('yyyy-MM-dd HH:mm:ss.fff'))"

		# Function BEGIN:
	}

	PROCESS
	{
		# Create the file if necessary
		If (!(Test-Path -Path $PSExpandLine.CustomHotstringsFilePath))
		{
			Write-Verbose "[$thisFunctionName]Creating custom hotstrings list: $($PSExpandLine.CustomHotstringsFilePath)"
			[PSCustomObject]@{ Name = ''; Definition = '' } `
			| Select-Object Name,Definition `
			| ConvertTo-Csv `
			| Select-Object -First 1 `
			| Out-File -FilePath $PSExpandLine.CustomHotstringsFilePath
		}

		# Open the file for editing
		If ($IsLinux)
		{
			Get-Item -Path $PSExpandLine.CustomHotstringsFilePath
		}
		Else
		{
			Write-Verbose "[$thisFunctionName]Editing custom hotstrings list: $($PSExpandLine.CustomHotstringsFilePath)"
			Write-Verbose "[$thisFunctionName]Waiting for editor to close..."
			Start-Process -FilePath $PSExpandLine.CustomHotstringsFilePath -PassThru | Wait-Process

			# Reload the module
			Write-Verbose "[$thisFunctionName]Re-importing PSExpandLine module: $($PSExpandLine.ModulePath)"
			Import-Module -Name $PSExpandLine.ModulePath -Global -Force -Verbose:$false
		}
	}

	END
	{
		# Function END:

		# Common END:
		$end      = Get-Date
		$duration = New-TimeSpan -Start $start -End $end
		Write-Verbose "[$thisFunctionName]Stopped: $($end.ToString('yyyy-MM-dd HH:mm:ss.fff')) ($($duration.ToString('d\d\ hh\:mm\:ss\.fff')))"
	}
}
