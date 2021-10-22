# Save-NativeAlias

## SYNOPSIS
Saves a list of native aliases for use by PSExpandLine.

## SYNTAX

```
Save-NativeAlias [<CommonParameters>]
```

## DESCRIPTION
Saves a list of native aliases for use by PSExpandLine.
This command will create a list of alias expansions from the aliases already defined in the current session.
The command is designed to be run as often as necessary to capture the current set of aliases, such as after a new module has been loaded.
The configuration file that stores the aliases is marked as read only. It is not intended to be edited by the user.
The command will also reload the module so that the aliases are available immediately.

## EXAMPLES

### EXAMPLE 1
```
Save-NativeAlias
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS


## OUTPUTS


## NOTES
Author : nmbell

## RELATED LINKS

[Edit-CustomAlias](Edit-CustomAlias.md)

[about_PSExpandLine](about_PSExpandLine.md)



