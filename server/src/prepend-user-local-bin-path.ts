import { existsSync } from "node:fs";
import { homedir } from "node:os";
import path from "node:path";

/**
 * Put ~/.local/bin on PATH when missing. IDE/Cursor-spawned Node often skips
 * login-shell profile, so tools symlinked there (e.g. claude) are invisible to adapters.
 */
export function prependUserLocalBinToPath(): void {
  const localBin = path.join(homedir(), ".local", "bin");
  if (!existsSync(localBin)) return;
  const sep = path.delimiter;
  const cur = process.env.PATH ?? "";
  const parts = cur.split(sep).filter(Boolean);
  if (parts.includes(localBin)) return;
  process.env.PATH = `${localBin}${sep}${cur}`;
}
