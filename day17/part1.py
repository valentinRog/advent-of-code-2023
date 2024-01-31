import sys
import heapq
import uuid

def dijkstra(m, pf):
    dists = {(0, 0): 0}
    q = []
    heapq.heappush(q, (0, uuid.uuid4(), (0, 0)))

    while True:
        _, _,  (p, ds) = heapq.heappop(q)
        for d in [-1j, 1, -1, 1j]:
            dds = ds
            np = p + d
            if np not in m:
                continue
            cost = dists[(p, ds)] + m[np]
            if dds == 0:
                dds = d
            elif d == -dds:
                continue
            dds = dds + d if  dds / abs(dds) == d else d
            if abs(dds) > 3:
                continue
            if np == pf:
                return cost
            if (np, dds) in dists and dists[(np, dds)] <= cost:
                continue
            dists[(np, dds)] = cost
            heapq.heappush(q, (cost, uuid.uuid4(), (np, dds)))

m = {
    x + y * 1j: int(c)
    for y, line in enumerate(sys.stdin.read().strip().splitlines())
    for x, c in enumerate(line)
}

print(dijkstra(m, max(m.keys(), key=abs)))
