<!-- DO NOT REMOVE - contributor_list:data:start:["m1dnight", "joshproehl", "dependabot[bot]"]:end -->
# Exbin

A pastebin clone written in Phoenix/Elixir. Live [here](https://exbin.call-cc.be). 

I work on this project from time to time, so the development pace is slow. If you want to dive in, feel free. The codebase is relatively small because, well, it's a simple application.

## Features

 * Post pastes either publicly or privately 
 * Opt-in ephemeral snippets. By default these are deleted approximately 60 minutes after creation.
 * Views are only incremented once every 24 hours, per client.
 * Usage statistics.
 * List of all public pastes 
 * Use `nc` to pipe text and get back the URL. 
   (e.g., `cat file.txt | nc exbin.call-cc.be 9999`)
 * "Raw View" where text is presented as is. Well suited for copy/pasting.
 * "Reader View" where text is presented in a more readable manner. Well suited to share prose text.
 * "Code View", showing snippets with syntax highlighting.

# Installation 

The easiest way to run your own instance of Exbin is by running it in a Docker container.
Make a copy of the configuration file in `rel/overlays/config.exs`. The file contains documentation on how to fill it out. 
Mount this file in the docker container to configure your instance.


Copy the `docker-compose.yaml` file, and change accordingly. Finally, run it with `docker-compose up`.

## Initial User Account

When installing/running ExBin for the first time, a user will be created for you.
It is highly recommended that you change this user its email and password. 
Look for a line like this in the log files.

```
Created a user with email admin@exbin.call-cc.be and password ccbbf2726ac2ce3d3918
```

If there are already users present in the database no user will be created.
The logfile will show this.

```
Did not create a user because there are already registered users in the database.
```

The first user is the only admin user possible. I should probably update this in the future, but not today.
If you already have a bunch of users, you can easily change it by toggling the flag in the database.
## Custom Branding in Docker 

In order to configure this you will need to mount the file into your docker container as a volume, and then set the CUSTOM_LOGO_PATH environment variable to the full path (inside the container) that the file is mounted at.  
Here is an example of what you would add to your docker-compose.yml:
```
services:
  exbin:
    environment:
      CUSTOM_LOGO_PATH=/exbin_branding/my_cool_logo.png
      CUSTOM_LOGO_SIZE=50
    volumes:
      - /path/on/docker/host/my_logo.png:/exbin_branding/logo.png
```

Logo by default is 30x30 pixels, but you can define the size for the width/height attributes of the img tag by setting CUSTOM_LOGO_SIZE.  
Logos are assumed to be square, so the same value will be used for both height and width.  
Any layout errors that come from using sizes other than 30x30 are your problem. :-)

## JSON API

There is a JSON API available. If your install has an API key set (the `API_KEY` environment variable), it is required to post through the API. If it is not set, the API can be freely used. 
The payload of the API is JSON, and expects at least the content of the snippet.

The `api/new` endpoint expects a JSON payload with the keys `content`, `private`, and `ephemeral`. For example: 

```
{"content": "this is the content", 
 "private": true, 
 "ephemeral": false
}
```

An example request for a snippet without authentication looks like this.

```
$ curl -XPOST -H "Content-type: application/json" -d '{"content": "this is the content", "private": true, "ephemeral": false}' 'https://exbin.call-cc.be/api/new'
{"content":"this is the content","created":"2021-10-01T20:32:38.702101Z","name":"RegelatedDoublemindedness","url":"https://exbin.call-cc.be/RegelatedDoublemindedness"}
```

To use an authenticated endpoint simply add another field to the JSON payload with the token.

```
$ curl -XPOST -H "Content-type: application/json" -d '{"content": "this is the content", "private": true, "ephemeral": false, "token": "supersecret"}' 'https://exbin.call-cc.be/api/new'
{"content":"this is the content","created":"2021-10-01T20:32:38.702101Z","name":"RegelatedDoublemindedness","url":"https://exbin.call-cc.be/RegelatedDoublemindedness"}
```

A snippet can be requested by name using the `api/new` endpoint. No parameters should be given. 
An example curl request looks like this.

```
 curl 'https://exbin.call-cc.be/api/show/CoppingSuctions'
 {"content":"this is the content","created":"2022-05-06T08:40:17.769579Z","name":"CoppingSuctions","url":"https://exbin.call-cc.be/api/show/CoppingSuctions"}
```

# Things To Do 

 * Empty snippets are not allowed, but if you use some unprintable chars it still passes. 
 * Synced paged back or not? 
 * Rate limit the amount of pastes a user can make.
 * Admin page
 * Nicer warnings/checks on environment variables instead of crashing immediately.
 * Check older issues to see what I missed
 * Allow a unique user (reuse from rate limiting) to delete a snippet in the next x minutes, or create a unique delete link or something.
 * Maybe use a list to filter out snippets that might contain bad words. Instead of disallowing them, we could drop them from the public list. 
 * Write some unit tests..


<!-- prettier-ignore-start -->
<!-- DO NOT REMOVE - contributor_list:start -->
## 👥 Contributors


- **[@m1dnight](https://github.com/m1dnight)**

- **[@joshproehl](https://github.com/joshproehl)**

- **[@dependabot[bot]](https://github.com/apps/dependabot)**

<!-- DO NOT REMOVE - contributor_list:end -->
<!-- prettier-ignore-end -->
