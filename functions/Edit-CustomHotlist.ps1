function Edit-CustomHotlist
{
	<#
	.SYNOPSIS
	Edit the list of custom hotlists for use by PSExpandLine.

	.DESCRIPTION
	Edit the list of custom hotlists for use by PSExpandLine.
	This command will open a list of user-defined hotlist definitions with the default editor associated with .csv files (on Linux machines, the file object will be written to the pipeline).
	If the file does not exist, the command will first create it.
	The command can be run as often as required by the user.
	The command will wait until the file has been closed, and then reload the module so that the hotlists are available immediately.
	In order to see the effect of a change without closing the file, simply run:

	PS C:\> Import-Module -Name PSExpandLine -Force

	.EXAMPLE
	Edit-CustomHotlist

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
	Save-AliasAsHotstring
	.LINK
	about_PSExpandLine
	#>

	# Function alias
	# [Alias('Edit-CustomAlias')]

	# Use cmdlet binding
	[CmdletBinding(
		HelpURI = 'https://github.com/nmbell/PSExpandLine/blob/main/help/Edit-CustomHotlist.md'
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
		If (!(Test-Path -Path $Module.CustomHotListsFilePath))
		{
			Write-Verbose "[$thisFunctionName]Creating custom hotlists list: $($Module.CustomHotListsFilePath)"
			[PSCustomObject]@{ Name = ''; IsDefault = ''; Separator = ''; Definition = '' } `
			| Select-Object Name,IsDefault,Separator,Definition `
			| ConvertTo-Csv `
			| Select-Object -First 1 `
			| Out-File -FilePath $Module.CustomHotListsFilePath

			ForEach ($i in 1..9)
			{
				Add-Content -Path $Module.CustomHotListsFilePath -Value "`"Ctrl+$i`",`"0`",`"`",`"`""
			}
		}

		# Open the file for editing
		If ($IsLinux)
		{
			Get-Item -Path $Module.CustomHotListsFilePath
		}
		Else
		{
			Write-Verbose "[$thisFunctionName]Editing custom hotlists list: $($Module.CustomHotListsFilePath)"
			Write-Verbose "[$thisFunctionName]Waiting for editor to close..."
			Start-Process -FilePath $Module.CustomHotListsFilePath -PassThru | Wait-Process

			# Reload the module
			Write-Verbose "[$thisFunctionName]Re-importing PSExpandLine module: $($Module.ModulePath)"
			Import-Module -Name $Module.ModulePath -Global -Force -Verbose:$false
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
