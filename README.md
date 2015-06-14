# Canvas Navigation External Tool Usage

Based on scripts from my colleague, [Jason Miller](https://github.com/redconfetti) - [Notification Setter](https://github.com/redconfetti/notification_setter) and [Stat Scraper](https://github.com/redconfetti/stat_scraper), this ruby script loops through 'canvas_course_id' columns in a Canvas CSV provisioning report of courses, and connects to the [Canvas-LMS](https://github.com/instructure/canvas-lms) API for [List available tabs for a course or group](https://canvas.instructure.com/doc/api/tabs.html) to report information about all external tools for each site in the report.

# Usage

## First Time Use

The first time you use this script, you will need to install required gems using Bundler.

	$ bundle install

Next you will need to copy the contents of config.example.yml into a new file named config.yml.

```bash
$ cp config.example.yml config.yml
```

To properly authenticate with the
Canvas LMS system you are using this script with, you'll need to [generate an API access token](https://guides.instructure.com/m/4214/l/40399-how-do-i-obtain-an-api-access-token) for your user account and then insert that token into the 'config.yml' file as the 'admin_token'.

## Providing CSV Report

This script will work with any list of canvas course ids that the user is authorized to access.  Ideally, you can use a provisioning report for courses which will result in a file that includes the 'canvas_course_id'.

## Admin User access

This script is really intended for Canvas Admins.

## Run the primary script

From the command line simply run the 'main.rb' script.

	$ ./main.rb
