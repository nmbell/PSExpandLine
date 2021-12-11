# PSExpandLine 1.1.1
[CmdletBinding()]
Param()


# Set variables
$PSExpandLine = @{}
$PSExpandLine.NativeHotstringsFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'config' -AdditionalChildPath 'PSExpandLine_native.csv'
$PSExpandLine.CustomHotstringsFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'config' -AdditionalChildPath 'PSExpandLine_custom.csv'
$PSExpandLine.ModulePath               = $PSCommandPath


# Include functions
$functionsDirPath = Join-Path -Path $PSScriptRoot -ChildPath 'functions'
ForEach ($file in Get-ChildItem -Path $functionsDirPath -Filter '*.ps1')
{
	. "$($file.FullName)"
}


# Import the hotstrings
$hotstrings = [Ordered]@{}
If (Test-Path -Path $PSExpandLine.NativeHotstringsFilePath)
{
	Import-Csv -Path $PSExpandLine.NativeHotstringsFilePath | ForEach-Object { $hotstrings.$($_.Name) = $_.Definition }
}
If (Test-Path -Path $PSExpandLine.CustomHotstringsFilePath)
{
	# custom hotstrings can overwrite native hotstrings
	Import-Csv -Path $PSExpandLine.CustomHotstringsFilePath | ForEach-Object { $hotstrings.$($_.Name) = $_.Definition }
}


# Set the key handler for hotstring expansion
$sb =
{
	# Get the contents of the buffer
	$ast         = $null
	$tokens      = $null
	$parseErrors = $null
	$cursor1     = $null
	$buffer      = $null
	$cursor2     = $null
	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([Ref]$ast,[Ref]$tokens,[Ref]$parseErrors,[Ref]$cursor1)
	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([Ref]$buffer,[Ref]$cursor2)

	# Find the token immediately before the cursor
	$textLeftOfCursor  = $buffer.Substring(0,$cursor2).Trim()
	$tokenLeftOfCursor = $null
	ForEach ($token in $tokens)
	{
		$tokenLeftOfCursor = $token

		# Remove token text from the buffer text until there's nothing left
		If ($textLeftOfCursor.StartsWith($token.Text))
		{
			$textLeftOfCursor = $textLeftOfCursor.Substring($token.Text.Length).Trim()
		}
		If (!$textLeftOfCursor)
		{
			Break
		}
	}

	# Get the hotstring definition
	$hotstringDefinition = $null
	If (!$tokenLeftOfCursor.TokenFlags -or $tokenLeftOfCursor.TokenFlags -band 524288) # 524288 = CommandName
	{
		$hotstringDefinition = $hotstrings[$($tokenLeftOfCursor.Text)]
	}

	# Replace hotstring with full command name
	If ($hotstringDefinition)
	{
		[Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteWord()
		$space = ' '
		If ($cursor2 -lt $buffer.Length -and $buffer.Substring($cursor2,1) -eq ' ') { $space = '' } # don't add a space if there's one already there
		If ($hotstringDefinition[0] -eq '{' -and $hotstringDefinition[-1] -eq '}') # script block
		{
			$sb = [ScriptBlock]::Create($hotstringDefinition.Substring(1,$hotstringDefinition.Length-2).Trim())
			$hotstringDefinition = Invoke-Command -ScriptBlock $sb -ErrorAction Ignore | Out-String -NoNewline
		}
		If ($hotstringDefinition -like '*<PSXLCursor>*')
		{
			$splitDefinition = $hotstringDefinition -split '<PSXLCursor>'
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($splitDefinition[0])
			[Microsoft.PowerShell.PSConsoleReadLine]::SetMark()
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($splitDefinition[1])
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($space)
			[Microsoft.PowerShell.PSConsoleReadLine]::ExchangePointAndMark()

		}
		Else
		{
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($hotstringDefinition)
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($space)
		}
	}
	Else
	{
		[Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ')
	}

}
Set-PSReadLineKeyHandler -BriefDescription 'PSExpandLine' -Chord ' ' -ScriptBlock $sb -Description 'Expand a defined expansion key string to its value.'


# Set the key handler for expansion suppression
Set-PSReadLineKeyHandler -BriefDescription 'PSExpandLine' -Chord 'Shift+SpaceBar' -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ') } -Description 'Suppress expansion of a defined expansion key string.'


# Export module members
$AliasesToExport   = @()
$CmdletsToExport   = @()
$FunctionsToExport = @('Save-AliasAsHotstring','Edit-CustomHotstring')
$VariablesToExport = @()
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
