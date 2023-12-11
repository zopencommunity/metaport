metaport

A test validation of our 'meta' tools. 
metaport MUST be run before any code in 'meta' repo can be merged into main

By default, metaport will pull down the latest 'meta' repo.
To test against your local development repo, do the following:

Export ZOPEN_META_DEV_ROOT to the root of your cloned git 'meta' repo, e.g

```
export ZOPEN_META_DEV_ROOT=$HOME/zopen/dev/meta/
```

By default, metaport will pull down the latest 'zotsampleport' repo.
To test against a branch under development, do the following:

Export ZOPEN_ZOT_SAMPLEPORT_BRANCH to the branch of 'zopensampleport' repo you want to test, e.g.
```
export ZOPEN_ZOT_SAMPLEPORT_BRANCH=updateversion
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


# Developer Notes

The detailed version of above.

## Workflow

The workflow for contributing to the meta repo.  This workflow assumes
your installation of zopen is installed in `$HOME/zopen`.

### Step 1 - Update existing meta

Update your z/OS Open Tools meta package before proceeding like so:

```
$ zopen upgrade meta -y
```

### Step 2 - Create the work dev repos for meta and metaport

This clones the two repos for development work. Note this workflow
requires meta and metaport dirs to be named meta and metaport respectively.  

Since merging to the main branch requires a pull request, this workflow shows
how to contribute using a personal dev branch and then the use of github
to perform a pull request.

It is a common practice to work in the `$HOME/zopen/dev/` directory.

```
$ cd $HOME/zopen/dev
$ git clone git@github.com:ZOSOpenTools/meta.git
$ git clone git@github.com:ZOSOpenTools/metaport.git
```

### Step 3 - Create a branch in the dev version of meta for work

For ease of use replace the text `YOURID` with your
github userid.  This will create a branch which looks
like: `xyzdev`.

```
$ cd $HOME/zopen/dev/meta
$ git branch YOURUSERIDdev
$ git checkout YOURUSERIDdev
```

Alternatively, you can create the branch and checkout with one command.

```
$ cd $HOME/zopen/dev/meta
$ git checkout -b YOURUSERIDdev
```


### Step 4 - Create an environment script to setup for dev work

This will allow you to enable and disable your work
on meta.

```
$ cd $HOME/zopen/dev
$ cat << EOF > setenv.sh
> export ZOPEN_META_DEV_ROOT=${HOME}/zopen/dev/meta
> export ZOPEN_META_BRANCH=YOURUSERIDdev
> EOF


$ cat setenv.sh
export ZOPEN_META_DEV_ROOT=${HOME}/zopen/dev/meta
export ZOPEN_META_BRANCH=YOURUSERIDdev
$
```

Source the script to have environment variables set in your current shell.

```
$ cd $HOME/zopen/dev
$ . ./setenv.sh
```

Create the unset script to disable using your sandbox.

```
$ cat << EOF > disable.sh
> unset ZOPEN_META_DEV_ROOT
> unset ZOPEN_META_BRANCH
> EOF
```

It is used in similar fashion.



### Step 5 - Build meta using branch YOURUSERIDdev

```
$ cd $HOME/zopen/dev/metaport
$ zopen build
```


The command sequence creates a link
to the `meta` directory specified by the environment variable
in the `metaport` directory.

Afterwards, the build and test process starts.  The test process
uses the test cases to validate the development build.

The environment settings are reflected as shown below.

```
$ cd $HOME/zopen/dev/metaport
$ ls -ld meta
lrwxrwxrwx   1 JXXXXXXX XXXXXXXX      26 Nov  9 16:16 meta -> /z/jXXXXXXX/zopen/dev/meta
$ cd $HOME/zopen/dev/metaport/meta
$ git branch
* johndev
  main
$
```

At this point the repo is ready to be configured as a development
package installer.  All that remains is to source the associated
`.env` script.

### Step 6 - Use the developer version of meta

This sequence configures zopen to use your
development version of meta rather than the system version.

```
$ cd $HOME/zopen/dev/metaport/meta
$ . ./.env
```

## Development on other repos impacted by `meta` modifications

Use this workflow if you are working on a specific port and need
to modify `meta` in conjunction with your changes to another 
repo.

If you wanted to enhance/improve zotsampleport - likely because you made changes to zopen-build or because you want to test zopen-build better, then you would:

```
$ export ZOPEN_ZOT_SAMPLEPORT_BRANCH=updateversion
$ cd $HOME/zopen/dev
$ git clone git@github.com:ZOSOpenTools/zotsampleport.git
$ cd zotsampleport
$ git branch mymod
$ git checkout mymod

<make your changes>

$ git add .
$ git commit -m 'comment'
$ git push --set-upstream origin mymod
```




