const path = require("path");

const p = (...ps) => path.join(__dirname, ...ps);

module.exports = {
  resolver: {
    nodeModulesPaths: [path.resolve("node_modules")],
    resolveRequest: (context, moduleName, platform) => {
      if (/^@elm-react-native\//.test(moduleName)) {
        const modulePath = moduleName.replace(/^@elm-react-native\//, "./");

        const filePath = context.sourceExts
          .flatMap((ext) => [
            p(`${modulePath}.${ext}`),
            p(`${modulePath}.index.${ext}`),
          ])
          .find((f) => context.doesFileExist(f));

        return { filePath, type: "sourceFile" };
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
