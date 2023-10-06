## Test cases for zopen

## To add a new testcase:

- create an executable (e.g. shell script) with a name of zopen_check_xxx where xxx is the name you want to use
- the executable should take one parameter which is the working directory it can use. If successful, it should clean up after itself
- the executable should exit with 0 if successful, non-zero otherwise
