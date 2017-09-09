from src import app
from flask import render_template
import urllib2, json
from bs4 import BeautifulSoup
import re

dosageHeadings = ["Adult:", "Children:", "Adults and Children:"]

@app.route("/")
@app.route("/medication/<medication>")
def getMedicationInfo(medication):

    url="http://www.empr.com/search/%s/"
    url=url%(medication)
    request = urllib2.urlopen(url)
    result = request.read()
    soup = BeautifulSoup(result, 'html.parser')

    searchResults = soup.find_all('h1')
    searchResultList = []
    for i in searchResults:
        searchResultList.append(str(i.a.get('href')))

    if searchResultList[0]:
        medicationURL = searchResultList[0]
    else:
        return json.dumps({'error':'try again'})

    request1 = urllib2.urlopen(medicationURL)
    result1 = request1.read()
    soup1 = BeautifulSoup(result1, 'html.parser')

    sections = soup1.find('section', class_='drug-monograph-section')
    headings = sections.find_all('h2')
    paragraphs = sections.find_all('p')

    pIndex = 0
    medicationInfo = {}
    newHTML = ""
    for i in headings:
        h2 = i.get_text()
        if h2 in dosageHeadings:
            p = paragraphs[pIndex]
            pText = p.get_text()
            h2 = h2.strip(':')
            #print (h2 + " " + p.get_text())
            #medicationInfo.append(h2 + " " + p.get_text())
            medicationInfo[h2.strip(':')] = pText

            # if 'once daily' in pText:
            #     medicationInfo[h2.strip(':') + " dosage"] += "once daily"
            # elif 'every ' and ' hours' in pText:
            #     medicationInfo[h2.strip(':')]
            #newHTML = newHTML + str(i) + str(p)
        # if 'How Supplied' in h2:
        #     medicationInfo['mg per pill'] = paragraphs[pIndex].get_text()
        #     medicationInfo['mg per pill regex'] = re.search(r'(?:\d*\.)?\d+mg', paragraphs[pIndex].get_text()).group()
        pIndex += 1

    #return newHTML
    return json.dumps(medicationInfo)
