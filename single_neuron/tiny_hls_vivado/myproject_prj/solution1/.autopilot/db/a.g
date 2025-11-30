#!/bin/sh
lli=${LLVMINTERP-lli}
exec $lli \
    /home/narendranath/Academmic/Theisis/single_neuron/tiny_hls_vivado/myproject_prj/solution1/.autopilot/db/a.g.bc ${1+"$@"}
