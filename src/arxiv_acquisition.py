# Code modified from Tim Head - http://betatim.github.io/posts/analysing-the-arxiv/

import time
import urllib2
import datetime
import xml.etree.ElementTree as ET

OAI = "{http://www.openarchives.org/OAI/2.0/}"
ARXIV = "{http://arxiv.org/OAI/arXiv/}"

def harvest(arxiv="q-bio", out_file="arxiv-bio-data.xml"):
    base_url = "http://export.arxiv.org/oai2?verb=ListRecords&"
    url = (base_url +
           "from=1997-01-01&until=2014-12-31&" +
           "metadataPrefix=arXiv&set=%s"%arxiv)
    with open(out_file, 'w+') as f:
        f.write("<?xml version="1.0" encoding="UTF-8"?>\n<root>")
    while True:
        print "fetching", url
        try:
            response = urllib2.urlopen(url)


        except urllib2.HTTPError, e:
            if e.code == 503:
                to = int(e.hdrs.get("retry-after", 30))
                print "Got 503. Retrying after {0:d} seconds.".format(to)

                time.sleep(to)
                continue

            else:
                raise

        xml = response.readlines()

        with open(out_file, 'a+') as f:
            for l in xml[1:]:
                f.write(l)

        root = ET.fromstring(xml)
        token = root.find(OAI+'ListRecords').find(OAI+"resumptionToken")

        if token is None or token.text is None:
            with open(out_file, 'a+') as f:
                f.write("</root>")
            break

        else:
            url = base_url + "resumptionToken=%s"%(token.text)

harvest()
