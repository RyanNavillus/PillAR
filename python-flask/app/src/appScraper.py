from src import app
from flask import render_template
import urllib2, json
from bs4 import BeautifulSoup

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


    medicationURL = searchResultList[0]
    request1 = urllib2.urlopen(medicationURL)
    result1 = request1.read()
    soup1 = BeautifulSoup(result1, 'html.parser')

    sections = soup1.find('section', class_='drug-monograph-section')
    headings = sections.find_all('h2')
    paragraphs = sections.find_all('p')

    pIndex = 0
    medicationInfo = []
    newHTML = ""
    for i in headings:
        h2 = i.get_text()
        if h2 in dosageHeadings:
            p = paragraphs[pIndex]
            #print (h2 + " " + p.get_text())
            medicationInfo.append(h2 + " " + p.get_text())
            newHTML = newHTML + str(i) + str(p)
        pIndex += 1

    return newHTML
