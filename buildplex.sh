./build.sh plex/Main.elm
if [ $? -eq 0 ]; then
    cp -r ./plex/assets ./template-project/
else
    exit $?
fi
