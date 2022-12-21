Experiment with building React native app in elm.

The idea is to replace virtual-dom and browser package without React virtual dom and return react component instead of elm node when calling the `Html.node` function.

But, I haven't figured out how to patch the elm compiler to allow the kernel code and the current implementation base on *nasty* monkey patch (by `patch/patch.js` file).
