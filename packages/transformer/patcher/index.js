const path = require("path");
const fs = require("fs");
const util = require("util");

const p = (...ps) => path.join(__dirname, ...ps);
const readFile = util.promisify(fs.readFile);

const toRemove = [
  "function _VirtualDom_diff(x, y)",
  "function _VirtualDom_diffHelp(x, y, patches, index)",
  "function _VirtualDom_pairwiseRefEqual(as, bs)",
  "function _VirtualDom_diffNodes(x, y, patches, index, diffKids)",
  "function _VirtualDom_diffFacts(x, y, category)",
  "function _VirtualDom_diffKids(xParent, yParent, patches, index)",
  "function _VirtualDom_diffKeyedKids(xParent, yParent, patches, rootIndex)",
  "function _VirtualDom_insertNode(changes, localPatches, key, vnode, yIndex, inserts)",
  "function _VirtualDom_removeNode(changes, localPatches, key, vnode, index)",
  "function _VirtualDom_addDomNodes(domNode, vNode, patches, eventNode)",
  "function _VirtualDom_addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)",
  "function _VirtualDom_applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)",
  "function _VirtualDom_applyPatchesHelp(rootDomNode, patches)",
  "function _VirtualDom_applyPatch(domNode, patch)",
  "function _VirtualDom_applyPatchRedraw(domNode, vNode, eventNode)",
  "function _VirtualDom_applyPatchReorder(domNode, patch)",
  "function _VirtualDom_applyPatchReorderEndInsertsHelp(endInserts, patch)",
  "function _VirtualDom_virtualize(node)",
  "function _VirtualDom_render(vNode, eventNode)",
  "function _VirtualDom_applyFacts(domNode, eventNode, facts)",
  "function _VirtualDom_applyStyles(domNode, styles)",
  "function _VirtualDom_applyAttrs(domNode, attrs)",
  "function _VirtualDom_applyAttrsNS(domNode, nsAttrs)",
  "function _VirtualDom_applyEvents(domNode, eventNode, events)",
  "function _VirtualDom_pushPatch(patches, type, index, data)",
  "function _VirtualDom_dekey(keyedNode)",
  "var _VirtualDom_init = F4(function(virtualNode, flagDecoder, debugMetadata, args)",
];

const variableReplacer = (elm, js) => {
  const elmVar = `$author$project$ReactNative$${elm}\\b`.replaceAll("$", "\\$");
  const toRemove = new RegExp(`var ${elmVar} = .*;$`, "");
  const toReplace = new RegExp(elmVar, "g");
  return (line) => line.replace(toRemove, "").replace(toReplace, js);
};

const replacers = [
  variableReplacer("null", "null"),
  variableReplacer("require", "require"),
  variableReplacer("Easing$bounce", "Easing.bounce"),
  variableReplacer("Easing$ease", "Easing.ease"),
  variableReplacer("Easing$sin", "Easing.sin"),
  variableReplacer("Easing$exp", "Easing.exp"),
  variableReplacer("Easing$circle", "Easing.circle"),
  variableReplacer("Easing$quad", "Easing.quad"),
  variableReplacer("Easing$cubic", "Easing.cubic"),
  variableReplacer("Easing$linear", "Easing.linear"),
  variableReplacer("Platform$os", "Platform.OS"),
  variableReplacer("Platform$version", "Platform.Version"),
  variableReplacer("Platform$osVersion", "Platform.osVersion"),
  variableReplacer("Platform$systemName", "Platform.systemName"),
  variableReplacer("Platform$color", "PlatformColor"),
  variableReplacer("Platform$isPad", "Platform.isPad"),
  variableReplacer("Platform$isTV", "Platform.isTV"),
  variableReplacer("Platform$select", "Platform.select"),
  variableReplacer("StyleSheet$hairlineWidth", "StyleSheet.hairlineWidth"),
  variableReplacer("StyleSheet$create", "StyleSheet.create"),
  variableReplacer("ToastAndroid$durationShort", "ToastAndroid.SHORT"),
  variableReplacer("ToastAndroid$durationLong", "ToastAndroid.LONG"),
  variableReplacer("StatusBar$currentHeight", "StatusBar.currentHeight"),
  variableReplacer("Platform$interfaceIdiom", "Platform.interfaceIdiom"),
  variableReplacer("LayoutAnimation$spring", "LayoutAnimation.Presets.spring"),
  variableReplacer("LayoutAnimation$linear", "LayoutAnimation.Presets.linear"),
];

const splitToFunctions = (lines) => {
  const fns = [];
  let begin;
  let indent = "";
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (/^var \$.*= F\d\(/.test(line) && /^\s+function \(/.test(lines[i + 1])) {
      begin = i;
      indent = /^(\s+)/.exec(lines[i + 1])[1];
    } else if (indent.length > 0 && line === `${indent}});`) {
      fns.push(lines.slice(begin, i + 1));
    } else if (/^(var|function)/.test(line)) {
      begin = i;
      indent = "";
    } else if (/^[}]/.test(line)) {
      fns.push(lines.slice(begin, i + 1));
    }
  }
  return fns;
};

const replacefn = (source, fn) => {
  const begin = fn[0];
  const hasIndent = /^var \$.*= F\d\($/.test(begin);
  const i = source.indexOf(begin);
  if (i !== -1) {
    const indent = hasIndent ? /^\s+/.exec(source[i + 1])[0] : "";
    let j;
    for (j = i + 1; j < source.length; j++) {
      if (indent.length > 0) {
        if (source[j] === `${indent}});`) {
          break;
        }
      } else if (/^[}]/.test(source[j])) {
        break;
      }
    }

    source.splice(i, j - i + 1, ...fn);
  }
  return source;
};

const removefn = (source, firstLine) => {
  let i = source.indexOf(firstLine);
  if (i !== -1) {
    let j;
    for (j = i + 1; j < source.length; j++) {
      if (/^[}]/.test(source[j])) {
        break;
      }
    }

    for (; i > 0; i--) {
      if (!/^\/\//.test(source[i])) {
        break;
      }
    }

    source.splice(i, j - i + 1);
  }
  return source;
};

module.exports = async (filename) => {
  const source = (await readFile(filename, { encoding: "utf-8" }))
    .trim()
    .split(/\r?\n/);

  const prependjsx = await readFile(p("./prepend.jsx"), { encoding: "utf-8" });
  source.splice(0, 2, prependjsx);

  toRemove.reduce(removefn, source);
  source.splice(
    source.length - 1,
    1,
    source[source.length - 1].replace("}(this));", "")
  );

  const replacejsx = (
    await readFile(p("./replace.jsx"), { encoding: "utf-8" })
  ).split(/\r?\n/);
  splitToFunctions(replacejsx).reduce(replacefn, source);

  const appendjsx = await readFile(p("./append.jsx"), { encoding: "utf-8" });
  source.push(appendjsx);

  const output = source
    .map((line) => {
      const prevLine = line;
      line = replacers.reduce((l, f) => f(l), line);

      // inject arbitray js code
      return line
        .replace(/'544d4631-adf8-\${(.*)}-4719-b1cc-46843cc90ca4'/, "$1")
        .replace(/(^\s*)_default: /, "$1default: ");
    })
    .join("\n");

  return output;
};
