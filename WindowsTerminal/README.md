# Windows Terminal

Config file for my windows terminal.

## What did I change?

* default is cmd.exe
* don't use `acrylicOpacity`
* `ctrl+d` closes tab
* profiles are reordered (cmd, debian, powershell, ubuntu, azure)
* added julia (after cmd) - icon must be placed next to `settings.json`
* added git bash (after julia)
* set `tabTitle` names
* set `duplicateTab` command
* set `fontSize` to 9 for all profiles
* hide unused profiles
* maximize window when launched
* new profile for demoing git bash
* copy and paste with ctrl+shift

## Turning of visual bell

Here are just the links:
* Terminal Preview has support for BEL character [link](https://docs.microsoft.com/en-us/windows/terminal/customize-settings/profile-settings#bell-settings-preview)
* https://github.com/microsoft/terminal/issues/7688
* https://tldp.org/HOWTO/Visual-Bell-8.html
  * `.inputrc` had to be created
* Git for Windows `.bashrc` issue
  * https://stackoverflow.com/questions/6883760/git-for-windows-bashrc-or-equivalent-configuration-files-for-git-bash-shell
  * https://github.com/git-for-windows/git/issues/191

## Resources

* https://www.howtogeek.com/426346/how-to-customize-the-new-windows-terminal-app/
* http://www.donovanbrown.com/post/How-to-add-profiles-to-the-new-Windows-Terminal
* [Documentation](https://github.com/microsoft/terminal/blob/master/doc/user-docs/index.md)
* [Profiles.json Documentation](https://github.com/microsoft/terminal/blob/master/doc/cascadia/SettingsSchema.md)