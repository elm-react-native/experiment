## Idea

The idea is to replace virtual-dom and browser package without React virtual dom and return react component instead of elm node when calling the `Html.node` function.

But, I haven't figured out how to patch the elm compiler to allow the kernel code and the current implementation base on _nasty_ monkey patch (by `patch/patch.js` file).

## Demo

On MacOS

- pull the template-project submodule
- install elm, nodejs and expo
- execute npm install in template-project
- execute `./rundemo.sh demo/ButtonExample.elm`
- execute `./build.sh demo/ButtonExample.elm` to generate `App.jsx` after made changes.
