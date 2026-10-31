#!/usr/bin/env python3
"""pack_keys.py <shader dir> <chain> <keys file> <list out>: every output file of those keys in cache/b-<chain>/ and ios/b-<chain>/ (relative to the shader dir), for tar -T"""
import sys, os
sh, chain, kf, lo = sys.argv[1:5]
keys = {l.split()[0] for l in open(kf) if l.strip()}
files = []
for d in (f'cache/b-{chain}', f'ios/b-{chain}'):
    p = os.path.join(sh, d)
    if os.path.isdir(p): files += [f'{d}/{n}' for n in sorted(os.listdir(p)) if '.tmp' not in n and n.split('_', 1)[0] in keys]
open(lo, 'w').write('\n'.join(files) + '\n')
print(f'{len(keys)} keys, {len(files)} files')
