#Resources: 
#
# Fetch-one: https://dev.mysql.com/doc/connector-python/en/connector-python-api-mysqlcursor-fetchone.html 

#Google Calender API: https://developers.google.com/calendar/api/quickstart/python 

#Open AI API: https://platform.openai.com/docs/quickstart 

#fetchall : https://dev.mysql.com/doc/connector-python/en/connector-python-api-mysqlcursor-fetchall.html


#Please run this file in enev. USing source, and then export the openai key so that openai can be accessed and then run it by typing python server.py.
# I decided to add everything to this file because it was easier and having too many files created unnecessary problems for me that I did not want to deal with.

#all the necesary imports to run the app smoothly.

import datetime
import os.path

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from flask import Flask, jsonify, json, request
from flask_cors import CORS
import pymysql
from dotenv import load_dotenv
load_dotenv()
import os 
# from tryingparser import parsepdf
# from testopenai import parsepdf

# or import tryingparser

#for ai
import os
from openai import OpenAI

app = Flask(__name__)
CORS(app) 

conn = pymysql.connect(host=os.getenv("hostt"), user=os.getenv("userz"), password= os.getenv("pw"), database=os.getenv("d_base"))






crsr = conn.cursor()
#neede for google calender API
SCOPES = ['https://www.googleapis.com/auth/calendar']


#takes in a string, parses it and sends it to another function that creates an event in google calender.
def testerz(container):
    events = container.split("\n")

    # print(f"printing event: {events}")
    for event in events:
        # print (event)
        divided = event.split(",")
        # print (divided)
        # print(f"\nprinting Lengthss {len(divided)}")
        if len(divided) == 4 :
            coursename = divided[0]+divided [1]
            asignmentname = divided[1]
            sdate = divided[2]
            edate = divided[3]
            # print(f"\ngoing into main {coursename}, {asignmentname}, {sdate}, {edate}")
            sendtogc(coursename,asignmentname,sdate,edate)
            # print("\nafter main")



#functionized the google calender API call
def sendtogc(summary,description,startdate,endate ):
    """Shows basic usage of the Google Calendar API.
    Prints the start and name of the next 10 events on the user's calendar.
    """
    summary = summary.strip()
    description = description.strip()
    startdate = startdate.strip()
    endate =  endate.strip()
    # print(summary)
    # print(description)
    # print(startdate)
    # print(endate)

    creds = None
    if os.path.exists("token.json"):
        creds = Credentials.from_authorized_user_file("token.json", SCOPES)

    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                "credentials.json", SCOPES
            )
            creds = flow.run_local_server(port=0)
        with open("token.json", "w") as token:
            token.write(creds.to_json())

    try:
        #api callz?
        service = build("calendar", "v3", credentials=creds)

        #creating an event
        event = {
            'summary': summary,
            # 'location': 'Spokane, WA',
            'description': description,
            'start': {
                # 'dateTime': '2025-01-23T09:00:00-07:00',
                'dateTime': startdate,
                'timeZone': 'America/Los_Angeles',
            },
            'end': {
                # 'dateTime': '2025-01-23T17:00:00-07:00',
                'dateTime' : endate,
                'timeZone': 'America/Los_Angeles',
            },
            #do not need these for now
            # 'recurrence': [
            #     'RRULE:FREQ=DAILY;COUNT=2'
            # ],
            # 'attendees': [
            #     {'email': 'lpage@example.com'},
            #     {'email': 'sbrin@example.com'},
            # ],
            # 'reminders': {
            #     'useDefault': False,
            #     'overrides': [
            #         {'method': 'email', 'minutes': 24 * 60},
            #         {'method': 'popup', 'minutes': 10},
            #     ],
            # },
        }

        #create the event
        event = service.events().insert(calendarId='primary', body=event).execute()

        #this was already here, useful for debugging
        print('Event created: %s' % (event.get('htmlLink')))

      
        now = datetime.datetime.utcnow().isoformat() + "Z"  
        print("Getting the upcoming 10 events")

        events_result = (
            service.events()
            .list(
                calendarId="primary",
                timeMin=now,
                maxResults=10,
                singleEvents=True,
                orderBy="startTime",
            )
            .execute()
        )
        events = events_result.get("items", [])

        if not events:
            print("No upcoming events found.")
            return

        #prints the next 10 events from the google calender
        for event in events:
            start = event["start"].get("dateTime", event["start"].get("date"))
            print(start, event["summary"])

    except HttpError as error:
        print(f"An error occurred: {error}")





#to store the content from the pdf in a string.
newstorage = " "
#to access AI
client = OpenAI()

# Test API
@app.route('/')
def index():
    return 'hi World'

#link it to flutter#done

#gets the user || testing GET request
@app.route('/test1' ,methods= ['GET'])
def yil():
   
    sql = "SELECT * FROM `User` WHERE `User_id` = 1;"

    crsr.execute(sql)

    rows = crsr.fetchall()

    storage_list= []

    for row in rows:
        storage = {
            'user_id': row[0],
            'username':row[1],
            'email':row[2]
        }
        storage_list.append(storage)

    return jsonify(storage_list)

#another method if you know you only need to return one row:
#rows = crsr.fetchone()
#user_id = row[0]  # First column value (e.g., username)
# username = row[1] 
# 'email':row[2]
# return jsonify({'user_id': user_id, 'username' : username, 'email': email})


#testing POST request 
@app.route('/posting' , methods= ['POST'])
def yupp():

    json = request.get_json()
    user_id = json['userid']

    sql = "SELECT `Course_name` FROM `Courses`"
    sql+= "WHERE `User_id` = %s;"

    crsr.execute(sql, (user_id))

    print("Current user id:${user_id}")

    rowz = crsr.fetchone()

    course_name = rowz[0]

    return jsonify({'coursename' : course_name})

    # storage_list2= []

    # for rowf in rowz:
    #     storage = {
    #         'user_id': rowf[0],
    #         'username':rowf[1],
    #         'email':rowf[2]
    #     }
    
    # storage_list2.append(storage)
    
    
    # user_id = row[0]
    # course_name = row[1]
   
    

#to check if the username and password matches.
@app.route('/checkuserdetails' , methods =['POST'])
def checkuser():
    
    try:
        json = request.get_json()
        username = json['username']
        password = json['password']

        # if notfrom: https://www.geeksforgeeks.org/python-if-with-not-operator/
        if not username or not password:
            return jsonify({'error': 'Username and password are required'}), 400


        sql = "SELECT `User_id` FROM `User`"
        sql+= "WHERE `User_name` = %s AND `password` = %s;"

        crsr.execute(sql, (username, password))
    
        rowz = crsr.fetchone()
        uid = rowz[0]
        #return the user id if match is found
        return jsonify({'userid' : uid})
   
    except Exception as e:
        #return the eroor
        return jsonify({'error': str(e)}), 500

#to let the user insert their dertails into the db
@app.route('/enteruserdetail', methods=['POST'])
def getuserin():
    #getting json data from the user
    json = request.get_json()
    username = json['username']
    password = json['password']
    email = json['email']

    sql= "INSERT INTO `User` (`User_name`,`email` ,`password`)"
    sql += "VALUES (%s, %s,%s);"
    crsr.execute(sql, (username,email,password))

    return jsonify({'update' : 'User has been entered into the database'})

#Getting a string from the extracted pdf and parsing it using AI and
#sending it to the calender
@app.route('/postingcontent', methods=['POST'])
def yeehaa():
    #get JSON data from the request
    json = request.get_json()
    content = json['content']

    #update string with data 
    newstorage = content
    print(f"newstorage updated to: {newstorage}")

    #try to make the call. Used to catch errors
    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",  # Ensure this is a valid model
            messages=[
                {"role": "system", "content": "content"},
                {
                    "role": "user",
                    #the prompt for the command
                    # "content": f"Tell me the name of all the assignment and what day it is due from: {newstorage}",
                     "content": f"Can you please only tell me the details of all the assignment in this comma seperated value format: coursename + assignment name, assignment name, the date is it due in the format 'YYYY-MM-DD'+T22:00:00, and finally the date again 'YYYY-MM-DD'+ T23:59:00  from: {newstorage}",
                },
            ],
        )
        
        #getting the content from API response
        assignments = response.choices[0].message.content

        assignments.strip()
        print(assignments)

        #########
        ###need to work on seperating data and putting them in a list?
        ## and then using the function sendtogc to send them to the calender?
        ##read docs: http://platform.openai.com/docs/guides/prompt-engineering 
        ##
        #####################
        testerz(assignments)
        # events = assignments.split("\n")
        
        # for event in events:
        #  print (event)
        #  events = event.split(",")
        # if len(events) == 4 :
        #     coursename = events[0]
        #     assignmentname = events[1]
        #     sdate = events[2]
        #     edate = events[3]

        #     print(f"We have the data {coursename}, {assignmentname},{sdate}, {edate}")
            # sendtogc(coursename,assignmentname,sdate,edate)
    except Exception as e:
        print(f"Error: {e}")

    
    return jsonify({'content': content})

#testing
# sendtogc('CS270-LM1','LM1', '2025-01-23T22:00:00','2025-01-23T23:59:00')



if __name__ == '__main__':
    app.run(debug=True)

