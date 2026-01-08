
BANNER_WIDTH=45
zopen_print_banner()
{
  tagline="${*}"
  formatstring "" $BANNER_WIDTH "*"
  formatstring "${tagline}" $BANNER_WIDTH "*" "** " " **" false
  formatstring "" $BANNER_WIDTH "*"
  formatstring "******************     *******      **" $BANNER_WIDTH "*" "****" "" false
  formatstring "****************  ****  *****  ***** *" $BANNER_WIDTH "*" "****" "" false
  formatstring "***************  ******  ****  *******" $BANNER_WIDTH "*" "****" "" false
  formatstring "          *****  ******  *****   *****" $BANNER_WIDTH "*" "****" "" false
  formatstring "******   ******  ******  *******   ***" $BANNER_WIDTH "*" "****" "" false
  formatstring "**   **********  ******  *********   *" $BANNER_WIDTH "*" "****" "" false
  formatstring "   *************  ****  ***** *****  *" $BANNER_WIDTH "*" "****" "" false
  formatstring "         *********    ********      **" $BANNER_WIDTH "*" "****" "" false
  formatstring "" $BANNER_WIDTH "*"

}

zopen_test_script_start()
{
  scriptname="$1"
  starttime=$(date +%s)
  formatstring "" $BANNER_WIDTH "*"
  formatstring "$(basename "${scriptname}")" $BANNER_WIDTH "" "** " " **" false
  formatstring "Started: $(date "+%Y-%m-%d %H:%M:%S")" $BANNER_WIDTH "" "** " " **" false
  formatstring "" $BANNER_WIDTH "*"
}

zopen_test_script_end()
{
  scriptname="$1"
  endtime=$(date +%s)
  elapsed_seconds=$((endtime - starttime))
  hours=$((elapsed_seconds / 3600))
  minutes=$(((elapsed_seconds % 3600) / 60))
  seconds=$((elapsed_seconds % 60))
  formatstring "" $BANNER_WIDTH "*"
  formatstring "$(basename "${scriptname}")" $BANNER_WIDTH "" "** " " **" false
  formatstring "Ended: $(date "+%Y-%m-%d %H:%M:%S")" $BANNER_WIDTH "" "** " " **" false
  formatstring "Time elapsed: $hours:$([ $minutes -lt 10 ] && /bin/echo '0')$minutes:$([ $seconds -lt 10 ] && /bin/echo '0')$seconds ($elapsed_seconds seconds)" $BANNER_WIDTH "" "** " " **" false
  formatstring "" $BANNER_WIDTH "*"

}

zopen_test_begin()
{
  testname="$1"
  description="$2"
  formatstring "" $BANNER_WIDTH "*"
  formatstring "${testname}" $BANNER_WIDTH " " "** " " **" false
  [ -n "${description}" ] && formatstring "${description}" $BANNER_WIDTH " " "** " " **" false
  formatstring "" $BANNER_WIDTH " "
}

zopen_test_end()
{
  endtext="${*}"
  formatstring "" $BANNER_WIDTH "*"
  if [ -n "${endtext}" ]; then
    formatstring "${endtext}" $BANNER_WIDTH " " "** " " **" false 
    formatstring "" $BANNER_WIDTH "*"
  fi
}

formatstring() {
  # Disable command trace if enabled as this outputs unneeded information
  # unless debugging the formatting code!
  [ -z "${-%%*x*}" ] && set +x && xtrc="-x" || xtrc=""
  text="$1"
  width="${2:-43}"
  padding="${3:- }"
  prefix="${4:-}"
  suffix="${5:-}"
  splitwords="${6:-false}"

  [ -n "${prefix}" ] && prefixlength=${#prefix} || prefixlength=0
  [ -n "${suffix}" ] && suffixlength=${#suffix} || suffixlength=0
  effectivewidth=$((width - prefixlength - suffixlength))

  if ${splitwords}; then
    text=$(/bin/echo "${text}" | fold -w "${effectivewidth}")
  else
    text=$(/bin/echo "${text}" | fold -s -w "${effectivewidth}")
  fi

  # Take the potential multiple lines and feed them into awk [line-by-line processing]
  /bin/echo "$text" | awk -v prefix="${prefix}" \
                     -v suffix="${suffix}" \
                     -v pad="${padding}" \
                     -v w="${width}" \
                     -v prefix_len="${prefixlength}" \
                     -v suffix_len="${suffixlength}" \
      '{
        printf "%s", prefix; # Output the prefix [if any]    
        # If any padding needed, work out the distance to EOL
        line_len = length($0);  # text to write on line
        pad_len = (w - line_len - prefix_len - suffix_len) / (length(pad));  # distance to EOL
      
        printf "%s", $0;  # line contents
        # Add padding if needed [loop outputing the padding string]
        for (i = 0; i < pad_len; i++) {
          printf "%s", pad;
        }    
        printf "%s\n", suffix;  # Suffix + EOL
    }'
    [ -n "${xtrc}" ] && set -x
}

fail(){ 
  /bin/printf "\n!!Test failure: %s\n" "$*"
  exit 8;
}

success(){
  /bin/printf "\nTest completed successfully\n"
}

did() { # Done is a reserved word!
  text=$1
  /bin/printf "%s\n" "${text:- - DONE}"
} 

doing() {
    NL=""
    if [ "$1" = "-n" ]; then
        NL="\n"
        shift
    fi
    stringmaxsize=30
    str=$1
    len=$(printf %s "$str" | wc -c)
    tilde=""
    if [ "$len" -gt "$stringmaxsize" ]; then
        tilde="~"
    fi
    # truncate to stringmaxsize, adding tilde to indicate if truncated
    printf "%.*s%s...%s" "$stringmaxsize" "$str" "$tilde" "$NL"
}


install_dummy_env()
{
  # Install a fresh version of meta but ensure the version of the zopen
  # tooling used is actually the test version.  This ensures there is a valid
  # zopen environment for testing commands against
  zopenenv="${WORKDIR}/zopen-env-$(basename "$0")"
  formatstring "Generating dummy zopen environment" $BANNER_WIDTH " " "** " " **" false
  if [ -e "${zopenenv}" ]; then
    doing "Clearing existing work env"
    rm -rf "${zopenenv}"
    did
  fi

  doing -n "Re-initializing environment"
  mkdir -p "${zopenenv}"
  zopen init -y --re-init "${zopenenv}"  #specify re-init to ensure an env
  did "initialised with rc=$?"

  doing "Testing if zopen was installed at: ${zopenenv}/usr/local/zopen"
  [ ! -e "${zopenenv}/usr/local/zopen" ] && fail "File system not available"
  did
  doing "Testing existence of the zopen-config file"
  [ ! -e "${zopenenv}/etc/zopen-config" ] && fail "zopen configuration not available"
  did

  doing -n "Testing source of configuration file at '${zopenenv}/etc/zopen-config'"
  # shellcheck disable=SC1091
  . "${zopenenv}/etc/zopen-config"
  [ -z "${ZOPEN_ROOTFS}" ] && fail "zopen required envvar ZOPEN_ROOTFS not set"
  did "Configuration file set environment variables as expected"

  doing "Testing the zopen version is set correctly (according to zopen-config)"
  zopen_binary=$(whence zopen)
  [ ! "${zopen_binary}" = "${zopenenv}/usr/local/bin/zopen" ] && fail "Incorrectly sourced zopen-config. ${zopen_binary} != ${zopenenv}/usr/local/bin/zopen"
  did

  doing -n "Hardcoding test meta into PATH"
  # Fix to ensure we use the test meta
  # shellcheck disable=SC2154
  export PATH="$(dirname "${zopen_tool_binary}"):${PATH}"
  zopen_binary=$(whence zopen)
  [ ! "${zopen_binary}" = "${zopen_tool_binary}" ] && fail "Could not reset to use test meta"
  did "Using zopen '${zopen_binary}'"

  doing "Check for leak of functions from source"
  if type "zot_displayHelp" 2>/dev/null; then
    fail "zot_displayHelp leaked into environment"
  fi 
  did

}


# Utility function to search a string for words [order indompodent]
# $1 : haystack to search in
# $@ : needles to find in string
# returns: 0 [success]; 1 [failure] 
containsWords() {
    mode=$1 && shift
    case $mode in
      ALL|NODUPES|UNIQ|SOME|NONE):;;
      *) fail "Internal error; bad mode passed: '$mode'" ;;
    esac

    haystack=$1
    shift
    printf '%s\n' "$haystack" |
    awk -v mode "$mode" '
      BEGIN {
        for (i = 1; i < ARGC; i++) 
          needles[ARGV[i]] = 0
        ARGC = 2
      }
      {
        for (i = 1; i <= NF; i++) 
          if (i in needles) {
            if (needles[i] && mode == "NODUPES")
              # Found a duplicate and we do not want duplicates of words
              exit 1
            if (len(needles) && mode == "UNIQ")
              # Already found a needle and we need to be unique (ie. no other needles/dupes)
              exit 1

            needles[i] = 1
            if (mode == "SOME")
              # We have found a needle - all we need is one
              exit 0
            if (mode == "NONE")
              # We found a needle and we do not want to
              exit 1
          }
      }
      END {
        for (w in needles)
          if (!needles[w])
            if ($mode == "ALL")
              exit 1
          
      }' "$@"
}

gitClone() {
  gitrepo=$1
  target=$2
  [ $# -eq 3 ] && branch=$3
  gitRef=""
  if [ -n "${branch}" ]; then
    gitRef="--branch ${branch}"
  fi

  if ! runAndLog "git clone ${gitRef} \"${gitrepo}\" "; then
    printError "Unable to clone from '${gitrepo}'"
  fi
  tagTree "${target}"
}