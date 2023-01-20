const path = require("path");

const p = (...ps) => path.join(__dirname, ...ps);

module.exports = {
  resolver: {
    nodeModulesPaths: [path.resolve("node_modules")],
    resolveRequest: (context, moduleName, platform) => {
      if (/^@elm-react-native\//.test(moduleName)) {
        return {
          filePath: p(
            moduleName.replace(/^@elm-react-native\//, "./"),
            "index.js"
          ),
          type: "sourceFile",
        };
      }

      return context.resolveRequest(context, moduleName, platform);
    },
  },
  transformer: {
    /* transformer options */
  },
  serializer: {
    /* serializer options */
  },
  server: {
    /* server options */
  },
  watchFolders: [p(".")],
};
