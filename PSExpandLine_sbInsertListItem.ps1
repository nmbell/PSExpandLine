[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseDeclaredVarsMoreThanAssignments','')]

# Set the key handlers for hotlist insertion
$sbInsert =
{
	Param ($Key,$Arg)

	If ($script:matchList)
	{
		# Initialize variables
		$buffer             = $null
		$cursor             = $null
		$matchedItem        = $null
		$bufferLeftOfCursor = $null
		$insertText         = $null

		# Get the contents of the buffer
		[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([Ref]$buffer,[Ref]$cursor)

		# Find the buffer text to the left of the cursor
		$bufferLeftOfCursor = $buffer.Substring(0,$cursor)

		# If the buffer text to the left of the cursor matches any of the list items, set the pointer to the position of that item; prefer longer and earlier matches
		ForEach ($matchKey in $script:matchList.Keys)
		{
			$isMatch    = $false
			$matchQuote = $null
			If ($bufferLeftOfCursor -like "*$matchKey")
			{
				$isMatch    = $true
				$matchQuote = ''
			}
			If ($bufferLeftOfCursor -like "*'$matchKey'")
			{
				$isMatch    = $true
				$matchQuote = ''''
			}
			If ($bufferLeftOfCursor -like "*`"$matchKey`"")
			{
				$isMatch    = $true
				$matchQuote = '"'
			}
			If ($isMatch)
			{
				If ($Key.Key.ToString() -eq 'DownArrow') { $i =  1 }
				If ($Key.Key.ToString() -eq 'UpArrow'  ) { $i = -1 }
				$matchedItem     = "$matchQuote$matchKey$matchQuote"
				$script:listPosn = ($script:matchList[$matchKey]+$script:listItems.Length+$i)%($script:listItems.Length) # move the pointer to the next/previous item
				Break
			}
		}

		# Determine the text to be inserted
		$isShiftUsed = ($Key.Modifiers -band [System.ConsoleModifiers]::Shift  ) -eq [System.ConsoleModifiers]::Shift
		$isCtrlUsed  = ($Key.Modifiers -band [System.ConsoleModifiers]::Control) -eq [System.ConsoleModifiers]::Control
		If ( $isCtrlUsed -and !$isShiftUsed) { $insertQuote = ''   }
		If (!$isCtrlUsed -and  $isShiftUsed) { $insertQuote = '''' }
		If ( $isCtrlUsed -and  $isShiftUsed) { $insertQuote = '"'  }
		$insertText = "$insertQuote$($script:listItems[$script:listPosn].ToString())$insertQuote"

		# If there's a match, replace with the text of the next list item, otherwise just insert
		If ($matchedItem)
		{
			[Microsoft.PowerShell.PSConsoleReadLine]::Replace($cursor-$matchedItem.Length,$matchedItem.Length,$insertText)
		}
		Else
		{
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert($insertText)
		}
	}
}
