from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.firefox.service import Service
from webdriver_manager.firefox import GeckoDriverManager
from selenium.webdriver.firefox.options import Options
import time
import re
import pandas as pd

data = [] 
def text_before(text,delimiter):
    return text.split(delimiter)[0] if delimiter in text else text
def text_after(text, delimiter):
    return text.split(delimiter, 1)[1] if delimiter in text else ""

firefox_options = Options()
#firefox_options.add_argument("--headless")  # if you don't want to open a window
firefox_options.add_argument("--disable-gpu")

driver = webdriver.Firefox(service=Service(GeckoDriverManager().install()), options=firefox_options)

channel_url = 'https://www.youtube.com/@uzhch/videos'
driver.get(channel_url)
time.sleep(5)

## accept all cookies
try:
    accept_button = driver.find_element(By.XPATH, "/html/body/c-wiz/div/div/div/div[2]/div[1]/div[3]/div[1]/form[2]/div/div/button/span")
    accept_button.click()
    print("Cookies accepted.")
except Exception as e:
    print(f"Could not accept cookies: {e}")

time.sleep(5)

start_height = driver.execute_script("return document.documentElement.scrollHeight")
print(start_height)
max_attempts = 100
attempt = 0

while attempt < max_attempts:    
    html = driver.find_element(By.TAG_NAME, 'html')
    html.send_keys(Keys.END)
    time.sleep(3)
    new_height = driver.execute_script("return document.documentElement.scrollHeight")
    print(new_height)
    if new_height == start_height:
        break
    else: 
        start_height = new_height

    attempt+=1

links = driver.find_elements(By.CSS_SELECTOR, "a#video-title-link")
aria_labels = [link.get_attribute("aria-label") for link in links]
for label in aria_labels:
    print(label)

    title = text_before(label,"by Universität Zürich")
    print(title)
    
    views = text_after(label,"by Universität Zürich")
    views = text_before(views," views ")
    print(views)
    
    date = text_after(label, views+" views ")
    date = text_before(date," ago ")
    print(date)
    
    duration = text_after(label,date+" ago ")
    print(duration)

    data.append([title, views, date, duration])

df = pd.DataFrame(data, columns=["Title", "Views", "Date", "Duration"])
df.to_csv("youtube_data.csv",index=False,quoting=1,sep=";",encoding="utf-8")
