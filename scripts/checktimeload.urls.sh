#!/bin/bash
#
# ron.checktimeload.urls.sh drupal1.hcaws.net www.healthcentral.com
# time curl --header Host:www.healthcentral.com -s -D - drupal1.hcaws.net/adhd -o /dev/null
#

THE_LOGFILE="/tmp/scanlog.txt"
TMP_RSP='/tmp/rsp_msg'
DEFAULT_SCAN_FILE='list.quick.stack.link.txt'
TIME_BEGIN=$(date +%s)
GREEN='\033[0;32m'
GREEN_B='\033[1;32m'
BLUE='\e[0;94m'
BLUE_B='\e[1;94m'
RED='\033[0;31m'
RED_B='\033[1;31m'
MAGENTA='\e[0;35m';
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
                        echo "-o, --out-file=FILE       file for log output"
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
                # -o)
                #         shift
                #         if test $# -gt 0; then
                #                 export THE_LOGFILE=$1
                #         else
                #                 echo "no process specified"
                #                 exit 1
                #         fi
                #         shift
                #         ;;
                # --out-file*)
                #         export THE_LOGFILE=`echo $1 | sed -e 's/^[^=]*=//g'`
                #         shift
                #         ;;
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
    FILE="${REPLY}/${DEFAULT_SCAN_FILE}"
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
    printf "${0} -f ./${DEFAULT_SCAN_FILE}\n"
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


echo > $THE_LOGFILE
log_output() {
    printf "${1}\n"
    if [[ "${2}" == 1 ]]; then
        #the_string=$(echo $1 | sed -E 's/\\033\[[0-9]{1}\;?[0-9]{1,2}m//g')
        the_string=$1
    else
        the_string=$(echo $1 | sed -E 's/\\033\[[0-9]{1}\;?[0-9]{1,2}m//g')
    fi
    printf "${the_string}\n" >> $THE_LOGFILE
    #printf "%s"  "$*" "$(date +'%Y-%m-%d %H:%M:%S')" >> $THE_LOGFILE
    #the_string=$(echo $* | sed -E "s/"$'\E'"\[([0-9]{1,3}((;[0-9]{1,3})*)?)?[m|K]//g")
    #the_string=`perl -pe 's/\x1b\[[0-9;]*[mG]//g'`
}


re="real ([0-9sm\.]*)"

cnt_error=0
cnt_success=0
cnt_warning=0
cnt_total=0
cnt_total_all=0
MAXPROG=${#urls[@]}
for i in "${urls[@]}"
do
    let cnt_total_all=cnt_total_all+1
	if [[ "${i}" == \#* ]]; then
        printf "${BG_YELLOW}${i}                                ${NC}\n"
        #--- create status
        let cnt_status=$(((cnt_total_all*100)/MAXPROG))
        echo -n "${cnt_status}% ${cnt_total}/${MAXPROG} - ERROR(S): [${cnt_error}]      "
        echo -n R | tr 'R' '\r'
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
    if [[ "${SHOWTIME}" == 1 ]]; then
        THETIMER=$(time (curl --head --location --insecure --connect-timeout 6 --silent -H "Pragma: akamai-x-cache-on" $HEADER "${url_to_test}" > ${TMP_RSP} ) 3>&1 1>&2 2>&3 )
        THETIMER=$(echo $THETIMER | tr '\015' ' ')
        RESPONSEFULL_ALL=$( < ${TMP_RSP})
    else
        RESPONSEFULL_ALL=$(curl --head --location --insecure --connect-timeout 6 --silent -H "Pragma: akamai-x-cache-on" $HEADER "${url_to_test}")
    fi

    RESPONSEFULL=$(echo "${RESPONSEFULL_ALL}" | grep "HTTPS\|HTTP\|Location\|X-Cache")

    if [[ $THETIMER =~ $re ]]; then real_time=${BASH_REMATCH[1]}; fi
	if [[ $RESPONSEFULL == *200* ]] ; then
        cnt_success=$((cnt_success+1))
        if [[ ! -n "${real_time}" ]]; then real_time="200"; fi
        if [[ -n $SHOWSUCCESS ]] ; then
            log_output "[${LIGHT}${real_time}${NC}] ${url_to_test}"
            log_output "${GREEN}${RESPONSEFULL}${NC}" 1
        else
            log_output "[${real_time}] ${GREEN}${url_to_test}${NC}..."
        fi
	else
        if [[ ! -n "${real_time}" ]]; then
            if [[ $RESPONSEFULL =~ .*403|404|500.* ]] ; then
                real_time="ERROR";
                cnt_error=$((cnt_error+1));
                NOTSUCCESS=$RED_B
                NOTSUCCESS_MSG=$RED
            elif [[ $RESPONSEFULL =~ .*410|50[0-9].* ]] ; then
                real_time="WARMING"
                NOTSUCCESS=$MAGENTA
                NOTSUCCESS_MSG=$MAGENTA
                cnt_warning=$((cnt_warning+1));
            else
                real_time="ERROR";
                NOTSUCCESS=$RED
                NOTSUCCESS_MSG=$RED
                cnt_error=$((cnt_error+1));
            fi
        fi
        log_output "[${NOTSUCCESS}${real_time}${NC}] ${BLUE_B}${url_to_test}${NC}"
        log_output "${NOTSUCCESS_MSG}${RESPONSEFULL}${NC}" 1
	fi
	baseurl=""
    real_time=""
    let cnt_total=cnt_total+1
    #--- create status
    let cnt_status=$(((cnt_total_all*100)/MAXPROG))
    echo -n "${cnt_status}% ${cnt_total}/${MAXPROG} - ERROR: [${cnt_error}]      "
    echo -n R | tr 'R' '\r'
#if [ $cnt_total -gt 10 ] ; then exit; fi
done


echo
printf "${cnt_success}\t[${GREEN}200${NC}]\n"
printf "${cnt_warning}\t[${MAGENTA}WARMING${NC}]${NC}\n"
printf "${cnt_error}\t[${RED}ERROR${NC}]${NC}\n"
printf "${cnt_total}\tTOTAL\n"
echo
TIME_END=$(date +%s)
TIME_DIFF=(TIME_END-TIME_BEGIN)
second_to_human_time $TIME_DIFF
TIME_EXEC=$?
echo

