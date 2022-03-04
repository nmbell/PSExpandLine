# PSExpandLine 2.0.0
[CmdletBinding()]
Param()


# Set variables
$Module = @{}
$Module.ModulePath               = $PSCommandPath
$Module.DefaultHotlist           = $null
$Module.NativeHotstringsFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'config' -AdditionalChildPath 'PSExpandLine_native.csv'
$Module.CustomHotstringsFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'config' -AdditionalChildPath 'PSExpandLine_custom.csv'
$Module.CustomHotListsFilePath   = Join-Path -Path $PSScriptRoot -ChildPath 'config' -AdditionalChildPath 'PSExpandLine_hotlist.csv'
$Module.Name                     = 'PSExpandLine'
$script:listPosn                 = 0


# Include functions
$functionsDirPath = Join-Path -Path $PSScriptRoot -ChildPath 'functions'
ForEach ($file in Get-ChildItem -Path $functionsDirPath -Filter '*.ps1')
{
	. "$($file.FullName)"
}


# Import the hotstrings
$hotstrings = [Ordered]@{}
If (Test-Path -Path $Module.NativeHotstringsFilePath)
{
	Import-Csv -Path $Module.NativeHotstringsFilePath | ForEach-Object { $hotstrings.$($_.Name) = $_.Definition }
}
If (Test-Path -Path $Module.CustomHotstringsFilePath)
{
	# custom hotstrings can overwrite native hotstrings
	Import-Csv -Path $Module.CustomHotstringsFilePath | ForEach-Object { $hotstrings.$($_.Name) = $_.Definition }
}


# Import the hotlists
$script:hotlists = @{}
If (Test-Path -Path $Module.CustomHotListsFilePath)
{
	Import-Csv -Path $Module.CustomHotListsFilePath `
	| Where-Object Name -match 'Ctrl\+[1-9]' `
	| ForEach-Object {

		$chord     = $_.Name
		$isDefault = [Bool][Int]$_.IsDefault
		$separator = $_.Separator
		$listItems = $_.Definition

		If ($listItems[0] -eq '{' -and $listItems[-1] -eq '}') # script block
		{
			$sbListItems = [ScriptBlock]::Create($listItems.Substring(1,$listItems.Length-2).Trim())
			$listItems = Invoke-Command -ScriptBlock $sbListItems -ErrorAction Ignore `
						 | ForEach-Object { $_.ToString().Trim() } `
						 | Select-Object -Unique
		}
		Else
		{
			$listItems = $listItems.Split($separator) | Select-Object -Unique
		}
		$script:hotlists[$chord] = $listItems

		If ($isDefault)
		{
			$Module.DefaultHotlist = $chord
		}
	}
}


# Set the key handler for hotstring expansion
. "$(Join-Path -Path $PSScriptRoot -ChildPath 'PSExpandLine_sbExpandHotstring.ps1')"
Set-PSReadLineKeyHandler -Chord 'Spacebar' -ScriptBlock $sbExpand -BriefDescription $Module.Name -Description 'Hotstrings: expand a defined hotstring to its value.'


# Set the key handler for suppression of hotstring expansion
Set-PSReadLineKeyHandler -Chord 'Shift+SpaceBar' -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ') } -BriefDescription $Module.Name -Description 'Hotstrings: suppress expansion of a defined hotstring.'


# Set key handlers for hotlist selection
. "$(Join-Path -Path $PSScriptRoot -ChildPath 'PSExpandLine_sbSelectHotlist.ps1')"
ForEach ($chord in $script:hotlists.Keys)
{
	$displayList = $($script:hotlists[$chord] -join ' ')
	$displayList = $displayList.Length -gt 75 ? $displayList.Substring(0,74)+'…' : $displayList
	Set-PSReadLineKeyHandler -Chord $chord -ScriptBlock $sbSelect -BriefDescription $Module.Name -Description "Hotlists: select hotlist: $displayList"
}
Set-PSReadLineKeyHandler -Chord 'Ctrl+0' -ScriptBlock $sbSelect -BriefDescription $Module.Name -Description "Hotlists: deactivate all hotlists."


# Set the default hotlist
If ($Module.DefaultHotlist)
{
	& $sbSelect
}


# Set the key handlers for hotlist insertion
. "$(Join-Path -Path $PSScriptRoot -ChildPath 'PSExpandLine_sbInsertListItem.ps1')"
Set-PSReadLineKeyHandler -Chord 'Ctrl+DownArrow'       -ScriptBlock $sbInsert -BriefDescription $Module.Name -Description 'Hotlists: insert the next     item in the selected hotlist.'
Set-PSReadLineKeyHandler -Chord 'Ctrl+UpArrow'         -ScriptBlock $sbInsert -BriefDescription $Module.Name -Description 'Hotlists: insert the previous item in the selected hotlist.'
Set-PSReadLineKeyHandler -Chord 'Shift+DownArrow'      -ScriptBlock $sbInsert -BriefDescription $Module.Name -Description 'Hotlists: insert the next     item in the selected hotlist with single-quotes.'
Set-PSReadLineKeyHandler -Chord 'Shift+UpArrow'        -ScriptBlock $sbInsert -BriefDescription $Module.Name -Description 'Hotlists: insert the previous item in the selected hotlist with single-quotes.'
Set-PSReadLineKeyHandler -Chord 'Ctrl+Shift+DownArrow' -ScriptBlock $sbInsert -BriefDescription $Module.Name -Description 'Hotlists: insert the next     item in the selected hotlist with double-quotes.'
Set-PSReadLineKeyHandler -Chord 'Ctrl+Shift+UpArrow'   -ScriptBlock $sbInsert -BriefDescription $Module.Name -Description 'Hotlists: insert the previous item in the selected hotlist with double-quotes.'


# Export module members
$AliasesToExport   = @()
$CmdletsToExport   = @()
$FunctionsToExport = @('Edit-CustomHotlist','Edit-CustomHotstring','Save-AliasAsHotstring')
$VariablesToExport = @('PSExpandLine')
$moduleMembers =
@{
	'Alias'    = $AliasesToExport
	'Cmdlet'   = $CmdletsToExport
	'Function' = $FunctionsToExport
	'Variable' = $VariablesToExport
}
Export-ModuleMember @moduleMembers


# Add OnRemove logic
$onRemove =
{
	Get-PSReadLineKeyHandler | Where-Object Function -eq PSExpandLine | ForEach-Object { Remove-PSReadLineKeyHandler -Chord $_.Key }
}
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = $onRemove
