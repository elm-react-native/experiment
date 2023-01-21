const path = require("path");
const fs = require("fs");
const util = require("util");

const p = (...ps) => path.join(__dirname, ...ps);

const initElmjs = async (moduleName) => {
  const elmModule = {
    moduleName,
    time: new Date(),
  };
  await util.promisify(fs.writeFile)(
    "elm.js",
    `// ${JSON.stringify(elmModule)}`
  );
};

module.exports = (transformOptions = { transform: {} }) => ({
  transformerPath: p("./transformer"),
  resolver: {
    nodeModulesPaths: [path.resolve("node_modules")],

    resolveRequest: (context, moduleName, platform) => {
      if (/^@elm-module\//.test(moduleName)) {
        return {
          filePath: path.resolve("elm.js"),
          type: "sourceFile",
        };
      }

      if (/^@elm-react-native\//.test(moduleName)) {
        const modulePath = moduleName.replace(/^@elm-react-native\//, "./");

        const filePath = context.sourceExts
          .flatMap((ext) => [
            p(`${modulePath}.${ext}`),
            p(modulePath, `index.${ext}`),
          ])
          .find((f) => context.doesFileExist(f));

        return { filePath, type: "sourceFile" };
      }

      return context.resolveRequest(context, moduleName, platform);
    },
  },
  transformer: {
    /* transformer options */
    getTransformOptions: async (entryPoints, options, getDependenciesOf) => {
      if (await util.promisify(fs.exists)("elm.js")) {
        return transformOptions;
      }

      for (const entry of entryPoints) {
        const entryContent = await util.promisify(fs.readFile)(entry, {
          encoding: "utf-8",
        });
        const m = entryContent.match(
          /^import \w+ from ["']@elm-module\/([^"']*)["']/m
        );
        if (m) {
          const moduleName = m[1].replaceAll("/", ".");
          await initElmjs(moduleName);
          if (options.dev) {
            // wait for watchman pick up the newly created elm.js, otherwise metro will have trouble to find it later
            await util.promisify(setTimeout)(500);
          }
          break;
        }
      }

      return transformOptions;
    },
  },
  serializer: {
    /* serializer options */
  },
  server: {
    /* server options */
  },
  watchFolders: [p(".")],
});
