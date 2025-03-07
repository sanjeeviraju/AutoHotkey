@echo off
echo Git LFS Troubleshooting...

echo.
echo === Checking Git LFS installation ===
git lfs install --force

echo.
echo === Verifying tracked patterns ===
git lfs track

echo.
echo === Checking Git LFS locks ===
git lfs locks

echo.
echo === Performing Git LFS fsck (checks integrity) ===
git lfs fsck

echo.
echo === If you need to migrate existing .exe files to LFS: ===
echo git lfs migrate import --include="*.exe" --everything

echo.
echo === If you're still having issues, try this: ===
echo 1. Make sure Git LFS is installed globally: git lfs install --system
echo 2. Check your Git config: git config --list | findstr lfs
echo 3. Ensure .gitattributes is committed: git add .gitattributes ^&^& git commit -m "Update gitattributes"
echo 4. For server_win.exe specifically, try: git lfs track "server_win.exe" (for a specific file)

pause
