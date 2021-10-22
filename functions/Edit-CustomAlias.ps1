function Edit-CustomAlias
{
	<#
	.SYNOPSIS
	Edit the list of custom aliases for use by PSExpandLine.

	.DESCRIPTION
	Edit the list of custom aliases for use by PSExpandLine.
	This command will open a list of user-defined alias expansions with the default editor associated with .csv files.
	If the file does not exist, the command will first create it.
	The command can be run as often as required by the user.
	The command will wait until the file has been closed, and then reload the module so that the aliases are available immediately.
	In order to see the effect of a change without closing the file, simply run:

	PS C:\> Import-Module -Name PSExpandLine -Force

	.EXAMPLE
	Edit-CustomAlias

	.NOTES
	Author : nmbell

	.LINK
	Save-NativeAlias
	.LINK
	about_PSExpandLine
	#>

	# Use cmdlet binding
	[CmdletBinding(
		HelpURI = 'https://github.com/nmbell/PSExpandLine/blob/main/help/Edit-CustomAlias.md'
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
		# Create the file if necessary
		If (!(Test-Path -Path $PSExpandLineCustomAliasesFilePath))
		{
			Write-Verbose "[$thisFunctionName]Creating custom aliases list: $PSExpandLineCustomAliasesFilePath"
			'' `
			| Select-Object Name,Definition `
			| ConvertTo-Csv `
			| Select-Object -First 1 `
			| Out-File -Path $PSExpandLineCustomAliasesFilePath
		}

		# Open the file for editing
		Write-Verbose "[$thisFunctionName]Editing custom aliases list: $PSExpandLineCustomAliasesFilePath"
		Write-Verbose "[$thisFunctionName]Waiting for editor to close..."
		Start-Process -FilePath $PSExpandLineCustomAliasesFilePath -PassThru | Wait-Process

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
