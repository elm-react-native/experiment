## Idea

The idea is to replace virtual-dom and browser package with React virtual dom and return react component instead of elm node when calling the `Html.node` function.

The current implementation is based on _nasty_ monkey patch (by `patch/patch.js` file), and I will try to use kernel code (which requires patching the elm compiler) instead.

## Demo

On MacOS

- pull the template-project submodule
- install elm, nodejs and expo
- execute npm install in template-project
- execute `./rundemo.sh demo/ButtonExample.elm`
- execute `./build.sh demo/ButtonExample.elm` to generate `App.jsx` after made changes.
