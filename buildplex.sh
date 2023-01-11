elm make ./Plex/src/Main.elm --output build/elm.js
if [ $? -eq 0 ]; then
    node ./patch/patch.js ./Plex/App.jsx
else
    exit $?
fi
