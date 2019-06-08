# Modal app

Sinatra app to upload pictures and display them according to get request. Images run in a slideshow and change every 15 seconds.
Webpage refreshes every 20 minutes.
## Example:
 Display all images for screen 3
 - www.example.com/display/3 

# App Deployment
- Images are saved to a aws s3 bucket
- Edit and rename .env.example to .env
- Edit and rename database.yml.example to database.yml
- Make sure db exists
- Bundle install
- ruby app.rb or rackup to start app
- bundle exec rake to run tests

# Screen Deployment
  - Set up raspbery pi's to open browser in KIOSK mode
  - Set link in browser as www.example.com/display/x where x is the assigned display


# Tips 
 - If power failures keep corrupting the raspberry pi sd card
   Set up raspberry pi as read-only
 - https://learn.adafruit.com/read-only-raspberry-pi?view=all.
 - It could be a good idea to set up a cron job to restart pie every x amount of time. As unexpected failures can happen.
 - Watch out for conterfeit sd cards as these corrupt easily 
   and might not have the amount of memory it says it has
