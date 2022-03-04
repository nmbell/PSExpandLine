function Save-AliasAsHotstring
{
	<#
	.SYNOPSIS
	Creates a hotstring from each command alias in the current session.

	.DESCRIPTION
	Creates a hotstring from each command alias in the current session.
	This command will create a hotstring definition from each command alias already defined in the current session.
	The command is designed to be run as often as necessary to capture the current aliases, such as after a new module has been loaded.
	The configuration file that stores the hotstrings is marked as read only. It is not intended to be edited by the user.
	The command will also reload the module so that the hotstrings are available immediately.

	.EXAMPLE
	Save-AliasAsHotstring

	.INPUTS
	None.

	.OUTPUTS
	[System.Void]
	The function does not return anything.

	.NOTES
	Author : nmbell

	.LINK
	Edit-CustomHotstring
	.LINK
	Edit-CustomHotlist
	.LINK
	about_PSExpandLine
	#>

	# Function alias
	[Alias('Save-NativeAlias')]

	# Use cmdlet binding
	[CmdletBinding(
	  HelpURI = 'https://github.com/nmbell/PSExpandLine/blob/main/help/Save-AliasAsHotstring.md'
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
		# Export the hotstrings
		Write-Verbose "[$thisFunctionName]Exporting hotstrings to: $($Module.NativeHotstringsFilePath)"

		Get-Alias `
		| Select-Object Name,Definition `
		| Sort-Object Name `
		| Tee-Object -Variable exportedAliases
		| Export-Csv -Path $Module.NativeHotstringsFilePath -Force # overwrite

		Write-Verbose "[$thisFunctionName]Exported hotstrings: $($exportedAliases.Count)"

		# Mark the file as ReadOnly
		$nativeAliasesFile = Get-Item -Path $Module.NativeHotstringsFilePath
		$nativeAliasesFile.IsReadOnly = $true

		# Reload the module
		Write-Verbose "[$thisFunctionName]Re-importing PSExpandLine module: $($Module.ModulePath)"
		Import-Module -Name $Module.ModulePath -Global -Force -Verbose:$false
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
