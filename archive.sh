#!/bin/bash
log="/root/log/"
bp="/root/backup/"
gyb="/root/bin/gyb/gyb"
gam="/root/bin/gamadv-xtd3/gam"
tmp="/root/tmp/"
usr="adminaccount@example.com"
fn="del"
fp=$tmp$fn".csv"
fpm=$fp"-m"
ua="users.archive"

#spreadsheet who is to be deleted
idr="1rC0DSKnZ_vT7EMlMcJ8zY7F8ysEMdfm3I4JBPb4dWJM"

#mail archive folder id
idwf="1dSZ3q7ZVh_KNtmlF306I9k-GMaTmX7TW"

rm $fp > /dev/null 2>&1
$gam user $usr get drivefile $idr csvsheet .delete targetfolder $tmp targetname $fn
mv $fp $fpm

cat -A $fpm | tr -d "^M$" > $fp
rm $fpm > /dev/null 2>&1

echo "" >> $fp

iu=$(wc -l $fp | cut -d " " -f 1)
echo "$iu users to archive, (b)reak?, (m)ail only, mail+(d)drive"
read odp


if [ $odp == "b" ]; then
exit 1
fi

while IFS="," read -r u
do
        $gyb --service-account --email $u --local-folder $bp$u
        tar -zcvf $bp$u".tar.gz" $bp$u
        $gam user $ua add drivefile localfile $bp$u".tar.gz" #parentid $idwf
        rm -r $bp$u $bp$u".tar.gz"


if [ $odp == "d" ]; then
        $gam user $u transfer drive $ua
        $gam delete user $u
fi

$gam sendemail michal.wilas@tzmo-global.com subject "Archiwizacja zakończona $u"

done < $fp
