# Lightweight Docker Setup for NodeJS Development
A starter Docker setup for NodeJS development with Nginx and MariaDB.

## How to Get Started?
First you'll have to clone this repo as you naturally would. After cloning the
repo build the images. There is `Makefile` included with simple rules. See the
whole list of commands below:

* `make build`  build the images
* `make up`     start the docker environment
* `make down`   stop the docker environment
* `make node`   enter Node container interactive mode
* `make init`   this is only used when you add your project code as a submodule
    and push this environment to a repo then clone it on another machine. It'll
    build the images, pull the changes and add your project as a submodule.
* `make cleanup` only meant for fixing if something went wrong with `make init`
    command so you'll be able to run `make init` again right away.

After the images are built you've two options to proceed:
1. Create a project directory for example `app` in root and start coding there.
2. Clone your project repo into `app` as a submodule.

### Option 1
The first option is very straight forward and simple you clone the repo, create
a directory like `app`, make the code become part of the whole and push
everything to a repo as one single project. This will include the whole docker
stuff and your code.

As this environment only meant for development you might wanna consider the
second option.

### Option 2
This is more of a clean option to keep your code separate from the whole docker
stuff. After cloning the repo add your project as a submodule into the `app`
directory like following:

```bash
git submodule add git@github.com:containershub/<your-app-repo>.git app
```

After cloning your app repository run `make up` to start docker up and running
or `make build` if you haven't yet build the images. Next test the following
things to make sure everything is ready and all services work as they should.

* Run `make node` and install NPM packages to verify both NodeJS service and
    NPM are working.
* Visit `nodeapp.test` (don't forget to add `nodeapp.test` to your hosts!).
* Access `adminer` at `nodeapp.test:8080`.
* Access `mailpit` at `nodeapp.test:8025`

After successfully testing everything you can now start with your own project.
However you've to first remove the old submodule otherwise it'll not allow you
to add your project as a submodule into app directory. To do that run the
following commands after another:

```bash
# 1. Remove the submodule entry from .git/config
git submodule deinit -f app

# 2. Remove the submodule directory from the working tree and Git index
git rm -f app

# 3. Remove the old submodule's internal git metadata
rm -rf .git/modules/app
```

Now you can add your project and start working!

```bash
git submodule add git@github.com:<Your-Project>.git app
```


## Requirements Handling Full-Stack Routing
This is the part where conflicts can occure between Nginx, Vite etc. For
simplicity we've to leave Nginx pointing only to port `3000` (`http://node:3000`)
and access Vite directly via port `5173`.

### Requirements For Vite
* **Frontend URL**: `http//nodeapp.test:5173` (Vite dev server)
* **Backend URL**: `http//nodeapp.test:` (Nginx -> port `3000`)
* **Requirements**: In your app's `vite.config.js`, set `server: { host: true }`
    (or `0.0.0.0`) so Vite accepts connections from outside the container, and
    configure Vite's `server.proxy` to forward `/api` requests to
    `http://localhost:3000`.
* **Advantage**: Nginx's `default.conf` stays generic and works for any Node.js
    project (API-only, SSR frameworks like Next.js/Nuxt on port `3000`, or
    Vite + Express).

### Requirements For Grunt LiveReload (grunt-contrib-watch)
* **Frontend URL**: `http//nodeapp.test:35729` (Grunt dev server)
* **Backend URL**: `http//nodeapp.test:` (Nginx -> port `3000`)
* **Requirements**: For Grunt LiveReload we expose port `35729`. For that to
    work we have enable LiveReload in `Gruntfile.js`. Set `livereload: true`
    inside your `watch` task options. By default, `grunt-contrib-watch` binds
    its LiveReload server to `0.0.0.0:35729`, so Docker will forward it
    automatically without extra host flags.
    * Also make sure your HTML layout includes `<script src="http://nodeapp.test"></script>`
    during development (or use a browser LiveReload extension) so the browser
    connects to the exposed port.
    * If you also want to access via localhost you can make it work automatically on
    both `nodeapp.test` and `localhost` by reading `location.hostname`
    dynamically:
        ```html
        <script>
          document.write('<script src="http://' + (location.hostname || 'localhost') + ':35729/livereload.js"></' + 'script>');
        </script>
        ```

:ytk
