#!/usr/bin/env python3
"""plan.py <profile dir> <done keys file> <out dir> <batch size>: the keys still to build, in the Linux driver's order
(pixel + compute first, vertex last: paired vertex shaders read their pixel shaders' MSL from the output folder), split into batch files out/bNNN."""
import sys, os
prof, done_f, out, n = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])
rows = [l.rstrip('\n').split('\t') for l in open(os.path.join(prof, 'shader_map.tsv')) if l.strip() and not l.startswith('#')]
rows = [r for r in rows if r[0] != 'package' and len(r) > 3]
order = [r[3] for r in rows if r[2] != 'vertex'] + [r[3] for r in rows if r[2] == 'vertex']
seen = set(); order = [k for k in order if not (k in seen or seen.add(k))]
done = {l.split()[0] for l in open(done_f) if l.strip()} if os.path.exists(done_f) else set()
unknown = len(done - set(order))
todo = [k for k in order if k not in done]
os.makedirs(out, exist_ok=True)
for i in range(0, len(todo), n):
    open(os.path.join(out, f'b{i // n:03d}'), 'w').write('\n'.join(todo[i:i + n]) + '\n')
print(f'shader keys {len(order)}, already built (seed) {len(order) - len(todo)}, to build {len(todo)} in {(len(todo) + n - 1) // n} batches of {n}'
      + (f'; WARNING {unknown} seed keys are not in this shader_map (profile differs from the seed)' if unknown else ''))
