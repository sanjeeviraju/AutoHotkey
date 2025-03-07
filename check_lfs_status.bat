@echo off
echo Checking Git LFS status...

echo.
echo === Git LFS Version ===
git lfs version

echo.
echo === Tracked File Patterns ===
git lfs track

echo.
echo === Git LFS Files Status ===git add path\to\server_win.exe
git commit -m "Add server_win.exe"
git pushgit add path\to\server_win.exe
git commit -m "Add server_win.exe"
git pushgit add path\to\server_win.exe
git commit -m "Add server_win.exe"
git push
git lfs status

echo.
echo === Git LFS Environment ===
git lfs env

pause
