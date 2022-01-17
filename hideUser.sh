#!/bin/bash
log="/root/log/"
gam="/root/bin/gamadv-xtd3/gam"
tmp="/root/tmp/"
usr="admin"
fn="del"
fp=$tmp$fn".csv"
fpm=$fp"-m"
password=$(openssl rand -base64 12)
message="Ten adres email zostanie wkrótce usunięty / This email address will be closed soon"

# source spreadsheet
idr="1rC0DSKnZ_vT7EMlMcJ8zY7F8ysEMdfm3I4JBPb4dWJM"

rm $fp > /dev/null 2>&1
$gam user $usr get drivefile $idr csvsheet .delete targetfolder $tmp targetname $fn
mv $fp $fpm

cat -A $fpm | tr -d "^M$" > $fp
rm $fpm > /dev/null 2>&1

echo "" >> $fp

iu=$(wc -l $fp | cut -d " " -f 1)
echo "$iu users to hide, (c)ontinue or (b)reak?"
read odp


if [ $odp == "b" ]; then
exit 1
fi

while IFS="," read -r u
do
        $gam update user $u password $password
        $gam update user $u gal off
        $gam user $u del group
        $gam user $u vacation on end 2222-01-01 subject "$message" message "$message"

done < $fp
