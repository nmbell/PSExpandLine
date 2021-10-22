function Save-NativeAlias
{
	<#
	.SYNOPSIS
	Saves a list of native aliases for use by PSExpandLine.

	.DESCRIPTION
	Saves a list of native aliases for use by PSExpandLine.
	This command will create a list of alias expansions from the aliases already defined in the current session.
	The command is designed to be run as often as necessary to capture the current set of aliases, such as after a new module has been loaded.
	The configuration file that stores the aliases is marked as read only. It is not intended to be edited by the user.
	The command will also reload the module so that the aliases are available immediately.

	.EXAMPLE
	Save-NativeAlias

	.NOTES
	Author : nmbell

	.LINK
	Edit-CustomAlias
	.LINK
	about_PSExpandLine
	#>

	# Use cmdlet binding
	[CmdletBinding(
	  HelpURI = 'https://github.com/nmbell/PSExpandLine/blob/main/help/Save-NativeAlias.md'
	)]

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
		$modulePath = Split-Path -Path $PSScriptRoot -Parent
	}

	PROCESS
	{
		# Export the aliases
		Write-Verbose "[$thisFunctionName]Exporting aliases to: $PSExpandLineNativeAliasesFilePath"

		Get-Alias `
		| Select-Object Name,Definition `
		| Sort-Object Name `
		| Tee-Object -Variable exportedAliases
		| Export-Csv -Path $PSExpandLineNativeAliasesFilePath -Force # overwrite

		Write-Verbose "[$thisFunctionName]Exported aliases: $($exportedAliases.Count)"

		# Mark the file as ReadOnly
		$nativeAliasesFile = Get-Item -Path $PSExpandLineNativeAliasesFilePath
		$nativeAliasesFile.IsReadOnly = $true

		# Reload the module
		Write-Verbose "[$thisFunctionName]Re-importing PSExpandLine module: $modulePath"
		Import-Module -Name $modulePath -Force -Verbose:$false
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
