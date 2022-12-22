elm make $1 --output build/elm.js
if [ $? -eq 0 ]; then
    node ./patch/patch.js ./template-project/App.jsx
else
    exit $?
fi
