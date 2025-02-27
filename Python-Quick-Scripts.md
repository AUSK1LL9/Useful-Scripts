1. Email Organizer
This script automatically sorts incoming emails into folders based on predefined rules. Using the imaplib and email libraries, it’s perfect for clearing cluttered inboxes.

Features:
Organizes newsletters, work emails, and personal messages.
Deletes spam or low-priority emails instantly.
Code Example:

import imaplib
import email

mail = imaplib.IMAP4_SSL("imap.gmail.com")
mail.login("your_email@gmail.com", "your_password")
mail.select("inbox")
status, messages = mail.search(None, 'FROM "newsletter@example.com"')

for num in messages[0].split():
    mail.store(num, '+X-GM-LABELS', 'Newsletters')  # Labels email
    mail.store(num, '+FLAGS', '\\Deleted')  # Marks as deleted
mail.expunge()
mail.logout()
Why I Use It:
This script declutters my inbox and ensures I never miss important work emails.

10 Python Scripts to Automate Your Daily Tasks
Discover 10 powerful Python scripts to automate daily tasks like emails, file organization, backups, and more.
medium.com

2. File Renamer
A lifesaver when dealing with messy file names! This script renames files in bulk based on patterns or extensions using the os module.

Features:
Adds prefixes, suffixes, or numbers to file names.
Works on specific file types, like .jpg or .txt.
Code Example:

import os

directory = "C:/example_folder"
for count, filename in enumerate(os.listdir(directory)):
    if filename.endswith(".jpg"):
        new_name = f"image_{count + 1}.jpg"
        os.rename(os.path.join(directory, filename), os.path.join(directory, new_name))
Why I Use It:
Perfect for renaming photos, downloaded files, or reports in seconds.

3. Web Scraper
Using libraries like BeautifulSoup and requests, this script extracts useful data from websites, such as product prices, articles, or news updates.

Features:
Extracts product prices, headlines, or article content.
Saves data into structured formats like CSV or JSON.
Code Example:

import requests
from bs4 import BeautifulSoup

url = "https://example.com"
response = requests.get(url)
soup = BeautifulSoup(response.text, 'html.parser')

headlines = [h2.text for h2 in soup.find_all('h2')]
print(headlines)
Why I Use It:
I use this script to track competitor pricing, gather market trends, or compile news summaries.

8 Uncommon But Extremely Useful Python Libraries
Unlock new capabilities with these lesser-known but highly effective Python libraries
medium.com

4. Social Media Scheduler
This script automates posting content on platforms like Twitter and LinkedIn using APIs.

Features:
Posts scheduled content automatically.
Integrates with content calendars.
Code Example (Twitter):

import tweepy

api_key = "your_api_key"
api_secret = "your_api_secret"
access_token = "your_access_token"
access_secret = "your_access_secret"

auth = tweepy.OAuthHandler(api_key, api_secret)
auth.set_access_token(access_token, access_secret)
api = tweepy.API(auth)

api.update_status("Automated Tweet: Hello, world!")
Why I Use It:
This keeps my social media presence consistent while focusing on other tasks.

5. PDF to Excel Converter
Combining PyPDF2 and pandas, this script extracts tabular data from PDFs and converts it into structured Excel files.

Features:
Extracts tables and saves them as Excel files.
Handles multi-page PDFs.
Code Example:

import PyPDF2
import pandas as pd

pdf_file = "example.pdf"
reader = PyPDF2.PdfReader(pdf_file)
data = []

for page in reader.pages:
    text = page.extract_text()
    data.append(text.splitlines())

df = pd.DataFrame(data)
df.to_excel("output.xlsx", index=False)
Why I Use It:
I use it for converting invoices, reports, and financial documents into editable formats.

6. Automatic Backups
With shutil and os, this script creates daily backups of critical files and folders to an external drive or cloud storage.

Features:
Creates scheduled backups.
Maintains directory structure.
Code Example:

import shutil
import os

source = "C:/important_files"
destination = "D:/backup_files"
shutil.copytree(source, destination, dirs_exist_ok=True)
Why I Use It:
This ensures my critical work is always safe, even during unexpected failures.

7. API Data Fetcher
This script connects to APIs, retrieves data, and stores it for analysis. For example, it fetches weather data using the OpenWeatherMap API.

Code Example:

import requests

api_url = "https://api.openweathermap.org/data/2.5/weather"
params = {"q": "New York", "appid": "your_api_key", "units": "metric"}

response = requests.get(api_url, params=params)
data = response.json()

if response.status_code == 200:
    print(f"Temperature in New York: {data['main']['temp']}°C")
else:
    print("Failed to fetch data.")
Why I Use It:

Monitors real-time metrics for projects.
Provides instant access to external data without opening a browser.
8. Data Cleaning Tool
A robust script leveraging pandas to clean and preprocess datasets by removing duplicates, handling missing values, and normalizing data.

Code Example:

import pandas as pd

df = pd.read_csv("raw_data.csv")
cleaned_df = df.drop_duplicates().fillna("Unknown")

print("Data cleaned!")
cleaned_df.to_csv("cleaned_data.csv", index=False)
Why I Use It:

Prepares raw data for analysis in seconds.
Eliminates manual effort in cleaning datasets.
9. Web Monitor
This script checks websites for changes, such as updates to specific pages or availability of items, and sends alerts.

Code Example:

import requests
import time

websites = ["https://google.com", "https://example.com"]
for site in websites:
    try:
        start = time.time()
        response = requests.get(site)
        elapsed = time.time() - start
        print(f"{site} is online. Response time: {elapsed:.2f} seconds.")
    except requests.RequestException:
        print(f"{site} is offline.")
Why I Use It:

Tracks product restocks.
Keeps tabs on website updates without constant refreshing.
10. Password Generator
A script that generates strong, unique passwords using the random module.

Code Example:

import random
import string

def generate_password(length=12):
    characters = string.ascii_letters + string.digits + string.punctuation
    return ''.join(random.choice(characters) for _ in range(length))

print(f"Generated Password: {generate_password(16)}")
Why I Use It:

Ensures account security.
Saves time thinking of creative passwords.
11. Expense Tracker
This script logs daily expenses into a CSV file and provides summaries at the end of the month.

Code Example:

import csv

expenses = [{"Date": "2025-01-12", "Item": "Coffee", "Amount": 5},
            {"Date": "2025-01-12", "Item": "Groceries", "Amount": 50}]

with open("expenses.csv", "w", newline='') as file:
    writer = csv.DictWriter(file, fieldnames=["Date", "Item", "Amount"])
    writer.writeheader()
    writer.writerows(expenses)

print("Expenses logged successfully!")
Why I Use It:

Keeps finances under control.
Visualizes spending habits using charts.
12. To-Do List Manager
A CLI-based script that creates, updates, and tracks tasks for the day.

Code Example:

tasks = []

def show_tasks():
    for i, task in enumerate(tasks, 1):
        print(f"{i}. {task}")

def add_task(task):
    tasks.append(task)
    print("Task added!")

add_task("Complete Python project")
show_tasks()
Why I Use It:

Keeps me organized without relying on apps.
Customizable for personal productivity workflows.
10 Python Scripts to Automate Your Daily Tasks
Discover 10 powerful Python scripts to automate daily tasks like emails, file organization, backups, and more.
medium.com

13. Text Summarizer
Using spaCy or transformers, this script summarizes lengthy articles or PDFs into concise bullet points.

Code Example:

from transformers import pipeline

summarizer = pipeline("summarization")
text = """Python is an incredibly versatile programming language..."""
summary = summarizer(text, max_length=50, min_length=25, do_sample=False)
print(summary[0]['summary_text'])
Why I Use It:

Speeds up research by extracting key insights.
Processes dense documents in seconds.
14. Stock Market Tracker
This script fetches real-time stock prices and trends using APIs like Alpha Vantage or Yahoo Finance.

Code Example:

import yfinance as yf

ticker = "AAPL"
stock = yf.Ticker(ticker)
price = stock.history(period="1d")['Close'][0]
print(f"{ticker} Current Price: {price}")
Why I Use It:

Provides instant market updates.
Tracks portfolio performance without external apps.
15. Image Resizer
A script that resizes images in bulk using Pillow.

Code Example:

from PIL import Image

image = Image.open("image.jpg")
image_resized = image.resize((800, 800))
image_resized.save("image_resized.jpg")
print("Image resized successfully!")
Why I Use It:

Optimizes images for websites or social media.
Simplifies resizing for different platforms.
16. Directory Cleaner
This script removes duplicate or temporary files from folders, freeing up storage space.

Code Example:

import os
import shutil

file_types = {
    "Images": [".jpg", ".png"],
    "Documents": [".pdf", ".docx"]
}

directory = "downloads/"

for file in os.listdir(directory):
    ext = os.path.splitext(file)[1]
    for folder, extensions in file_types.items():
        if ext in extensions:
            os.makedirs(os.path.join(directory, folder), exist_ok=True)
            shutil.move(os.path.join(directory, file), os.path.join(directory, folder))
Why I Use It:

Keeps my directories tidy.
Prevents storage bloat over time.
9 Python Debugging Tricks to Boost Your Efficiency
The Python Debugging Secret That 90% of Developers Miss
python.plainenglish.io

17. Habit Tracker
A fun project using Python to log and track habits, with visualizations powered by matplotlib.

Code Example:

habits = {"Exercise": 0, "Read": 0}

def log_habit(habit):
    habits[habit] += 1
    print(f"Logged {habit}! Total: {habits[habit]} days.")

log_habit("Exercise")
Why I Use It:

Builds consistency in daily routines.
Tracks progress visually, boosting motivation.
18. Desktop Notifications
Using plyer, this script sends desktop alerts for reminders, updates, or tasks.

Code Example:

from plyer import notification

notification.notify(
    title="Meeting Reminder",
    message="Your meeting starts in 15 minutes!",
    timeout=10
)
Why I Use It:

Ensures I never miss deadlines or meetings.
Replaces bulky reminder apps.
19. YouTube Downloader
A script powered by pytube to download YouTube videos or playlists.

Code Example:

from pytube import YouTube

url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
yt = YouTube(url)
yt.streams.get_highest_resolution().download(output_path="downloads/")
print("Video downloaded successfully!")
Why I Use It:

Downloads tutorials for offline viewing.
Automates video downloads for personal projects.
