const path = require("path");
const fs = require("fs");

if (!process.argv[2]) {
  throw new Error("output file is required");
}

const _p = (p) => path.join(__dirname, p);

const replacejsx = fs
  .readFileSync(_p("./replace.jsx"), { encoding: "utf-8" })
  .split(/\r?\n/);
const prependjsx = fs.readFileSync(_p("./prepend.jsx"), { encoding: "utf-8" });
const appendjsx = fs.readFileSync(_p("./append.jsx"), { encoding: "utf-8" });
const source = fs
  .readFileSync(_p("../build/elm.js"), { encoding: "utf-8" })
  .trim()
  .split(/\r?\n/);

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

const replacefn = (fn, source) => {
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
};

source.splice(0, 2, prependjsx);
const fns = splitToFunctions(replacejsx);
for (const fn of fns) {
  replacefn(fn, source);
}
source.splice(
  source.length - 1,
  1,
  source[source.length - 1].replace("}(this));", "")
);
if (process.argv.indexOf("--mobile")) {
  source.push("scope.isReactNative = true;");
}
source.push(appendjsx);

const variableReplacer = (elm, js) => {
  const elmVar = `$author$project$ReactNative$${elm}`.replaceAll("$", "\\$");
  const toRemove = new RegExp(`var ${elmVar} = .*;$`, "");
  const toReplace = new RegExp(elmVar, "g");
  return (line) => line.replace(toRemove, "").replace(toReplace, js);
};

const replacers = [
  variableReplacer("Easing$bounce", "Easing.bounce"),
  variableReplacer("Easing$ease", "Easing.ease"),
  variableReplacer("Platform$os", "Platform.OS"),
  variableReplacer("Platform$version", "Platform.Version"),
  variableReplacer("Platform$color", "PlatformColor"),
  variableReplacer("Platform$isPad", "Platform.isPad"),
  variableReplacer("Platform$isTV", "Platform.isTV"),
  variableReplacer("Platform$isTesting", "Platform.isTesting"),
  variableReplacer("Platform$select", "Platform.select"),
  variableReplacer("StyleSheet$hairlineWidth", "StyleSheet.hairlineWidth"),
  variableReplacer("StyleSheet$create", "StyleSheet.create"),
];

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

fs.writeFileSync(process.argv[2] || _p("../src/App.jsx"), output);
