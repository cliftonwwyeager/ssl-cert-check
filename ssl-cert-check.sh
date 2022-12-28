#!/bin/bash

DOMAINS="/path/to/list.txt"
RECIPIENT="email@sender.com"
DAYS="30"

while read -r DOMAIN; do
	echo "checking if $DOMAIN expires in less than $DAYS days";
	expirationdate=$(date -d "$(: | openssl s_client -connect $DOMAIN 2>/dev/null | openssl x509 -noout -dates  | grep 'notAfter' | awk -F '[= ]' '{print $2,$3,$4,$6}')" '+%s');
	in30days=$(($(date +%s) + (86400*$DAYS)));
	if [[ $in30days -ge $expirationdate ]]; then
	    echo "SSL certificates expiring within the next 30 days for $DOMAIN on $(date -d @$expirationdate) " >>domainslist \
		|| mail -s "SSL certificates expiring within 30 days" $RECIPIENT < domainslist
	else
		echo "SSL Certs--No problems found" \
		|| mail -s "SSL Certs for $DOMAIN--Okay" $RECIPIENT < nop.txt
	fi;
done<"${DOMAINS}"
mail -s "SSL certificates expiring within 30 days" $RECIPIENT < domainslist
mail -s "SSL Certs--Okay" $RECIPIENT < nop.txt
