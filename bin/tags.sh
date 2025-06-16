#!/bin/sh

set +e

# -- Downloads language sources -----------------------------------------------

# if missing, get java/clojure/node/go

# generate langauge tags in .vim folder

# -- Generate 3rd party/dep sources ----

# from places like.. .m2 for clojure, go has it's GOROOT I think?, node has
# node_modules locally and java has gradle area?

# we end up with tags per language again but for the user-level caches e.g .m2
# folder has ALL deps we use across all projects that I have downloaded

# -- Finally generate tags based on your code

# -- Result.. tags that can be applied for any of the languages I work with.
