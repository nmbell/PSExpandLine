# PSExpandLine 1.0.1


## SHORT DESCRIPTION
PSExpandLine is a PowerShell module that automatically expands command aliases into full commands in the PowerShell console.


## LONG DESCRIPTION
PSExpandLine is a PowerShell module that automatically expands command aliases into full commands in the PowerShell console.\
Three types of alias are supported:
- **Native alias expansion**: expands an existing alias into its corresponding command name.
- **Custom alias expansion**: expands a user-defined alias into an arbitrary text value.
- **Dynamic alias expansion**: expands a user-defined alias into the result of a script block.

Aliases and their expansions are stored in a pair of configuration files under the module folder:
- Native aliases are stored in `.\config\PSExpandLine_native.csv`.
- Custom aliases are stored in `.\config\PSExpandLine_custom.csv`.

Two functions are provided to manage these files:
- `Save-NativeAlias`
- `Edit-CustomAlias`

### [Save-NativeAlias](Save-NativeAlias.md)
This command will create a list of alias expansions from the aliases already defined in the current session. The command is designed to be run as often as necessary to capture the current set of aliases, such as after a new module has been loaded. The configuration file that stores the aliases is marked as read only. It is not intended to be edited by the user. The command will also reload the module so that the aliases are available immediately.

### [Edit-CustomAlias](Edit-CustomAlias.md)
This command will open a list of user-defined alias expansions with the default editor associated with `.csv` files. If the file does not exist, the command will first create it. The command can be run as often as required by the user. The command will wait until the file has been closed, and then reload the module so that the aliases are available immediately. In order to see the effect of a change without closing the file, simply run `Import-Module -Name PSExpandLine -Force` in the console.


## QUICK START GUIDE
### 1. Install the module.
The [module](https://www.powershellgallery.com/packages/PSExpandLine/1.0.1) is available through the [PowerShell Gallery](https://docs.microsoft.com/en-us/powershell/scripting/gallery/getting-started). Run the following command in a PowerShell console to install the module:
```
Install-Module -Name PSExpandLine -Force
```
Run the following to import the module into the current session:
```
Import-Module -Name PSExpandLine
```

### 2. Save native aliases.
Simply run:
```
Save-NativeAlias
```
All existing aliases will now automatically expand to their full command name, e.g. typing `gci` will automatically expand to `Get-ChildItem`.

### 3. Create custom aliases.
Custom aliases can be either simple (the alias is replaced with the definition text), or dynamic (the alias is replaced with the results of executing a script block). The definitions for both are stored in the same file. To open the file, run:
```
Edit-CustomAlias
```
The first time the command is run, the file will have only the header row:
```
"Name","Definition"
```
New simple aliases should be added in the same format, e.g.:
```
"ghf","Get-Help -Full -Name"
"gho","Get-Help -Online -Name"
```
Dynamic aliases are recognized when the first character of the definition is an opening brace `{` and the last character is a closing brace `}`. The text between the braces is executed as a PowerShell command, and the result is converted to string output and used to replace the alias, e.g.:
```
"today","{(Get-Date).DayOfWeek}"
```
To avoid unexpected behavior, ensure that the output of the definition script block for dynamic aliases is a scalar string value.\
Custom aliases that have the same name as a native alias will override the native alias.


## TRIGGERING ALIAS EXPANSION
Alias expansion is triggered with the `Spacebar` key. When pressed, the token immediately to the left of the cursor is examined, and if it matches a defined alias, the alias is replaced with the definition. Otherwise, a regular space is inserted at the cursor position. When an expansion is triggered and the cursor is either at the far right of the input or is not followed by a space, a space is also inserted. However, when a word is split by pressing `Spacebar`, and the characters to the left of the cursor are an alias, the alias is not expanded, because the tokens are examined before the space is inserted. In this case, simply moving the cursor back to the end of the alias and hitting space again will trigger the expansion.


## DISABLING ALIAS EXPANSION
Native aliases can be disabled by creating a custom alias with the same name that has an empty definition, e.g.:
```
"gci",""
```
To insert a space after a defined alias without triggering expansion, use `Shift+SpaceBar` instead of `Spacebar`.\
Note: expansion is triggered *only* when the token to the left of the cursor is a defined alias. Otherwise, `Spacebar` behaves normally.


## REPOSITIONING THE CURSOR
Sometimes it is useful to be able to reposition the cursor after an alias has been expanded, e.g. to set it between a pair of quotation marks. When `<PSXLCursor>` is included in the definition, this text will be removed during expansion, and when the expansion is complete the cursor will be placed at its position, e.g.:
```
"ofp","Out-File -Path ""<PSXLCursor>"""
```
To avoid unexpected behavior, ensure that the definition contains, at most, one instance of `<PSXLCursor>`.


## CUSTOM ALIAS EXAMPLES
Below are some examples of custom aliases:
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
Note: when the csv values are quoted, a literal double-quote `"` in the definition is expressed with a double double-quote `""` in the `.csv` file.


## PSREADLINE DOCUMENTATION
PSReadLine reference documentation can be found [here](https://docs.microsoft.com/en-us/powershell/module/psreadline/).


## RELEASE HISTORY
### 1.0.1 (2021-10-26)
  - Update file path handling for cross-platform

### 1.0.0 (2021-10-21)
  - Initial release
