/**
 * Metro configuration for React Native
 * https://github.com/facebook/react-native
 *
 * @format
 */

const {getDefaultConfig, mergeConfig} = require('@react-native/metro-config');

const defaultConfig = getDefaultConfig(__dirname);

const packagesConfig = require('../packages/metro.config');

module.exports = mergeConfig(
  defaultConfig,
  packagesConfig({
    transformer: {
      experimentalImportSupport: false,
      inlineRequires: true,
    },
  }),
);
