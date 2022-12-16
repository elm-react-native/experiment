const path = require("path");
const fs = require("fs");

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
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (/^(var|function)/.test(line)) {
      begin = i;
    } else if (/^[}]/.test(line)) {
      fns.push(lines.slice(begin, i + 1));
    }
  }
  return fns;
};

const replacefn = (fn, source) => {
  const begin = fn[0];
  const i = source.indexOf(begin);
  if (i !== -1) {
    let j;
    for (j = i + 1; j < source.length; j++) {
      if (/^[}]/.test(source[j])) {
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

const output = source
  .map((line) => {
    // inject arbitray js code
    return line.replace(
      /'544d4631-adf8-\${(.*)}-4719-b1cc-46843cc90ca4'/,
      "$1"
    );
  })
  .join("\n");

fs.writeFileSync(process.argv[2] || _p("../src/App.jsx"), output);
