@echo off
echo Setting up Git LFS for this repository...

echo Installing Git LFS...
git lfs install

echo Configuring Git LFS to track .exe files...
git lfs track "*.exe"

echo Adding .gitattributes to Git...
git add .gitattributes

echo Git LFS setup complete!
echo.
echo Now you can add your server_win.exe file with:
echo git add path\to\server_win.exe
echo git commit -m "Add server_win.exe file"
echo git push
echo.
echo If you already tried to commit the file before, you may need to:
echo git rm --cached path\to\server_win.exe
echo git add path\to\server_win.exe
echo git commit -m "Add server_win.exe using Git LFS"
echo git push
pause
