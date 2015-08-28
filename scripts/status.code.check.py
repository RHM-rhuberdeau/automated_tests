#!/usr/bin/python
# encoding: utf-8



from twisted.internet import reactor, threads
from urlparse import urlparse
import httplib
import itertools
#pip install regex
import string, re
import sys, getopt, optparse


parser = optparse.OptionParser()
parser.add_option('-f', '--file', action="store", dest="file"
    , help="file with newline for each url", default="./list.100k.crawl.txt", metavar="./list.100k.crawl.txt")
parser.add_option('-p', '--proxy', action="store_const", const=1, dest="proxy"
    , help="Flag to use proxy", default=0)
parser.add_option('-w', '--compare-with',action="store_const", const=0, dest="compare"
    , help="requires --second-domain to compare with the primary domain", default=1)
parser.add_option('-e', '--display-all',action="store_const", const=1, dest="display_all"
    , help="The defaul is to just display errors when comparing", default=0)
parser.add_option('-l', '--limit', action="store", dest="limit"
    ,help="Limit scan to 'n'", default="10000", metavar="10000", type="int")
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

# print options
# sys.exit(0)


finished=itertools.count(1)
reactor.suggestThreadPoolSize(arg_concurrent)

def strip_domain(url):
    # return string.replace(url, 'http://www.healthcentral.com', '')
    return re.sub('[\:\/a-z]{1,14}\.[a-z\.\-]{1,20}\.[a-z]{1,4}', '', url)
    #re.sub(r"(?i)^.*healthcentral.com$" % '', url)

def getStatus(ourl):
    if re.search(("^/.*"), ourl):
        purl = arg_main_domain+ourl.strip()
    else:
        purl = ourl.strip()

    url = urlparse(purl)
    if arg_use_proxy == 1 and arg_just_primary_domain == 1 :
        conn = httplib.HTTPConnection("10.0.0.10", 3128)
        conn.request("HEAD", purl)
    else :
        conn = httplib.HTTPConnection(url.netloc)
        conn.request("HEAD", url.path)
    res = conn.getresponse()

    if arg_just_primary_domain == 0:
        #--- scan aother domain
        if arg_use_proxy == 0 :
            #surl = string.replace(ourl, arg_main_domain, arg_other_test_domain)
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
for url in open(arg_url_file):
    # if re.search(("^/.*"), url):
    #     url = arg_main_domain+url.strip()
    # else:
    #     url = url.strip()
    url = url.strip()

    if( list_urls.has_key(url) ):
        continue
    added+=1

    addTask(url)
    list_urls[url]=added
    #if "%s" % arg_stop_after == "%s" % added:
    if arg_stop_after == added:
        break

try:
    reactor.run()
except (KeyboardInterrupt, SystemExit):
    print "Interrupted by keyboard. Exiting."
    reactor.stop()

