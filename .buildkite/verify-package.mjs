import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const packageJson = JSON.parse(fs.readFileSync(path.join(root, "package.json"), "utf8"));

assert.equal(packageJson.name, "@buildkite/emojis");
assert.equal(packageJson.publishConfig?.access, "public");
assert.equal(packageJson.dependencies, undefined);

const pack = spawnSync("npm", ["pack", "--dry-run", "--json"], {
  cwd: root,
  encoding: "utf8",
});
assert.equal(pack.status, 0, pack.stderr);

const packResult = JSON.parse(pack.stdout);
assert(Array.isArray(packResult) && packResult[0], "npm pack --dry-run --json should return an array");
const packagedFiles = new Set(packResult[0].files.map(({ path: filePath }) => filePath));

const cataloguePaths = packageJson.files.filter((filePath) => /^img-.*\.json$/.test(filePath)).sort();
assert(cataloguePaths.length > 0, "No emoji catalogues found");
const repositoryCatalogues = fs
  .readdirSync(root)
  .filter((filePath) => /^img-.*\.json$/.test(filePath))
  .sort();
assert.deepEqual(cataloguePaths, repositoryCatalogues, "package.json must include every emoji catalogue");

for (const cataloguePath of cataloguePaths) {
  assert(packagedFiles.has(cataloguePath), `${cataloguePath} is missing from the npm package`);

  const catalogue = JSON.parse(fs.readFileSync(path.join(root, cataloguePath), "utf8"));
  for (const emoji of catalogue) {
    for (const image of [emoji.image, ...(emoji.modifiers ?? []).map((modifier) => modifier.image)]) {
      assert(packagedFiles.has(image), `${image} is missing from the npm package`);
    }
  }
}
