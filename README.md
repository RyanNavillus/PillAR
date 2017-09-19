# PillAR
AR Pill tracking app


[_See Our Devpost_](https://devpost.com/software/pillar-egulwv)


[_See the full video here_](https://www.youtube.com/watch?v=EThrHxm1ga0&index=3&list=PLyC3kmCiJ2x31ZLjuB7RogEvyamrkSOo9)

![alt tag](https://raw.githubusercontent.com/Averylamp/TravelAR/master/Images/screen1.jpg)

## Inspiration

A couple weeks ago, a friend was hospitalized for taking Advil–she accidentally took 27 pills, which is nearly 5 times the maximum daily amount.  Apparently, when asked why, she responded that thats just what she always had done and how her parents have told her to take Advil.  The maximum Advil you are supposed to take is 6 per day, before it becomes a hazard to your stomach.  

#### PillAR is your personal augmented reality pill/medicine tracker.   

It can be difficult to remember when to take your medications, especially when there are countless different restrictions for each different medicine.  For people that depend on their medication to live normally, remembering and knowing when it is okay to take their medication is a difficult challenge.  Many drugs have very specific restrictions (eg. no more than one pill every 8 hours, 3 max per day, take with food or water), which can be hard to keep track of.  PillAR helps you keep track of when you take your medicine and how much you take to keep you safe by not over or under dosing.

![alt tag](https://raw.githubusercontent.com/Averylamp/TravelAR/master/Images/screen2.jpg)


We also saw a need for a medicine tracker due to the aging population and the number of people who have many different medications that they need to take.  According to health studies in the U.S., 23.1% of people take three or more medications in a 30 day period and 11.9% take 5 or more.   That is over 75 million U.S. citizens that could use PillAR to keep track of their numerous medicines.

## How we built it
We created an iOS app in Swift using ARKit. We collect data on the pill bottles from the iphone camera and passed it to the Google Vision API. From there we receive the name of drug, which our app then forwards to a Python web scraping backend that we built. This web scraper collects usage and administration information for the medications we examine, since this information is not available in any accessible api or queryable database. We then use this information in the app to keep track of pill usage and power the core functionality of the app.

## Accomplishments that we're proud of
This is our first time creating an app using Apple's ARKit. We also did a lot of research to find a suitable website to scrape medication dosage information from and then had to process that information to make it easier to understand. 

![alt tag](https://raw.githubusercontent.com/Averylamp/TravelAR/master/Images/screen3.jpg)

![alt tag](https://raw.githubusercontent.com/Averylamp/TravelAR/master/Images/screen4.jpg)

![alt tag](https://raw.githubusercontent.com/Averylamp/TravelAR/master/Images/screen5.jpg)



## What's next for PillAR
In the future, we hope to be able to get more accurate medication information for each specific bottle (such as pill size).  We would like to improve the bottle recognition capabilities, by maybe writing our own classifiers or training a data set.  We would also like to add features like notifications to remind you of good times to take pills to keep you even healthier.

