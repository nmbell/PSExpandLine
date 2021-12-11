# PSExpandLine 1.1.0

[SHORT DESCRIPTION](#short-description)

[LONG DESCRIPTION](#long-description)

- [Save-AliasAsHotstring](#save-aliasashotstring)

- [Edit-CustomHotstring](#edit-customhotstring)

[QUICK START GUIDE](#quick-start-guide)

1. [Install the module.](#1-install-the-module)

2. [Create hotstrings from native aliases.](#2-create-hotstrings-from-native-aliases)

3. [Create custom hotstrings.](#3-create-custom-hotstrings)

[TRIGGERING HOTSTRING EXPANSION](#triggering-hotstring-expansion)

[DISABLING HOTSTRING EXPANSION](#disabling-hotstring-expansion)

[REPOSITIONING THE CURSOR](#repositioning-the-cursor)

[CUSTOM HOTSTRING EXAMPLES](#custom-hotstring-examples)

[PSREADLINE DOCUMENTATION](#psreadline-documentation)

[RELEASE HISTORY](#release-history)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

## SHORT DESCRIPTION
PSExpandLine is a PowerShell module that automatically expands command aliases and user-defined 'hotstrings' into full commands in the PowerShell console.

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

## LONG DESCRIPTION
PSExpandLine is a PowerShell module that automatically expands command aliases and user-defined 'hotstrings' into full commands in the PowerShell console.\
Three types of hotstring are supported:
- **Native alias expansion**: expands an existing alias into its corresponding command name.
- **Simple hotstring expansion**: expands a user-defined hotstring into an arbitrary text value.
- **Dynamic hotstring expansion**: expands a user-defined hotstring into the result of a script block.

Hotstrings and their expansions are stored in a pair of configuration files under the module folder:
- Native alias hotstrings are stored in `.\config\PSExpandLine_native.csv`.
- Custom hotstrings are stored in `.\config\PSExpandLine_custom.csv`.

Two functions are provided to manage these files:
- `Save-AliasAsHotstring`
- `Edit-CustomHotstring`

### [Save-AliasAsHotstring](help/Save-AliasAsHotstring.md)
This command will create a hotstring definition from each command alias already defined in the current session. The command is designed to be run as often as necessary, such as after a new module has been loaded. The configuration file that stores the hotstrings is marked as read only. It is not intended to be edited by the user. The command will also reload the module so that the hotstrings are available immediately.

### [Edit-CustomHotstring](help/Edit-CustomHotstring.md)
This command will open a list of user-defined hotstring definitions with the default editor associated with `.csv` files (on Linux machines, the file object will be written to the pipeline). If the file does not exist, the command will first create it. The command can be run as often as required by the user. The command will wait until the file has been closed, and then reload the module so that the hotstrings are available immediately. In order to see the effect of a change without closing the file, simply run `Import-Module -Name PSExpandLine -Force` in the console.

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

## QUICK START GUIDE
### 1. Install the module.
The [module](https://www.powershellgallery.com/packages/PSExpandLine/1.1.0) is available through the [PowerShell Gallery](https://docs.microsoft.com/en-us/powershell/scripting/gallery/getting-started). Run the following command in a PowerShell console to install the module:
```
Install-Module -Name PSExpandLine -Force
```
Run the following to import the module into the current session:
```
Import-Module -Name PSExpandLine
```

### 2. Create hotstrings from native aliases.
Simply run:
```
Save-AliasAsHotstring
```
All existing aliases will now automatically expand to their full command name, e.g. typing `gci` will automatically expand to `Get-ChildItem`.

### 3. Create custom hotstrings.
Custom hotstrings can be either simple (the hotstring is replaced with the definition text), or dynamic (the hotstring is replaced with the results of executing a script block). The definitions for both are stored in the same file. To open the file, run:
```
Edit-CustomHotstring
```
(Note: on Linux machines, rather than opening the file in its default editor, the file object will be written to the pipeline.)

The first time the command is run, the file will have only the header row:
```
"Name","Definition"
```
New simple hotstrings should be added in the same format, e.g.:
```
"ghf","Get-Help -Full -Name"
"gho","Get-Help -Online -Name"
```
Dynamic hotstrings are recognized when the first character of the definition is an opening brace `{` and the last character is a closing brace `}`. The text between the braces is executed as a PowerShell command, and the result is converted to string output and used to replace the hotstring, e.g.:
```
"today","{(Get-Date).DayOfWeek}"
```
To avoid unexpected behavior, ensure that the output of the definition script block for dynamic hotstrings is a scalar string value.\
Custom hotstrings that have the same name as a native alias will override the native alias hotstring.

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

## TRIGGERING HOTSTRING EXPANSION
Hotstring expansion is triggered with the `Spacebar` key. When pressed, the token immediately to the left of the cursor is examined, and if it matches a defined hotstring, the hotstring is replaced with the definition. Otherwise, a regular space is inserted at the cursor position. When an expansion is triggered and the cursor is either at the far right of the input or is not followed by a space, a space is also inserted. However, when a word is split by pressing `Spacebar`, and the characters to the left of the cursor match a hotstring, the hotstring is not expanded, because the tokens are examined before the space is inserted. In this case, simply hitting space again will trigger the expansion.

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

## DISABLING HOTSTRING EXPANSION
Native alias hotstrings can be disabled by creating a custom hotstring with the same name that has an empty definition, e.g.:
```
"gci",""
```
To insert a space after a defined hotstring without triggering expansion, use `Shift+SpaceBar` instead of `Spacebar`.\
Note: expansion is triggered *only* when the token to the left of the cursor is a defined hotstring. Otherwise, `Spacebar` behaves normally.

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

## REPOSITIONING THE CURSOR
Sometimes it is useful to be able to reposition the cursor after a hotstring has been expanded, e.g. to set it between a pair of quotation marks. When `<PSXLCursor>` is included in the definition, this text will be removed during expansion, and when the expansion is complete the cursor will be placed at its position, e.g.:
```
"ofp","Out-File -Path ""<PSXLCursor>"""
```
To avoid unexpected behavior, ensure that the definition contains, at most, one instance of `<PSXLCursor>`.

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

## CUSTOM HOTSTRING EXAMPLES
Below are some examples of custom hotstrings:
```
"desktoppath","{[Environment]::GetFolderPath('Desktop')}"
"desktopvar","[Environment]::GetFolderPath('Desktop')"
"sle","Select-Object -ExpandProperty"
"psco","[PSCustomObject]@{ xNamex = $xValuex }"
"dbgon","$DebugPreference = 'Continue'"
"dbgoff","$DebugPreference = 'SilentlyContinue'"
"gettodayslogs","{
	$today = (Get-Date).ToString('yyyy-MM-dd')
	$logsDir = 'C:\MyLogs'
	""Get-ChildItem -Path '$logsDir' -Recurse -Filter *.txt | Where-Object Name -like '*$today*'""
}"
```
Note: when the csv values are quoted, a literal double-quote `"` in the definition should be expressed with a double double-quote `""` in the `.csv` file.

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

## PSREADLINE DOCUMENTATION
PSReadLine reference documentation can be found [here](https://docs.microsoft.com/en-us/powershell/module/psreadline/).

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

## RELEASE HISTORY
### 1.1.0 (2021-12-10)
- Update language and code throughout to refer to strings that will trigger an expansion as 'hotstrings'.
- Rename functions to be more descriptive; include aliases for previous names.
- Force reloading of module into Global scope to preserve appearance in Get-Module results.
- Add .INPUTS and .OUTPUTS sections in each function's help.
- Add OutputType declaration to each function.
- Update Edit-CustomHotstring to write a file object to the pipeline on Linux machines.
- Add descriptions to PSReadLine key handlers.
- Add OnRemove logic.
- Update manifest with minimum versions for PowerShell host and PSReadLine.
- Add ProjectUri, IconUri, and ReleaseNotes values to manifest.
- Add logo file for PowerShellGallery.com.
- Other minor code changes.

### 1.0.1 (2021-10-26)
- Update file path handling for cross-platform.

### 1.0.0 (2021-10-21)
- Initial release.

