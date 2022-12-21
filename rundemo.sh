./build.sh $1
if [ $? -eq 0 ]; then
    cd template-project
    if [ ! -d "node_modules" ]
    then
        npm install
    fi
    npm run ios
fi
