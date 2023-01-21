The idea is to replace virtual-dom and browser package with React virtual dom and return react component instead of elm node when calling the `Html.node` function.

The current implementation is based on _nasty_ monkey patch (by `packages/transformer/patcher`), and I will try to use kernel code (which requires patching the elm compiler) instead.

## packages/

This folder contains elm packages wraps react native built-in components as well as some other community libraries.
Also there is metro transformer to patch the output file of elm compiler.

## demo/

This contains examples translate from React Native's offical document.

### Run On MacOS

Requires elm, nodejs and expo.

- cd demo
- npm install
- npm start
- execute `./build demo` (same as `elm make demo/src/Demo.elm --output ./demo/elm.js`) after made changes.

## plex/

This is an iOS [Plex](https://www.plex.tv) client, a video steaming app, which can browsing / steaming from local plex server. Android is NOT working for now.

### Run On MacOS

Requires elm and nodejs.

- cd plex
- npm install
- cd ios && pod install
- npm start
- execute `./build plex` after made changes.
