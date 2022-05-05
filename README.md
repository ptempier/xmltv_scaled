# xmltv_scaled
Update closer data more often and far away data less often

The script is currently set for tv_grab_fr_telerama and inserting into tvheadend xmltv.sock

data for current day is be updated every hour
then every 0.5 day for each day the data is further away up to 10 days

so :
today every 3h
tomorow every 12h
the day after every 24h
..
10 days away every 5 days

Every day the downloaded data is rotated to account for the fact that we downloaded it a long time ago , but still respect the update rule
Think logrotate, but data expires by getting closer, not further.

The idea is to get the most precise data for days that matter the most.
and still have an idea of what will happen in a long time.
this without overloading the server.

(tv schedules are subject to changes, you can't just download 10 days of data every 10 days)

My guess i that it's easy to do better, but i can't bother right now.
