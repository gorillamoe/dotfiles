 #!/bin/bash

if [ "$#" == "0" ]; then
    echo "You need tu supply at least one argument!"
    exit 1
fi

for domain in "$@"; do
  whois "$domain" | egrep -q \
      '^No match|^NOT FOUND|^Not fo|AVAILABLE|^No Data Fou|has not been regi|No entri'
  if [ $? -eq 0 ]; then
    echo -e "\e[1m$domain\e[21m \e[32mavailable\e[0m"
  else
    echo -e "\e[1m$domain\e[21m \e[31mnot available\e[0m"
  fi
shift

done
