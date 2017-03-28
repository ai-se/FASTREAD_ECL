
import urllib2
import ujson
import xmltodict
from pdb import set_trace

# Find the record structure of the logical filename

thor_ip = '192.168.56.101'
url = "http://" + thor_ip + ":8002/WsEcl/submit/query/thor/demo/json?"
url += "data=\'" + '~Hall.csv' + "\'&"
url += "sample_no=" + "world"

# Replacing the whitespace in the url with %20
url = url.replace(' ', '%20')

# Download the content of the page
response = urllib2.urlopen(url)
html = response.read()

# Parsing the response
j = ujson.loads(html)

set_trace()
xml_string = '<root>' + str(
    j["runprogramResponse"]["Results"]["data"]["Row"][-1]["Result"]) + '</root>'
set_trace()
o = xmltodict.parse(xml_string)
rows = o["root"]["Dataset"]["Row"]
content = [[row[key] for key in row.keys()] for row in rows]