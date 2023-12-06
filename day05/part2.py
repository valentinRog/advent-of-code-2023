import sys
import math
import threading

def location(maps, n):
    for m in maps:
        for mm in m:
            [d, s, l] = mm
            if n >= s and n < s + l:
                n = d + n - s
                break
    return n


[seeds, *maps] = sys.stdin.read().strip().split("\n\n")
seeds = seeds.split()[1::]
seeds = list(map(int, seeds))
seeds = [tuple(seeds[n:n+2]) for n in range(0, len(seeds), 2)]
maps = map(lambda x : list(map(lambda x : list(map(int, x.split())), x.split("\n")[1::])), maps)
maps = list(maps)

g_res = math.inf
lock = threading.Lock()

def compute(s, l, ii):
    global g_res, lock
    res = math.inf
    for i in range(s, s + l):
        res = min(res, location(maps, i))
        if i % 1000000 == 0:
            with lock:
                print(f"id={ii}: {100 * (i - s )/ l}%", end=" ")
                g_res = min(g_res, res)
                print(g_res)
    with lock:
        g_res = min(g_res, res)
        print(g_res)

t = []

for i, [s, l] in enumerate(seeds):
    t.append(threading.Thread(target=compute, args=(s, l, i)))

for tt in t:
    tt.start()

for tt in t:
    tt.join()

print(g_res)