#!/bin/bash

if [ ! -f /etc/app_configured ]; then
    mkdir -p /znc-data/configs
    mv /znc.conf /znc-data/configs/znc.conf

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

    ZNCPASS=$(echo sha256#${HASH}#${SALT}# | tr -d '\r' | sed -e 's/[\/&]/\\&/g')

    sed -i 's/USER/'${USERNAME}'/g' /znc-data/configs/znc.conf
    sed -i 's/ZNCPASS/'${ZNCPASS}'/g' /znc-data/configs/znc.conf
    sed -i 's/ZNCPORT/'${ZNCPORT}'/g' /znc-data/configs/znc.conf

    rm -rf /root/${RAND1}
    rm -rf /root/${RAND2}

    chown -R znc:znc /znc-data
    chmod 700 /znc-data

    #Tell Apex we're done installing.
    curl -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST "https://api.cylo.io/v1/apps/installed/$INSTANCE_ID"
    touch /etc/app_configured
fi

/bin/su -s /bin/bash -c "znc --foreground --datadir /znc-data" znc