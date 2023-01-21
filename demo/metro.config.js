// Learn more https://docs.expo.io/guides/customizing-metro
const { mergeConfig } = require("metro-config");
const { getDefaultConfig } = require("expo/metro-config");
const packagesConfig = require("../packages/metro.config");

module.exports = mergeConfig(getDefaultConfig(__dirname), packagesConfig());
