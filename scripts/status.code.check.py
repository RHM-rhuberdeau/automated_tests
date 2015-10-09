#!/usr/bin/python
# encoding: utf-8

from twisted.internet import reactor, threads
from urlparse import urlparse
from random import random
import httplib, os, sys, getopt, optparse, datetime, collections
import itertools
#-->pip install regex
import string, re





# sys.exit()


script_cwd = os.path.dirname(os.path.realpath(__file__))
parser = optparse.OptionParser()
parser.add_option('-f', '--file', action="store", dest="file"
    , help="file with newline for each url", default=script_cwd + "/list.100k.crawl.txt", metavar="./list.100k.crawl.txt")
parser.add_option('-p', '--proxy', action="store_const", const=1, dest="proxy"
    , help="Flag to use proxy", default=0)
parser.add_option('-r', '--ramdom', action="store_const", const=1, dest="ramdom"
    , help="Select entries at Random to test", default=0)
parser.add_option('-b', '--cache-buster', action="store_const", const=1, dest="cache_bust"
    , help="Set query string for cache busting", default=0)
parser.add_option('-w', '--compare-with',action="store_const", const=0, dest="compare"
    , help="requires --second-domain to compare with the primary domain", default=1)
parser.add_option('-e', '--display-all',action="store_const", const=1, dest="display_all"
    , help="The defaul is to just display errors when comparing", default=0)
parser.add_option('-l', '--limit', action="store", dest="limit"
    ,help="Limit scan to 'n'", default="100000", metavar="100000", type="int")
parser.add_option('-d', '--domain', action="store", dest="domain"
    ,help="Default Domain", default="http://www.healthcentral.com", metavar="http://www.healthcentral.com")
parser.add_option('-s', '--second-domain', action="store", dest="second_domain"
    ,help="Second domain to compare", default="http://qa2.healthcentral.com", metavar="http://qa2.healthcentral.com")
parser.add_option('-c', '--concurent', action="store", dest="concurent"
    ,help="concurent scans", default=5, metavar=5)
options, args = parser.parse_args()


if not re.search(("^http://.*"), options.domain):
    options.domain = "http://" + options.domain
if not re.search(("^http://.*"), options.second_domain):
    options.second_domain = "http://" + options.second_domain
#arg_other_test_domain = input("Enter a subdomain to test agains: ")
arg_main_domain=options.domain
arg_other_test_domain=options.second_domain
arg_url_file = options.file
arg_stop_after=options.limit
arg_display_all=options.display_all
arg_use_proxy=options.proxy
arg_just_primary_domain=options.compare
arg_concurrent=options.concurent
arg_ramdom=options.ramdom
arg_cache_bust=options.cache_bust
added_at_cnt=0
cache_key = datetime.datetime.now().strftime('%s')
report_summery=collections.defaultdict(lambda:collections.defaultdict(int))
report_errors=0


finished=itertools.count(1)
reactor.suggestThreadPoolSize(arg_concurrent)


class bcolors:
    OK_L1 = '\033[0;32m'
    OK_L2 = '\033[0;36m'
    OK_L3 = '\033[1;36m'
    WRN_L1 = '\033[0;45;33m'
    WRN_L2 = '\033[0;45;37m'
    ERR_L1 = '\033[0;41;34m'
    ERR_L2 = '\033[1;41;37m'

    GRAY = '\033[0;37m'
    GRAY_BL = '\033[0;40;37m'
    BLUE = '\033[0;34m'
    GREEN = '\033[0;32m'
    WARNING = '\033[93m'
    RED = '\033[0;31m'
    MAGENTA_B = '\033[1;35m'
    MAGENTA = '\033[0;35m'
    FAIL = '\033[91m'
    BOLD = '\033[1m'
    ENDC = '\033[0m'

def statuscode_colorize(status, profile):
    global report_errors
    if profile:
        report_summery[profile][status]+=1
    status = str(status)
    if re.search(("^5[0-9]{2}"), str(status)):
        if profile:
            report_errors+=1
        return bcolors.ERR_L1 + status + bcolors.ENDC
    elif re.search(("^40[4-9]{1}"), str(status)):
        if profile:
            report_errors+=1
        return bcolors.ERR_L2 + status + bcolors.ENDC
    elif re.search(("^40[0-3]{1}"), str(status)):
        if profile:
            report_errors+=1
        return bcolors.WRN_L1 + status + bcolors.ENDC
    elif re.search(("^41[0-9]{1}"), str(status)):
        return bcolors.WRN_L2 + status + bcolors.ENDC
    elif re.search(("^302"), str(status)):
        return bcolors.OK_L3 + status + bcolors.ENDC
    elif re.search(("^3[0-9]{2}"), str(status)):
        return bcolors.OK_L2 + status + bcolors.ENDC
    else:
        return bcolors.OK_L1 + status + bcolors.ENDC

def is_good_statuscode(status):
    if re.search(("200|301|302"), str(status)):
        return True
    else:
        return False


f = open('/tmp/test.py.txt','w')
def logger(msg, prt):
    if prt == 1:
        print msg
    print >>f, strip_term_color(msg)

def strip_term_color(msg):
    return re.sub('\033\[[0-9;]+m', '', msg)

def strip_domain(url):
    return re.sub('[\:\/a-z]{1,14}\.[a-z\.\-]{1,20}\.[a-z]{1,4}', '', url)

def getStatus(ourl):
    if arg_cache_bust == 1 and not re.search((".*\?.*"), ourl):
        ourl = ourl + "?c=" + cache_key

    if re.search(("^/.*"), ourl):
        purl = arg_main_domain+ourl.strip()
    else:
        purl = ourl.strip()

    url = urlparse(purl)
    start = datetime.datetime.now()
    if arg_use_proxy == 1 and arg_just_primary_domain == 1 :
        conn = httplib.HTTPConnection("10.0.0.10", 3128)
        conn.request("HEAD", purl)
    else :
        conn = httplib.HTTPConnection(url.netloc)
        conn.request("HEAD", url.path)
    res = conn.getresponse()
    res.timer = datetime.datetime.now() - start

    if arg_just_primary_domain == 0:
        #--- scan aother domain
        start = datetime.datetime.now()
        if arg_use_proxy == 0 :
            if re.search(("^/.*"), ourl):
                surl = arg_other_test_domain+ourl
            else:
                surl = ourl
            url = urlparse(surl)
            conn = httplib.HTTPConnection(url.netloc)
            conn.request("HEAD", url.path)
        else:
            conn = httplib.HTTPConnection("10.0.0.10", 3128)
            conn.request("HEAD", purl)
        res_other = conn.getresponse()
        res.other = res_other
        #res.other.timer = int(round(diff.microseconds / 1000 / 60, 2))
        res.other.timer = datetime.datetime.now() - start
    #--- return main respeonse and the other host response
    return res

def processResponse(resp,url):
    location_other = ""
    timer_other = ""
    location = ""
    server = ""
    server_other = ""
    if 'location' in resp.msg.dict:
        location = resp.msg.dict['location']
    if 'server' in resp.msg.dict:
        server = resp.msg.dict['server']
    if arg_just_primary_domain == 0:
        if 'server' in resp.other.msg.dict:
            server_other = resp.other.msg.dict['server']
        if 'location' in resp.other.msg.dict:
            location_other = resp.other.msg.dict['location']
        if resp.other.timer:
            timer_other = resp.other.timer
        #--- only care about the diffances
        if (resp.status != resp.other.status) or (arg_display_all <> 0):
            report_summery['BOTH']['diff']+=1
            msg = '{1},{4},{0},{3},{6},{7},{8}'.format( strip_domain(url), statuscode_colorize(resp.status, '(1) ' + arg_main_domain), server, strip_domain(location), statuscode_colorize(resp.other.status, '(2) ' + arg_other_test_domain), server_other, location_other, resp.timer, timer_other)
            # total_timer = (resp.timer + timer_other)
            # print "{0} and ".format( total_timer.timer )
            logger(msg, 1)
    else:
        the_status = is_good_statuscode(resp.status)
        if (the_status == False) and (arg_display_all == 0):
            msg = '{1},,{0},{3},,{4},'.format(strip_domain(url), statuscode_colorize(resp.status, arg_main_domain), server, strip_domain(location), resp.timer)
            logger(msg, 1)
        #total_timer += resp.timer.microseconds
    thecount = counter()
    sys.stdout.write("  {3}  {2}% {1} of {0} @{5}concurrent - ERRORS [{6}]  {4} \r".format(added, thecount, get_percentage(thecount, added), bcolors.GRAY_BL, bcolors.ENDC, arg_concurrent, report_errors))
    sys.stdout.flush()
    processedOne()

def counter():
    global added_at_cnt
    added_at_cnt += 1
    return added_at_cnt
def get_percentage(added_at_cnt, cur_total):
    return int(round(added_at_cnt * 100 / cur_total))


def processError(error,url):
    print ',,{0},ERROR: {1},,'.format(url, error)
    processedOne()

def processedOne():
    if finished.next()==added:
        reactor.stop()

def addTask(url):
    req = threads.deferToThread(getStatus, url)
    req.addCallback(processResponse, url)
    req.addErrback(processError, url)


print 'Status Code,Status Code2,URL,Redirect,Redirect2'



added=0
list_urls={}
if arg_ramdom == 1:
    lines = [line for line in open(arg_url_file) if random() >= .5]
else:
    lines = open(arg_url_file)
for url in lines:
    if re.search(("^#.*"), url) or not url:
        continue

    url = url.strip()

    if( list_urls.has_key(url) ):
        continue
    added+=1

    addTask(url)
    list_urls[url]=added
    if arg_stop_after == added:
        break


try:
    reactor.run()
except (KeyboardInterrupt, SystemExit):
    print "Interrupted by keyboard. Exiting."
    reactor.stop()
f.close()

print "\n\n{0}Summery{1}".format(bcolors.GRAY_BL, bcolors.ENDC)
for profile, scodes in report_summery.iteritems():
    print '{1}{0}{2}'.format(profile, bcolors.MAGENTA_B, bcolors.ENDC)
    for scode, snum in scodes.iteritems():
        print '\t{0}: ({1})'.format(statuscode_colorize(scode, ''), snum)
