# Save-AliasAsHotstring

## SYNOPSIS
Creates a hotstring from each command alias in the current session.

## SYNTAX

```
Save-AliasAsHotstring [<CommonParameters>]
```

## DESCRIPTION
Creates a hotstring from each command alias in the current session.
This command will create a hotstring definition from each command alias already defined in the current session.
The command is designed to be run as often as necessary to capture the current aliases, such as after a new module has been loaded.
The configuration file that stores the hotstrings is marked as read only. It is not intended to be edited by the user.
The command will also reload the module so that the hotstrings are available immediately.

## EXAMPLES

### EXAMPLE 1
```
Save-AliasAsHotstring
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

[Edit-CustomHotlist](Edit-CustomHotlist.md)

[about_PSExpandLine](about_PSExpandLine.md)



