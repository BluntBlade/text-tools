#/bin/bash

awk '{ c[$0] += 1; } END{ for (t in c) { printf "%s\t%d\n", t, c[t]; } }'
