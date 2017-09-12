# Map The Museum


This application was originally written as a one week hack by [Stef Lewandowski](http://stef.io), in conjunction with [Caper](http://wearecaper.com). It has had some modifications since the original hack, but generally only to keep dependencies up to date & improve the mobile device experience.

## Upgrading MTM

Initial indications are that upgrading Padrino to 0.12.X causes some issues. Some can be fixed following the upgrade guide, i.e. the order in which the applications are registered needs to be reversed, plus the login page path needs amending (remove the /admin).

Unfortunately though there is also an issue with Sinatra-Flash which was introduced with Padrino 0.10.X but it looks like is no longer required for 0.12.X - changing the templates to use the new way of doing flash notices isn't impossible, but will take a bit of work. The main area though is the admin area which probably wants starting from scratch again as it has changed so much since 0.10.X

## Environment variables

There are a number of environment variables which need to be set (they are all set on the running Heroku instance). To run the application locally, you will need to create a .env file where the application can pick them up.

For example:

```
RACK_ENV=development

S3_ACCESS_KEY_ID=<Put in your S3 access key>
S3_SECRET_ACCESS_KEY=<Put in your secret access key>
S3_HOST_ALIAS=<Your S3 domain alias>
S3_BUCKET=<Your S3 bucket name>

GOOGLE_ANALYTICS_CODE=<This is the UA code for analytics>
SESSION_SECRET=<Generate your own session secret using rake secret>
MAPBOX_MAP_ID=<This is your unique mapbox id, usually username.XXXXXX>

```

## Install MongoDB

```
brew update
brew install mongodb
```

## Install gems

```
bundle install
```

## Import db

```
mongorestore -d mapping_museum_development path_to_the_extracted_directory
```

## Run Padrino with WEBrick

```
bundle exec padrino s -p 3333
```

## Notes on the mobilification of the application

A media query was used to determine what the view port size was, and if it was too small, it'd show a message saying that mobile devices weren't supported. A custom set of styles was set up for mobile devices, the message removed and some functionality tweaked. This was simply done by hiding the various controls when the view is dropped to a certain size. You can see this happening by changing the size of the browser window, in, say Firefox.

### Android gotchas

The Android and mobile Chrome browsers proved to be quite a headache for the application. This was for a number of reasons

 * Older versions of Android (i.e. before 3.0) do not support SVG, the IE fallback provided here doesn't work properly either, so basically, if you're on 2.X you get a message telling you it's not supported. This is simply done by sniffing the header

 * Newer versions of Android, 4.X seem to have difficulties with polymaps -

    * Pinch and zoom events are not captured correctly, the values don't get set and consequently the map blows up as it doesn't have the co-ordinates. This was fixed by using, for Android only, a forked version of the polymaps library. The fork is on an Android-Touch branch of this [repository](https://github.com/natevw/polymaps).

    * One issue is that even when the map is covered by another div, it is the map which captures touch events rather than the overlaying div. We did a lot of experimentation to try and change this behaviour. In the end, the simplest way to stop this happening was to check in the touchmove event whether there was a visible div over the top of the map! Consequently the polymaps-android.js file is also a tweaked version from the natevw version.

## Notes on the admin suite

A new user can be created by running the Padrino console and doing a user create like this:

```
heroku run padrino console --app mtmstaging
```

Runs the console, then

```
Account.create(:email => email, :name => "Foo", :surname => "Bar", :password => password, :password_confirmation => password, :role => "admin")
```

## Other useful

When the staging stuff was set up, various environment decisions were taken in photograph.rb - the staging environment used an S3 bucket.

Currently though, staging has a copy of production and is using productions S3 environment. This may need tweaking in the future so that staging has an S3 bucket which is a copy of the production one.


