#!/bin/bash
set -x
NEWPASSWORD=$1

RAND1=$(echo `</dev/urandom tr -dc A-Za-z0-9 | head -c18`)
RAND2=$(echo `</dev/urandom tr -dc A-Za-z0-9 | head -c18`)

echo '#!/usr/bin/expect -f' > /root/${RAND1}
echo "set timeout -1
spawn /usr/local/bin/znc --makepass -n
expect {
password {send \"${ZNCPASS}\r\" ; exp_continue}
eof exit
}" >> /root/${RAND1}

chmod +x /root/${RAND1}
/root/${RAND1} > /root/${RAND2}

HASH=$(cat /root/${RAND2} | grep Hash | awk '{print $3}')
SALT=$(cat /root/${RAND2} | grep Salt | awk '{print $3}')
SALT="$(cat /root/${RAND2} | grep Salt | awk '{print $3}')"

sed -ie 's/Hash =.*/Hash = '${HASH}'/g' /znc-data/configs/znc.conf
sed -ie 's/Salt =.*/Salt = '${HASH}'/g' /znc-data/configs/znc.conf

rm -rf /root/${RAND1}
rm -rf /root/${RAND2}

echo "Password changed successfully."