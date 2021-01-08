import datetime as dt
from dateutil.tz import gettz
today = dt.date.today()
todayts = dt.datetime.now()

print(today, todayts)
print(today)
print(today.year)
print(today.month)
print(today.day)
last = dt.date(2020, 4, 1)

new_years_day = dt.date(2019, 1, 1)
memorial_day = dt.date(2019, 5, 27)
days_between = memorial_day - new_years_day
print(days_between)
duration = dt.timedelta(days=146)
print(new_years_day + duration)
print(memorial_day - duration)
start_time = dt.datetime(2019, 3, 31, 8, 0, 0)
finish_time = dt.datetime(2019, 3, 31, 14, 34, 45)
time_between = finish_time - start_time
print(time_between)
print(type(time_between))

birthdate = dt.date(2005, 11, 29)
delta_age = today - birthdate
print(delta_age, type(delta_age))
# pull out days from time delta and store as integer
days_old = delta_age.days
years_old = days_old // 365
print(years_old)
months = (days_old % 365) // 30
print(f"You are {years_old} yeas and {months} months old.")

utc_now = dt.datetime.utcnow()
time_difference = utc_now - todayts
print(f"My time       : {todayts: %I:%M %p}")
print(f"UTC time      : {utc_now: %I:%M %p}")
print(f"Difference    : {time_difference}")

# UTC time right now
utc = dt.datetime.now(gettz('Etc/UTC'))
print(f"{utc:%A %D %I %M %p %Z}")
# Eastern
est = dt.datetime.now(gettz('America/New_York'))
print(f"{est:%A %D %I %M %p %Z}")
# Central
cst = dt.datetime.now(gettz('Ameica/Chicago'))
print(f"{cst:%A %D %I %M %p %Z}")
# Mountain
mst = dt.datetime.now(gettz('America/Boise'))
print(f"{mst:%A %D %I %M %p %Z}")
# PST
pst = dt.datetime.now(gettz('America/Los_Angeles'))
print(f"{pst:%A %D %I %M %p %Z}")

event = dt.datetime(2020, 7, 4, 19, 0, 0)
# local date time
print("Local: " + f"{event:%D %I %M %p %Z}" + "\n")
event_eastern = event.astimezone(gettz("America/New_York"))
print(f"{event_eastern:%D %I %M %p %Z}")

import datetime as dt
dates = [dt.date(2020,12,31), dt.date(2019,1,31), dt.date(2018,2,28), dt.date(2020,1,1)]

# more readable
datelist = []
datelist.append(dt.date(2020, 12, 31))
datelist.append(dt.date(2019, 1, 31))
datelist.append(dt.date(2018, 2, 28))
datelist.append(dt.date(2020, 1, 1))

datelist.sort(reverse = True)
for date in datelist:
    print(f"{date:%m/%d/%Y}")



