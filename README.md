metaport

A test validation of our 'meta' tools. 
metaport MUST be run before any code in 'meta' repo can be merged into main

By default, metaport will pull down the latest 'meta' repo.
To test against your local development repo, do the following:

Export ZOPEN_META_DEV_ROOT to the root of your cloned git 'meta' repo, e.g
```
export ZOPEN_META_DEV_ROOT=$HOME/zopen/dev/meta/
```

Change directory to your 'metaport' repo, e.g.
```
cd $HOME/zopen/dev/metaport
```

Perform zopen build and validate that the tests all run correctly against your local build, e.g.
```
zopen build
```

Note that running `zopen build` against your development repo will NOT install the code into your
environment.

