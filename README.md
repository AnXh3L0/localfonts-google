# localfonts-google
Copies all Google Fonts to the fonts folder.

## Usage on Linux/MacOS

There are two versions of the script, the `script.sh` has to be run manually and will install the fonts, meanwhile the `persistent.sh` one will set a cron job that runs (by default set to 7 days) and updates your fonts folder with the latest fonts from Google Fonts.

Run either of the scripts using `sh script.sh` or `sh persistent.sh` and it will automatically detect your OS and ask for confirmation.

## Usage on Windows

Tested with Powershell 5 and Powershell 7.

Open a Powershell window as administrator, and run the script:

`.\windows.ps1`

This will run the same process as on Linux, and will set a Task scheduled every 7 days (by default). If you want to change the frequency, you can change the frequency, you can edit the `$CHECK_INTERVAL_DAYS` variable.
