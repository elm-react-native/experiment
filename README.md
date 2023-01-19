## core/

The idea is to replace virtual-dom and browser package with React virtual dom and return react component instead of elm node when calling the `Html.node` function.

The current implementation is based on _nasty_ monkey patch (by `core/patch/patch.js` file), and I will try to use kernel code (which requires patching the elm compiler) instead.

## demo/

This contains examples translate from React Native's office document.

Run On MacOS

Requires elm, nodejs and expo

- cd demo
- npm install
- npm start
- execute `./build demo` to generate after made changes.

## plex/

This is a [Plex](https://www.plex.tv) client, a video steaming app, which can browsing / steaming a local plex server.

Run On MacOS

Requires elm and nodejs

- cd plex
- npm install
- npm start
- execute `./build plex` to generate after made changes.
