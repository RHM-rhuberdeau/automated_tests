#!/bin/bash
#
# ron.checktimeload.urls.sh drupal1.hcaws.net www.healthcentral.com
# time curl --header Host:www.healthcentral.com -s -D - drupal1.hcaws.net/adhd -o /dev/null
#

TIME_BEGIN=$(date +%s)

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
                        echo "-a, --header=curl_header  curl custom header"
                        echo "-c, --cache-buster        if flagged, we append unix epoc seconds to the url as a query sting"
                        echo "-p, --proxy               use oru proxy server 10.0.0.10:3128"
                        echo "-d, --domain=www.healthcentral.com  use this domain for relative paths"
                        exit 0
                        ;;
                -p|--proxy)
                        HEADER+=" --proxy http://10.0.0.10:3128"
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
                -c)
                        shift
                        if test $# -gt 0; then
                                export CACHEBUST="?test=${TIME_BEGIN}"
                        else
                                echo "no process specified"
                                exit 1
                        fi
                        shift
                        ;;
                --cache-buster*)
                        export CACHEBUST="?test=${TIME_BEGIN}"
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



#if [[ "${DOMAIN// }" == "" ]]; then
if [[ -z "${DOMAIN}" ]]; then
	DOMAIN="www.healthcentral.com"
fi
if [ -f "$FILE" ]; then
	#urls=$(cat $FILE)
	index=0
	while read line; do
	  urls+=("$line")
	done < $FILE
else
	urls=(
		/alzheimers/cf/slideshows/
		/

		/acid-reflux/
		/alzheimers/
		/bipolar/
		/cold-flu/
		/high-blood-pressure/
		/skin-care/

		/acid-reflux/cf/quizzes/
		/alzheimers/cf/quizzes/
		/bipolar/cf/quizzes/
		/cold-flu/cf/quizzes/
		/high-blood-pressure/cf/quizzes/
		/skin-care/cf/quizzes/

		/acid-reflux/cf/slideshows/7-tricks-help-prevent-acid-reflux
		/alzheimers/cf/slideshows/10-conditions-can-mimic-dementia
		/bipolar-disorder/cf/slideshows/10-people-who-shaped-how-we-view-bipolar-disorder
		/cold-flu/cf/slideshows/10-best-foods-fight-spring-colds
		/high-blood-pressure/cf/slideshows/10-foods-to-avoid-with-high-blood-pressure
		/skin-care/cf/slideshows/12-terms-you-may-hear-when-living-psoriasis

		/acid-reflux/cf/slideshows/
		# /alzheimers/cf/slideshows
		# /bipolar/cf/slideshows
		# /cold-flu/cf/slideshows
		# /high-blood-pressure/cf/slideshows
		# /skin-care/cf/slideshows

	 )
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
    the_human_time="TOTAL EXECUTION TIME: ${day}d ${hour}h ${min}m ${sec}s"
    echo $the_human_time
}

GREEN='\033[1;32m'
RED='\033[0;31m'
NOTE='\033[0;35m'
NC='\033[0m'
for i in "${urls[@]}"
do
	if [[ "${i}" == \#* ]]; then
		continue
	fi
	if [[ ! -n "${i}" ]]; then
		continue
	fi
	if [[ $i == /* ]] ; then
		baseurl=$DOMAIN
	fi
	printf "====> ${baseurl}${i} <===="
    #time curl $header -s -D - "http://${baseurl}${i}" -o /dev/null
	#curl -I http://google.com | head -n 1| cut -d $' ' -f2
	#curl -s --head --location http://google.com | head -n 1 | grep "HTTP/1.[01] [23].."
	#RESPONSE=$(time curl -IL $HEADER --silent "${baseurl}${i}" | grep HTTP)
    RESPONSEFULL=$(curl --head --location --silent $HEADER  "${baseurl}${i}" | grep "HTTP\|Location")


	echo
	if [[ $RESPONSEFULL == *200* ]] ; then
		printf "${GREEN}${RESPONSEFULL}${NC}"
	else
		printf "${RED}${RESPONSEFULL}${NC}"
	fi
	echo ""
	baseurl=""
done

TIME_END=$(date +%s)

TIME_DIFF=(TIME_END-TIME_BEGIN)
second_to_human_time $TIME_DIFF
TIME_EXEC=$?

