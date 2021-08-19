<!-- DO NOT REMOVE - contributor_list:data:start:["m1dnight", "joshproehl", "dependabot[bot]"]:end -->
# ExBin

A pastebin clone written in Phoenix/Elixir. Live [here](https://exbin.call-cc.be). 

I work on this project from time to time, so the development pace is slow. If you want to dive in, feel free. The codebase is relatively small because, well, it's a simple application.

## Features

 * Post pastes publicly and privately 
 * Opt-in ephemeral snippets. Ephemeral snippets get deleted after 24 hours.
 * Views are only incremented once every 24 hours, per client.
 * Usage statistics.
 * List of all public pastes 
 * Use `nc` to pipe text and get back the URL. 
   (e.g., `cat file.txt | nc exbin.call-cc.be 9999`)
 * "Raw View" where text is presented as is. Well suited for copy/pasting.
 * "Reader View" where text is presented in a more readable manner. Well suited to share prose text.
 * "Code View", showing snippets with syntax highlighting.

# Installation 

The easiest way to run your own instance of ExBin is by running it in a Docker container.

| Environment var     | Description                                                                                | Default  |
|---------------------|--------------------------------------------------------------------------------------------|----------|
| `SECRET_KEY_BASE`   | Secret hash to encrypt traffic. Generate with `mix phx.gen.secret`.                        | Required |
| `SECRET_SALT`       | Secret hash to encrypt traffic. Generate with `mix phx.gen.secret`.                        | Required |
| `DATABASE_HOST`     | Host for database.                                                                         | Required |
| `DATABASE_DB`       | Name of the database.                                                                      | Required |
| `DATABASE_USER`     | Username for Postgres instance.                                                            | Required |
| `DATABASE_PASSWORD` | Password for Postgres user.                                                                | Required |
| `POOL_SIZE`         | Concurrent database connections.                                                           | `10`     |
| `TZ`                | TZ database name                                                                           | Required |
| `EPHEMERAL_AGE`     | Ephemeral age of snippets in minutes.                                                      | `60`     |
| `HTTP_PORT`         | Port for HTTP endpoint.                                                                    | `4000`   |
| `TCP_PORT`          | Port for the TCP endpoint.                                                                 | Required |
| `TCP_HOST`          | IP to bind on for TCP socket.                                                              | Required |
| `MAX_SIZE`          | Maximum size in bytes for the TCP endpoint.                                                | Required |
| `DEFAULT_VIEW`      | Standard view for snippets. (Supported values are 'code', 'reader', or 'raw')              | Required |
| `BASE_URL`          | Base URL for this instance. Necessary behind a reverse proxy. E.g., `https://example.com`. | Required |
| `HOST`              | Hostname for this instance. E.g., `example.com`.                                           | Required |
| `API_KEY`           | Password token for the API. If not set, the API is publicly available.                     | Optional |
| `BRAND`             | Name of the ExBin instance. Shown in bottom right corner when creating a snippet.          | `ExBin`  |

Create an .env file and give a value to all these environment variables. You can leave the ones with default values as is, if you want.
An example is shown below.

```
SECRET_KEY_BASE=TUvAjMKpIXf+ik05cgmjErbtWVUBmKX70TCtg9ToU3ZC8gdNQoYnCrLAljBuHvKU 
SECRET_SALT=Qrw8mzDAAdvouNi6EvP/vEBwgPw0lCXh2dCANXKbW0HnQElvhB8nETC/q/L+zxxa 
DATABASE_HOST=db 
DATABASE_DB=exbin
DATABASE_USER=postgres
DATABASE_PASSWORD=postgres 
POOL_SIZE=10 
TZ=Europe/Brussels 
EPHEMERAL_AGE=60
HTTP_PORT=5000
TCP_PORT=9999
TCP_HOST=0.0.0.0
MAX_SIZE=2048
DEFAULT_VIEW=code 
BASE_URL=https://example.com
HOST=example.com 
DATABASE_DATA=/tmp/exbindata
API_KEY=mysupersecretkey
BRAND=ExBin
```

Copy the `docker-compose.yaml` file, and change accordingly. Finally, run it with `docker-compose up`.

## Custom Branding in Docker 

To create a custom logo when you use Docker do the following. Let's assume your logo is located on your host at `/path/my_logo.png`. 
Additionally, the version of ExBin you are running is 0.1.3 (you can see this on the about page).
To overwrite the logo, mount your file as a volume at `/app/lib/exbin-0.1.3/priv/static/images/logo.png`. 
This will overwrite the logo with your own.

# Things To Do 

 * Empty snippets are not allowed, but if you use some unprintable chars it still passes. 
 * Synced paged back or not? 
 * Rate limit the amount of pastes a user can make.
 * Admin page
 * Custom logos
 * Nicer warnings/checks on environment variables instead of crashing immediately.
 * Check older issues to see what I missed
 * Allow a unique user (reuse from rate limiting) to delete a snippet in the next x minutes, or create a unique delete link or something.
 * Maybe use a list to filter out snippets that might contain bad words. Instead of disallowing them, we could drop them from the public list. 


<!-- prettier-ignore-start -->
<!-- DO NOT REMOVE - contributor_list:start -->
## 👥 Contributors


- **[@m1dnight](https://github.com/m1dnight)**

- **[@joshproehl](https://github.com/joshproehl)**

- **[@dependabot[bot]](https://github.com/apps/dependabot)**

<!-- DO NOT REMOVE - contributor_list:end -->
<!-- prettier-ignore-end -->
