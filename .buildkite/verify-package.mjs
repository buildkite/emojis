import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const packageJson = JSON.parse(fs.readFileSync(path.join(root, "package.json"), "utf8"));

assert.equal(packageJson.name, "@buildkite/emojis");
assert.equal(packageJson.publishConfig?.access, "public");
assert.equal(packageJson.dependencies, undefined);

const packDestination = fs.mkdtempSync(path.join(os.tmpdir(), "buildkite-emojis-pack-"));
const pack = spawnSync("npm", ["pack", "--dry-run", "--json", "--pack-destination", packDestination], {
  cwd: root,
  encoding: "utf8",
});
fs.rmSync(packDestination, { force: true, recursive: true });
assert.equal(pack.status, 0, pack.stderr);

const packResult = JSON.parse(pack.stdout);
const { files } = Array.isArray(packResult) ? packResult[0] : Object.values(packResult)[0];
const packagedFiles = new Set(files.map(({ path: filePath }) => filePath));

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
