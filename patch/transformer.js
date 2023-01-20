const defaultTransformer = require("metro-transform-worker");
const shell = require("shelljs");
const path = require("path");
const p = (...ps) => path.join(__dirname, ...ps);
const fs = require("fs");
const util = require("util");
const patch = require("./patch");

module.exports = {
  transform: async (config, projectRoot, filename, data, options) => {
    if (filename.endsWith(".elm")) {
      const elmjs = p("./elm.js");
      await util.promisify(shell.exec)(
        `elm make ${filename} --output=${elmjs}`
      );
      const jsdata = Buffer.from(await patch(elmjs));
      return defaultTransformer.transform(
        config,
        projectRoot,
        filename,
        jsdata,
        options
      );
    }

    return defaultTransformer.transform(
      config,
      projectRoot,
      filename,
      data,
      options
    );
  },

  getCacheKey: (config) => {
    return defaultTransformer.getCacheKey(config);
  },
};
