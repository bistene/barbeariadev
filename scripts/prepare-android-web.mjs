import { cp, mkdir, rm, readdir } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const output = path.join(root, 'www');
const excluded = new Set(['.git', 'node_modules', 'android', 'www', '.vercel', '.github']);

await rm(output, { recursive: true, force: true });
await mkdir(output, { recursive: true });

async function copyTree(from, to) {
  await mkdir(to, { recursive: true });
  for (const entry of await readdir(from, { withFileTypes: true })) {
    if (excluded.has(entry.name)) continue;
    if (entry.name === 'package.json' || entry.name === 'package-lock.json' || entry.name === 'capacitor.config.ts') continue;
    const source = path.join(from, entry.name);
    const target = path.join(to, entry.name);
    if (entry.isDirectory()) await copyTree(source, target);
    else if (entry.isFile()) await cp(source, target);
  }
}

await copyTree(root, output);
console.log('Arquivos web preparados em ./www para o aplicativo Android.');
