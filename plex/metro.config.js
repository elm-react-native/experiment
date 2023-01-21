/**
 * Metro configuration for React Native
 * https://github.com/facebook/react-native
 *
 * @format
 */

const packagesConfig = require('../packages/metro.config');

module.exports = packagesConfig({
  transformer: {
    experimentalImportSupport: false,
    inlineRequires: true,
  },
});
