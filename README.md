# Windows Path Export Scripts

Two lightweight batch scripts generate a **CSV** inventory of every file and directory in your working tree while ignoring the `.git` folder.

| Script | Scan strategy | Order | Output file | `.gitignore` aware | Empty dirs included |
|--------|---------------|-------|-------------|--------------------|---------------------|
| **`List_Paths_Fast.bat`** | One‑pass `dir /s /b` (depth‑first) | Directories first, then files (sorted) | `paths_fast.csv` | ❌ | ✅ |
| **`List_Paths_BFS.bat`**  | Breadth‑first queue (files first) | Files first *within each level*, then folders | `paths_bfs.csv` | ❌ | ✅ |

> **Note** — Neither script consults `.gitignore`; they include any ignored artefacts that are physically present, but still skip the `.git` folder itself.

---

## 1 · `List_Paths_Fast.bat`

Walks the entire tree with a single `dir /s /b`, pipes through `findstr` to drop everything under `.git`, and writes the results to **`paths_fast.csv`**.

```cmd
> List_Paths_Fast.bat
```

* **Directories** finish with a trailing `\`.  
* **Files** appear without a trailing slash.

Expected first lines:

```
src\                 ← directory
src\main.c           ← file
```

### When to use
* Need a *very* quick snapshot.  
* Okay with extra build artefacts / swap files being present.

---

## 2 · `List_Paths_BFS.bat`

Implements a classic **breadth‑first search**:

1. Queues root‑level sub‑folders.  
2. Writes root files, then root folders (with `\`).  
3. Pops each queued folder, writing its direct files first, then its sub‑folders, queuing as it goes.  
4. Repeats until the queue is empty.

Output is **`paths_bfs.csv`** and reflects the natural *folder‑by‑folder* exploration order a human would follow.

```cmd
> List_Paths_BFS.bat
```

### When to use
* Prefer to see files grouped by their immediate parent directory.  
* Useful for diffing tree growth level‑by‑level.

---

## CSV Format

```
relative\folder\          ← directory (always ends in \)
relative\folder\file.txt  ← file
```

* Encoding — UTF‑8, no BOM.  
* One path per line, Windows back‑slashes throughout.

---

## Known Limitations & Tips

| Behaviour | Explanation | Work‑around |
|-----------|-------------|-------------|
| **Ignored files included** | Scripts operate on the filesystem, not Git’s index. | Run a Git‑based exporter instead (e.g. `git ls-files`). |
| **Empty directories emitted** | `dir` enumerates actual folders. | Delete unused folders or filter later. |
| **Scripts list themselves / CSV** | Both scripts contain inline checks to skip the running `.bat` and their own CSVs. | — |
| **Path count differs from Git** | Git doesn’t track empty dirs & ignores patterns. | Expect counts to diverge. |

---

© 2025 Path Utilities  •  MIT License
