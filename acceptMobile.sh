#!/bin/bash
gam="/root/bin/gamadv-xtd3/gam"

if [ ! $# -eq 1 ]; then
   echo "Usage ./acceptMobile <email>"
   exit 1
fi

if ! command -v npm > /dev/null ; then apt-get update && sudo apt-get install nodejs npm ; fi
if ! command -v csvtojson > /dev/null ; then apt-get update && sudo npm install ; fi
if ! command -v jq > /dev/null ; then apt-get update && npm install jquery ; fi

usr=$@
csv=$($gam print mobiles query "email:$usr* status:PENDING" fields firstSync model)
json=$(csvtojson <<< $csv)
len=$(jq '. | length' <<< $json)
let lastInd=$len-1

echo ''
echo ''
echo '---------------------------------------------------'
echo ''
echo "There are $len unapproved devices for user $usr:"
echo ''

for (( i=0 ; i<$len ; i++ )) ; do
   echo -n "$(expr $i + 1): "
   echo -n "Model: " ; jq .[$i].model <<< $json
   echo -n "   FirstSync: " ; jq .[$i].firstSync <<< $json ;
   echo ''
done

echo ''
echo '---------------------------------------------------'
echo ''

echo "Which number to approve?"
read num
cho=$(expr $num - 1)
id=$(jq -r .[$cho].resourceId <<< $json)
$gam update mobile $id action approve
