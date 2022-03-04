# Edit-CustomHotlist

## SYNOPSIS
Edit the list of custom hotlists for use by PSExpandLine.

## SYNTAX

```
Edit-CustomHotlist [<CommonParameters>]
```

## DESCRIPTION
Edit the list of custom hotlists for use by PSExpandLine.
This command will open a list of user-defined hotlist definitions with the default editor associated with .csv files (on Linux machines, the file object will be written to the pipeline).
If the file does not exist, the command will first create it.
The command can be run as often as required by the user.
The command will wait until the file has been closed, and then reload the module so that the hotlists are available immediately.
In order to see the effect of a change without closing the file, simply run:

`Import-Module -Name PSExpandLine -Force`

## EXAMPLES

### EXAMPLE 1
```
Edit-CustomHotlist
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

None.

## OUTPUTS

[System.Void]

The function does not return anything.

## NOTES
Author : nmbell

## RELATED LINKS

[Edit-CustomHotstring](Edit-CustomHotstring.md)

[Save-AliasAsHotstring](Save-AliasAsHotstring.md)

[about_PSExpandLine](about_PSExpandLine.md)



