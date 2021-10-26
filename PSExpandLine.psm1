# PSExpandLine 1.0.1
[CmdletBinding()]
Param()


# Set variables
$PSExpandLineNativeAliasesFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'config' -AdditionalChildPath 'PSExpandLine_native.csv'
$PSExpandLineCustomAliasesFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'config' -AdditionalChildPath 'PSExpandLine_custom.csv'


# Include functions
$functionsDirPath = Join-Path -Path $PSScriptRoot -ChildPath 'functions'
ForEach ($file in Get-ChildItem -Path $functionsDirPath -Filter '*.ps1')
{
	. "$($file.FullName)"
}


# Import the aliases
$PSExpandLineAliases = [Ordered]@{}
If (Test-Path -Path $PSExpandLineNativeAliasesFilePath)
{
	Import-Csv -Path $PSExpandLineNativeAliasesFilePath | ForEach-Object { $PSExpandLineAliases.$($_.Name) = $_.Definition }
}
If (Test-Path -Path $PSExpandLineCustomAliasesFilePath)
{
	# custom aliases can overwrite native aliases
	Import-Csv -Path $PSExpandLineCustomAliasesFilePath | ForEach-Object { $PSExpandLineAliases.$($_.Name) = $_.Definition }
}


# Set the key handler for alias expansion
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

	# Get the alias definition
	$aliasDefinition = $null
	If (!$tokenLeftOfCursor.TokenFlags -or $tokenLeftOfCursor.TokenFlags -band 524288) # 524288 = CommandName
	{
		$aliasDefinition = $PSExpandLineAliases[$($tokenLeftOfCursor.Text)]
	}

	# Replace alias with full command name
	If ($aliasDefinition)
	{
		[Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteWord()
		$space = ' '
		If ($cursor2 -lt $buffer.Length -and $buffer.Substring($cursor2,1) -eq ' ') { $space = '' } # don't add a space if there's one already there
		If ($aliasDefinition[0] -eq '{' -and $aliasDefinition[-1] -eq '}') # script block
		{
			$sb = [ScriptBlock]::Create($aliasDefinition.Substring(1,$aliasDefinition.Length-2).Trim())
			$aliasDefinition = Invoke-Command -ScriptBlock $sb -ErrorAction Ignore | Out-String -NoNewline
		}
		If ($aliasDefinition -like '*<PSXLCursor>*')
		{
			$splitDefinition = $aliasDefinition -split '<PSXLCursor>'
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($splitDefinition[0])
			[Microsoft.PowerShell.PSConsoleReadLine]::SetMark()
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($splitDefinition[1])
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($space)
			[Microsoft.PowerShell.PSConsoleReadLine]::ExchangePointAndMark()

		}
		Else
		{
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($aliasDefinition)
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($space)
		}
	}
	Else
	{
		[Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ')
	}

}
Set-PSReadLineKeyHandler -Chord ' ' -ScriptBlock $sb


# Set the key handler for expansion suppression
Set-PSReadLineKeyHandler -Chord 'Shift+SpaceBar' -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ') }


# Export module members
$AliasesToExport   = @()
$CmdletsToExport   = @()
$FunctionsToExport = @('Edit-CustomAlias','Save-NativeAlias')
$VariablesToExport = @()
$moduleMembers =
@{
	'Alias'    = $AliasesToExport
	'Cmdlet'   = $CmdletsToExport
	'Function' = $FunctionsToExport
	'Variable' = $VariablesToExport
}
Export-ModuleMember @moduleMembers
