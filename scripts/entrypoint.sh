#!/bin/bash

if [ ! -f /etc/app_configured ]; then
    mkdir -p /znc-data/configs
    mv /znc.conf /znc-data/configs/znc.conf

    RAND1=$(echo `</dev/urandom tr -dc A-Za-z0-9 | head -c18`)
    RAND2=$(echo `</dev/urandom tr -dc A-Za-z0-9 | head -c18`)

echo '#!/usr/bin/expect -f' > /root/${RAND1}
echo "set timeout -1
spawn /opt/znc/bin/znc --makepass -n
expect {
password {send \"${PASSWORD}\r\" ; exp_continue}
eof exit
}" >> /root/${RAND1}

    chmod +x /root/${RAND1}

    /root/${RAND1} > /root/${RAND2}

    HASH=$(cat /root/${RAND2} | grep Hash | awk '{print $3}')
    SALT=$(cat /root/${RAND2} | grep Salt | awk '{print $3}')

    ZNCPASS=$(echo sha256#${HASH}#${SALT}# | tr -d '\r' | sed -e 's/[\/&]/\\&/g')

    sed -i 's/USER/'${USERNAME}'/g' /znc-data/configs/znc.conf
    sed -i 's/ZNCPASS/'${ZNCPASS}'/g' /znc-data/configs/znc.conf

    rm -rf /root/${RAND1}
    rm -rf /root/${RAND2}

    chown -R znc:znc /znc-data
    chmod 700 /znc-data

    touch /etc/app_configured
fi

/bin/su -s /bin/bash -c "znc --foreground --datadir /znc-data" znc