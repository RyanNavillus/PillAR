from src import app
from flask import render_template
import urllib2, json
from bs4 import BeautifulSoup
import re, requests

dosageHeadings = ["Adult:", "Adults and Children:"]

@app.route("/")
@app.route("/medication/<medication>")
def getMedicationInfo(medication):

    medication.replace(' ', '-')
    medication.replace('%20', '-')
    
    url="http://www.empr.com/search/%s/"
    url=url%(medication)
    request = urllib2.urlopen(url)
    result = request.read()
    soup = BeautifulSoup(result, 'html.parser')

    numOfSearchResults = re.search("(?:\d+\.)?\d+", soup.find('span', class_='hmiSearchTerm').parent.get_text()).group()

    if numOfSearchResults == '0':
        return json.dumps({'error':'try again'})
    else:
        searchResults = soup.find_all('h1')
        searchResultList = []
        for i in searchResults:
            if i.a.get('href'):
                searchResultList.append(str(i.a.get('href')))

        # medicationURL = searchResultList[0]
        medicationURL = searchResultList[0]

        request1 = urllib2.urlopen(medicationURL)
        result1 = request1.read()
        soup1 = BeautifulSoup(result1, 'html.parser')

        if not soup1.find('section', class_='drug-monograph-section'):
            if 'alka' in medication:
                return json.dumps({'instructions': "Fully chew then swallow 1-2 chewable tablets as symptoms occur. Do not take more than 5 chewable tablets in a 24-hour period", "maximum": 5})
            else:
                return json.dumps({'error':'try again'})

        sections = soup1.find('section', class_='drug-monograph-section')
        headings = sections.find_all('h2')
        paragraphs = sections.find_all('p')

        pIndex = 0
        medicationInfo = {}
        newHTML = ""
        for i in headings:
            h2 = i.get_text()
            if h2 in dosageHeadings:
                #p = paragraphs[pIndex]
                p = i.find_next("p")
                pText = p.get_text()
                h2 = h2.strip(':')
                #print (h2 + " " + p.get_text())
                #medicationInfo.append(h2 + " " + p.get_text())
                #medicationInfo[h2.strip(':')] = pText
                medicationInfo['instructions'] = pText
                medicationInfo['maximum'] = findMax(pText)
                # if 'once daily' in pText:
                #     medicationInfo[h2.strip(':') + " dosage"] += "once daily"
                # elif 'every ' and ' hours' in pText:
                #     medicationInfo[h2.strip(':')]
                #newHTML = newHTML + str(i) + str(p)
            #if 'How Supplied' in h2:
                #medicationInfo['mg per pill'] = paragraphs[pIndex].get_text()
                # pillSize = re.search('(?:\d+\.)?\d+mg', i.find_next("p").get_text())
                # if pillSize != '':
                #     medicationInfo['mg per pill'] = pillSize.group(0)
                  
            # medicationInfo['mg per pill regex'] = re.search(r'(?:\d*\.)?\d+mg', paragraphs[pIndex].get_text()).group()
            pIndex += 1

    #return newHTML
    #frequency, max, num of mg per pill
    return json.dumps(medicationInfo)

@app.route("/logo/<medication>")
def getLogo(medication):
    url = "https://api.cognitive.microsoft.com/bing/v5.0/images/search"
    medication += " logos"
    payload = {'q': str(medication)}
    headers = {'Ocp-Apim-Subscription-Key': 'c27264578ba449bcbca148baa3466b9e'}
    r = requests.get(url, params=payload, headers=headers).json()
    imgURL = r['value'][0]['contentUrl']
    imgURLJSON = {'url': imgURL}
    return json.dumps(imgURLJSON)

# Returns an integer number of pills needed daily given json input
def findMax(text):
    if 'once daily' in text or 'once a day' in text or 'one a day' in text or 'one time a day' in text or '1 a day' in text:
        #return "once a day"
        return 1
    if 'twice daily' in text or 'twice a day' in text or 'two a day' in text or 'two times a day' in text or '2 a day' in text:
        # return "twice a day"
        return 2
    if re.search(r'every \d hours for \d doses', text, re.I|re.M) is not None:
        return int(re.search(r'every \d hours for \d doses', text, re.I|re.M).group()[-7])
    if re.search(r'every \d hours for \d\d doses', text, re.I|re.M) is not None:
        return int(re.search(r'every \d hours for \d\d doses', text, re.I|re.M).group()[-8:-6])
    if re.search(r'max \d\d', text, re.I|re.M) is not None:
        num = int(re.search(r'max \d\d', text, re.I|re.M).group()[4:6])
        return int(round(num/0.5))
    if re.search(r'max \d dose', text, re.I|re.M) is not None or re.search(r'max \d tab', text, re.I|re.M) is not None:
        return int(re.search(r'max \d', text, re.I|re.M).group()[4])
    if re.search(r'max \d', text, re.I|re.M) is not None:
        num = int(re.search(r'max \d', text, re.I|re.M).group()[4])
        return int(round(num/0.3))
    if re.search(r'max: \d', text, re.I|re.M) is not None:
        return int(re.search(r'max: \d', text, re.I|re.M).group()[5])
    if re.search(r'every \d hours', text, re.I|re.M) is not None:
        num = int(re.search(r'every \d hours', text, re.I|re.M).group()[6])
        return int(round(24/num))
    if re.search(r'every \d\d hours', text, re.I|re.M) is not None:
        num = int(re.search(r'every \d\d hours', text, re.I|re.M).group()[6:8])
        return int(round(24/num))
    return 1
