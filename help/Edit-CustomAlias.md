# Edit-CustomAlias

## SYNOPSIS
Edit the list of custom aliases for use by PSExpandLine.

## SYNTAX

```
Edit-CustomAlias [<CommonParameters>]
```

## DESCRIPTION
Edit the list of custom aliases for use by PSExpandLine.
This command will open a list of user-defined alias expansions with the default editor associated with .csv files.
If the file does not exist, the command will first create it.
The command can be run as often as required by the user.
The command will wait until the file has been closed, and then reload the module so that the aliases are available immediately.
In order to see the effect of a change without closing the file, simply run:

`Import-Module -Name PSExpandLine -Force`

## EXAMPLES

### EXAMPLE 1
```
Edit-CustomAlias
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS


## OUTPUTS


## NOTES
Author : nmbell

## RELATED LINKS

[Save-NativeAlias](Save-NativeAlias.md)

[about_PSExpandLine](about_PSExpandLine.md)



