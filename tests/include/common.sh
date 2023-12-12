
zopen_print_banner()
{

  tagline="${*}"
  numchars=$(expr length "${tagline}")
  # banner width is 43, 4 spaces for blanks and prefix
  numchars=$(expr 43 - $numchars - 4 + 1)

  # Build tag line with prefix and suffix
  tagline="** ${tagline} "
  count=0
  while [ $count -lt $numchars ]
  do
      tagline="${tagline}*"
      count=$(expr $count + 1)
  done

  echo "********************************************"
  echo "${tagline}"
  echo "********************************************"
  echo "**********************     *******      ****"
  echo "********************  ****  *****  ***** ***"
  echo "*******************  ******  ****  *********"
  echo "****          *****  ******  *****   *******"
  echo "**********   ******  ******  *******   *****"
  echo "******   **********  ******  *********   ***"
  echo "****   *************  ****  ***** *****  ***"
  echo "***          *********    ********      ****"
  echo "********************************************"

}

