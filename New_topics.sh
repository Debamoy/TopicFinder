#!/usr/bin/bash
#--------------------------------------------------------URL encoding---------------------------------
RESULT="" 
WORDS_COUNT=$(echo "$1"|wc -w)
echo "WORDS_COUNT:${WORDS_COUNT}"
i=1
#set -vx
for i in $(seq 1 $WORDS_COUNT)
do
  RESULT+=$(echo "$1" | cut -d " " -f $i)
  if (($i < $WORDS_COUNT))
  then
    RESULT+="%20"
  fi
done 
#set +vx
echo "RESULT:${RESULT}"
#set -vx
#------------------------------------------------------------------------------------------------------
TOPICS=$(curl --location --request GET "https://api.core.ac.uk/v3/search/outputs?q=${RESULT}" --header 'Authorization: Bearer ZGxwobuMBmphfDyF25dTSgKE13H87NtC' --header 'Content-Type: application/json'| jq '.results[].tags' | sed -e 's/\]//' -e 's/\[//' | grep -e '"' | grep -v '"text"')
if (($?!=0))
then
  echo "Error sending curl request"
  read -p "Do you want to continue" CH
  if ["${CH}" -eq "n"]
  then
    exit 1
  fi
  sleep 120s
fi

echo '------------------------------------First level of Topics-----------------------'
echo "${TOPICS}"
echo '--------------------------------------------------------------------------------'

echo "----------------------------------Second level of topics-------------------------"
#set +vx
for TOPIC in $TOPICS
do
  sleep 10s
  RELATED_TOPICS=`curl --location --request GET "https://api.core.ac.uk/v3/search/outputs?q=${TOPIC}" --header 'Authorization: Bearer ZGxwobuMBmphfDyF25dTSgKE13H87NtC' --header 'Content-Type: application/json'| jq '.results[].tags' | sed -e 's/\]//' -e 's/\[//' | grep -e '"' | grep -v '"text"'`
  if(($?!=0))
  then
    echo "Error sending curl request"
    sleep 15s
  fi
  echo "For the first level topic: ${TOPIC}"
  echo '--------------------- Related Topics ----------------------'
  echo "${RELATED_TOPICS}\n"
  echo '-----------------------------------------------------------'
done
