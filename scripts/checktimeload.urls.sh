#!/bin/bash
#
# ron.checktimeload.urls.sh drupal1.hcaws.net www.healthcentral.com
# time curl --header Host:www.healthcentral.com -s -D - drupal1.hcaws.net/adhd -o /dev/null
#

TIME_BEGIN=$(date +%s)
GREEN='\033[1;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BG_RED='\033[0;41m'
BG_YELLOW='\033[0;43m'
NOTE='\033[0;35m'
NC='\033[0m'

while test $# -gt 0; do
        case "$1" in
                -h|--help)
                        echo "$package - get status codes and load tims of urls"
                        echo " "
                        echo "$package [options] application [arguments]"
                        echo " "
                        echo "options:"
                        echo "-h, --help                show brief help"
                        echo "-f, --file=FILE           file of URLs"
                        echo "-d, --domain=www.healthcentral.com  use this domain for relative paths"
                        echo "-a, --header=curl_header  curl custom header"
                        echo "-c, --cache-buster        if flagged, we append unix epoc seconds to the url as a query sting"
                        echo "-p, --proxy               use oru proxy server 10.0.0.10:3128"
                        echo "-t, --show-time           Show time to get each link"
                        echo "-v, --verbose             Show all statuses"
                        exit 0
                        ;;
                -p|--proxy)
                        HEADER+=" --proxy http://10.0.0.10:3128"
                        shift
                        ;;
                -v|--verbose)
                        SHOWSUCCESS=1
                        shift
                        ;;
                -t|--show-time)
                        export SHOWTIME=1
                        shift
                        ;;
                -c|--cache-buster)
                        export CACHEBUST="test=${TIME_BEGIN}"
                        shift
                        ;;
                -f)
                        shift
                        if test $# -gt 0; then
                                export FILE=$1
                        else
                                echo "no process specified"
                                exit 1
                        fi
                        shift
                        ;;
                --file*)
                        export FILE=`echo $1 | sed -e 's/^[^=]*=//g'`
                        shift
                        ;;
                -d)
                        shift
                        if test $# -gt 0; then
                                export DOMAIN=$1
                        else
                                echo "no process specified"
                                exit 1
                        fi
                        shift
                        ;;
                --domain*)
                        export DOMAIN=`echo $1 | sed -e 's/^[^=]*=//g'`
                        shift
                        ;;
                -a)
                        shift
                        if test $# -gt 0; then
                                export HEADER=$1
                        else
                                echo "no output dir specified"
                                exit 1
                        fi
                        shift
                        ;;
                --header*)
                        export HEADER+=`echo $1 | sed -e 's/^[^=]*=//g'`
                        shift
                        ;;
                *)
                        break
                        ;;
        esac
done


if [[ -z "${DOMAIN}" ]]; then
	DOMAIN="www.healthcentral.com"
fi
if [[ -z "${FILE}" ]]; then
    read < <(readlink  $0 | xargs dirname)
    FILE="${REPLY}/quick.stack.link.txt"
fi

if [ -f "$FILE" ]; then
	#urls=$(cat $FILE)
	index=0
	while read line; do
	  urls+=("$line")
	done < $FILE
else
    echo
    printf "${RED}Please specify a file of URLs to scan:${NC}\n"
    printf "${0} -f ./quick.stack.link.txt\n"
    echo
    exit
fi


second_to_human_time () {
    num=$1
    min=0
    hour=0
    day=0
    if((num>59));then
        ((sec=num%60))
        ((num=num/60))
        if((num>59));then
            ((min=num%60))
            ((num=num/60))
            if((num>23));then
                ((hour=num%24))
                ((day=num/24))
            else
                ((hour=num))
            fi
        else
            ((min=num))
        fi
    else
        ((sec=num))
    fi
    the_human_time="[${day}d ${hour}h ${min}m ${sec}s] TOTAL EXECUTION TIME"
    echo $the_human_time
}


TMP_RSP='/tmp/rsp_msg'
re="real ([0-9sm\.]*)"

for i in "${urls[@]}"
do
	if [[ "${i}" == \#* ]]; then
        echo
        printf "${BG_YELLOW}${i}${NC}"
		continue
	fi
	if [[ ! -n "${i}" ]]; then
		continue
	fi
    if [[ $i == /* ]] ; then
        baseurl=$DOMAIN
    fi
    if [[ $i == *\?* && ! -z "$CACHEBUST" ]] ; then
        url_to_test="${baseurl}${i}&${CACHEBUST}"
    elif [[ ! -z "$CACHEBUST" ]] ; then
        url_to_test="${baseurl}${i}?${CACHEBUST}"
    else
        url_to_test="${baseurl}${i}"
    fi
    #time curl $header -s -D - "http://${baseurl}${i}" -o /dev/null
	#curl -I http://google.com | head -n 1| cut -d $' ' -f2
	#curl -s --head --location http://google.com | head -n 1 | grep "HTTP/1.[01] [23].."
	#RESPONSE=$(time curl -IL $HEADER --silent "${baseurl}${i}" | grep HTTP)
    #RESPONSEFULL=$(${checktime} curl --head --location --silent $HEADER  "${baseurl}${i}?${CACHEBUST}" | grep "HTTP\|Location")
    if [[ "${SHOWTIME}" == 1 ]]; then
        THETIMER=$(time (curl --head --location --silent $HEADER "${url_to_test}" | grep "HTTPS\|HTTP\|Location" >${TMP_RSP} ) 3>&1 1>&2 2>&3 )
        #RESPONSEFULL=$(tr '\015' ' ' < /tmp/tmp.txt)
        THETIMER=$(echo $THETIMER | tr '\015' ' ')
        RESPONSEFULL=$( < ${TMP_RSP})
    else
        RESPONSEFULL=$(curl --head --location --insecure --silent $HEADER "${url_to_test}" | grep "HTTPS\|HTTP\|Location")
    fi

    if [[ $THETIMER =~ $re ]]; then real_time=${BASH_REMATCH[1]}; fi
	if [[ $RESPONSEFULL == *200* ]] ; then
        echo
        if [[ ! -n "${real_time}" ]]; then real_time="200"; fi
        if [[ -n $SHOWSUCCESS ]] ; then
            printf "[${LIGHT}${real_time}${NC}] ${url_to_test} "
            echo
            printf "${GREEN}${RESPONSEFULL}${NC}"
        else
            printf "[${real_time}] ${GREEN}${url_to_test}${NC}..."
        fi
	else
        if [[ ! -n "${real_time}" ]]; then real_time="ERROR"; fi
        echo
        printf "[${RED}${real_time}${NC}] ${url_to_test} "
        echo
		printf "${RED}${RESPONSEFULL}${NC}"
	fi
	baseurl=""
    real_time=""
done

echo
echo
TIME_END=$(date +%s)
TIME_DIFF=(TIME_END-TIME_BEGIN)
second_to_human_time $TIME_DIFF
TIME_EXEC=$?
echo

