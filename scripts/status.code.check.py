#!/usr/bin/python
# encoding: utf-8


from twisted.internet import reactor, threads
from urlparse import urlparse
import httplib
import itertools
#pip install regex
import string, re
import sys, getopt


#arg_other_test_subdomain = input("Enter a subdomain to test agains: ")
arg_other_test_subdomain="qa1"
arg_url_file = '/Users/ron/Dropbox/RHM/tmp/100k.crawl.txt'
arg_stop_after=0
arg_display_all=0
arg_use_proxy=0
arg_just_primary_domain=1
arg_print_header=1
arg_concurrent=5

def args_help():
    print "\n"
    print "Usage:"
    print "\t-f list.txt : URL file location "
    print "\t-0 0 : Set to '0' to scan second domain, works with '-s' flag"
    print "\t-s qa1 : subdomain URL file prefix, defaul 'qa1', requires '-o 0'"
    print "\t-l 5 : Limit to 'n' in the scan, defaul all"
    print "\t-p 1 : Use proxy server: 10.0.0.10:3128 also set '-s www'"
    print "\t-d 1 : Display All, default (0) display only errors"
    print "\nExample:"
    print " '-f list_path.txt' open file list_path.txt "
    print " '-l 15' scan 15 enties"
    print " '-o 0' scan a second host, default second host is 'qa1'"
    print " '-s qa1'change subdomain of the second to E.G. qa1.healthcentral.com"
    print " '-p 1' using a proxy"
    print "status.code.check.py -f list_path.txt -l 15 -o0 -s qa1 -p 1"
    print "\n"
    sys.exit(0)

if len(sys.argv) < 1:
    if sys.argv[1] == '-h':
        args_help()
#myopts, args = getopt.getopt(sys.argv[1:],"f:l:s:d:h:p:", ["file", "stop=", "subdomain=", "display", "help", "proxy"])
myopts, args = getopt.getopt(sys.argv[1:],"f:l:s:d:h:p:o:w:c:")
for o, a in myopts:
    if o == '-f':
        arg_url_file=a
    elif o == '-s':
        arg_other_test_subdomain=a
    elif o == '-l':
        arg_stop_after=a
    elif o == '-d':
        arg_display_all=a
    elif o == '-p':
        arg_use_proxy=a
        arg_other_test_subdomain='www'
    elif o == '-o':
        arg_just_primary_domain=1
    elif o == '-w':
        arg_print_header=a
    elif o == '-c':
        arg_concurrent=a
    elif o == '-h':
        rgs_help()
    else:
        print("Don't know what do do with: %s " % o, a)
        args_help()



finished=itertools.count(1)
reactor.suggestThreadPoolSize(arg_concurrent)

if arg_print_header == 1:
    print 'Status Code,Status Code2,URL,Redirect,Redirect2'

def strip_domain(url):
    # return string.replace(url, 'http://www.healthcentral.com', '')
    return re.sub('[\:\/a-z]{1,14}\.[a-z\.\-]{1,20}\.[a-z]{1,4}', '', url)
    #re.sub(r"(?i)^.*healthcentral.com$" % '', url)

def getStatus(ourl):
    url = urlparse(ourl)
    conn = httplib.HTTPConnection(url.netloc)
    conn.request("HEAD", url.path)
    res = conn.getresponse()
    #--- scan second domain
    if arg_just_primary_domain == 0:
        if arg_use_proxy == 0 :
            other_url = string.replace(ourl, 'www', arg_other_test_subdomain)
            url = urlparse(other_url)
            conn = httplib.HTTPConnection(url.netloc)
            conn.request("HEAD", url.path)
        else:
            conn = httplib.HTTPConnection("10.0.0.10", 3128)
            conn.request("HEAD", ourl)
        res_other = conn.getresponse()
        res.other = res_other
    #--- return main respeonse and the other host response
    return res

def processResponse(resp,url):
    location_other = ""
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

        #--- only care about the diffances
        if (resp.status != resp.other.status) or (arg_display_all <> 0):
            # main:status,other:status,test URI,main:response uri,other:response url
            print '{1},{4},{0},{3},{6}'.format(strip_domain(url), resp.status, server, strip_domain(location), resp.other.status, server_other, location_other)
    else:
        print '{1},,{0},{3},'.format(strip_domain(url), resp.status, server, strip_domain(location))
    processedOne()

def processError(error,url):
    #print (',,r%,ERROR,' % (url, error) )#, error
    print ',,{0},ERROR: {1},,'.format(url, error)
    processedOne()

def processedOne():
    if finished.next()==added:
        reactor.stop()

def addTask(url):
    req = threads.deferToThread(getStatus, url)
    req.addCallback(processResponse, url)
    req.addErrback(processError, url)

added=0
url_strip=''
list_urls={}
#--- loop through urls to scan
# - remove dupe urls
# - ensure urls are full path
for url in open(arg_url_file):
    url_strip=url.strip()
    m = re.match('^http://.*', url_strip)
    if(m == ''):
        continue
    if( list_urls.has_key(url_strip) ):
        continue
    added+=1
    addTask(url_strip)
    list_urls[url_strip]=1
    if "%s" % arg_stop_after == "%s" % added:
        break
try:
    reactor.run()
except KeyboardInterrupt:
    reactor.stop()
    sys.exit(0)


