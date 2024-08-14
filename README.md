# localfonts-google
Copies all Google Fonts to the fonts folder.

## Usage on Linux/MacOS

There are two versions of the script, the `script.sh` has to be run manually and will install the fonts, meanwhile the `persistent.sh` one will set a cron job that runs (by default set to 7 days) and updates your fonts folder with the latest fonts from Google Fonts.

Run either of the scripts using `sh script.sh` or `sh persistent.sh` and it will automatically detect your OS and ask for confirmation.

## Usage on Windows

Tested with Git Bash.

1. First, run the script:
   ```bash
   ./windows.sh
   ```
2. After that has finished, open `google-fonts/` with the File Explorer.
   1. Select all files. (Ctrl+A)
   2. Right-click and click Install. 

