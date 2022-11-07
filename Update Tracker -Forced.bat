@echo off
set DownloadUrl=https://github.com/besteon/Ironmon-Tracker/archive/main.tar.gz
set ArchiveFile=Ironmon-Tracker-main.tar.gz
set DownloadFolder=Ironmon-Tracker-main

echo Downloading the latest Ironmon Tracker version.
::curl -L "%DownloadUrl%"

echo Extracting downloaded files.
::tar -xf "%ArchiveFile%"
::del "%ArchiveFile%"

echo Applying the update; copying over files.
::rmdir "%DownloadFolder%\.vscode" /s /q
::rmdir "%DownloadFolder%\ironmon_tracker\Debug" /s /q
::del "%DownloadFolder%\.editorconfig" /q
::del "%DownloadFolder%\.gitattributes" /q
::del "%DownloadFolder%\.gitignore" /q
::del "%DownloadFolder%\README.md" /q
::xcopy "%DownloadFolder%" /s /y /q
::rmdir "%DownloadFolder%" /s /q

echo Update complete.
timeout /t 3

::pause
exit