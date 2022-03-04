[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseDeclaredVarsMoreThanAssignments','')]

# Set the key handler for hotstring expansion
$sbExpand =
{
	Param ($Key,$Arg)

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
	$textLeftOfCursor  = $buffer.Substring(0,$cursor2)
	$spaceLeftOfCursor = $textLeftOfCursor[-1] -eq ' '
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
	If ($hotstringDefinition -and !$spaceLeftOfCursor)
	{
		[Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor2-$tokenLeftOfCursor.Text.Length,$tokenLeftOfCursor.Text.Length)
		$trailingWhitespace = ' '
		If ($cursor2 -lt $buffer.Length -and $buffer.Substring($cursor2,1) -eq ' ') { $trailingWhitespace = '' } # don't add a space if there's one already there
		If ($hotstringDefinition[0] -eq '{' -and $hotstringDefinition[-1] -eq '}') # script block
		{
			$sbHotstring = [ScriptBlock]::Create($hotstringDefinition.Substring(1,$hotstringDefinition.Length-2).Trim())
			$hotstringDefinition = Invoke-Command -ScriptBlock $sbHotstring -ErrorAction Ignore | Out-String -NoNewline
		}
		$hotstringDefinition = $hotstringDefinition.Replace("`r`n","`n").Replace("`r","`n") # handle line breaks
		If ($hotstringDefinition -like '*<PSXLCursor>*')
		{
			$splitDefinition = $hotstringDefinition -split '<PSXLCursor>'
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($splitDefinition[0])
			[Microsoft.PowerShell.PSConsoleReadLine]::SetMark()
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($splitDefinition[1])
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($trailingWhitespace)
			[Microsoft.PowerShell.PSConsoleReadLine]::ExchangePointAndMark()

		}
		Else
		{
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($hotstringDefinition)
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($trailingWhitespace)
		}
	}
	Else
	{
		[Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ')
	}
}
