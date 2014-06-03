bluemix-car-rally-charge-coupon
================================================================================

Implements the Electric Car Rally demo for BlueMix.

tl;dr
================================================================================

    git clone https://github.com/CodenameBlueMix/bluemix-car-rally-charge-coupon.git
    cd bluemix-car-rally-charge-coupon
    make install

installation
================================================================================

To run the program, you'll need [node.js installed](http://nodejs.org/).  The
source repository is available via `git`, so you may need to
[install `git`](http://git-scm.com/book/en/Getting-Started-Installing-Git).
Mac OS X users can also get `git` via Xcode,
[but beware](http://stackoverflow.com/questions/5364340/does-xcode-4-install-git).

From a command/shell terminal:

* `cd` into the parent directory you want to install the project in
* `git clone` the project into a child directory
* `cd` into that child directory
* `npm install` to install dependencies

For example:

    $ cd Projects
    $ git clone [INSERT GIT REPO HERE]

        ... git output here ...

    $ cd bluemix-car-rally

    $ npm install

        ... npm output here ...



running locally
================================================================================

To run the app locally, you will first need to have a CouchDB server running
locally.

You can install a CouchDB server locally, from
[Apache CouchDB](http://couchdb.apache.org/).

After installing CouchDB locally, and installing the app via the directions
above, you can run it with the command:

    node server

You should see something similar to the following output written to the console:

    bluemix-car-rally: using database:  http://127.0.0.1:5984/car-rally
    bluemix-car-rally: initializing database
    bluemix-car-rally: - creating database (if it doesn't already exist)
    bluemix-car-rally: - database already exists
    bluemix-car-rally: - listing all the documents
    bluemix-car-rally: - deleting existing documents
    bluemix-car-rally: - database is now empty
    bluemix-car-rally: - inserting design documents
    bluemix-car-rally: - inserting sample data
    bluemix-car-rally: - database initialization complete
    bluemix-car-rally: server starting: http://localhost:6029
    bluemix-car-rally: server started


You can use the URL listed on one of the last lines to access the application.
It stores the data locally in the CouchDB database listed on one of the first
lines.  You will see various error messages if the CouchDB connection is
unsuccessful.

You can get to your local CouchDB admin console at the URL
<http://127.0.0.1:5984/_utils/> .



create a BlueMix service for your Cloudant database using the command-line
================================================================================

The first thing you should do is create a database at
[Cloudant](https://cloudant.com/)
to store the data for the application.  Once you've created the database, make
sure you add an API key (and remember the password!).  That API key should have
admin authority, as the database will be populated from scratch by the
server.

The name of the database is up to you, but you will need to use the name
when you create a BlueMix service for the database.  The database name
and BlueMix service name do **NOT** need to be the same, but you might want
to do that to keep things consistent.

Next, you'll create a BlueMix service for the Cloudant database.  You can do
this via the
[ACE dashboard](https://ace.ng.bluemix.net/),
or from the command-line.

This application expects the BlueMix service name to be, exactly:

    car-rally-db

To create the BlueMix service via the command-line, we'll use the `cf cups`
command:

    cf cups car-rally-db -p "url,database,username,password"

This will prompt you for values for url, database, username, and password.

The values you should use for your Cloudant database are:

    url:        https://<cloudant-userid>.cloudant.com
    database:   <cloudant-db-name>
    username:   <cloudant-db-API-key>
    password:   <cloudant-db-API-password>

After running the command, your service will be created and you should see
it listed when you run `cf services`.



deploying to BlueMix
================================================================================


To deploy from the command-line, while in the `bluemix-car-rally`
directory, issue the following command:

    cf push -n car-rally-charge-coupon-$RANDOM

You will need to ensure the `host` URL for the application is a unique host name across BlueMix. 

The progress of the deployment will be displayed on the console,
ultimately indicating your
application has been deployed and what URL it is available at.

Other commands you may want to use

* `cf logs car-rally`

  shows continuous log information for the app; Ctrl-C to exit

* `cf logs car-rally --recent`

  shows recent log information for the app

* `cf stop car-rally`

  stop the app if it's running

* `cf start car-rally`

  start the app if it's stopped

* `cf app car-rally`

  show information about the app

* `cf apps`

  show information about all the apps you have

You can of course also do all this through the
[ACE dashboard](https://ace.ng.bluemix.net/) as well.



about the application
================================================================================

This application is written in [CoffeeScript](http://coffeescript.org/) and
compiled into JavaScript.  The CoffeeScript source is available in the
`lib-src` directory, and the compiled JavaScript files are available in the
`lib` directory.

The browser code for this app is also written in CoffeeScript.
The source files are available in the
`www-src` directory, and the compiled JavaScript files are available in the
`www` directory.

Many 3rd party libraries are used in the app; see the following files for
the list of dependencies:

* `bower-config.coffee` - browser code
* `package.json` - server and some browser code



###promises###

This application makes heavy use of Q promises to handle async calls.
Promises are explained in depth on
[Q's project page](https://github.com/kriskowal/q) and
[an introduction to promises](http://www.promisejs.org/intro/) is
available at the <http://promisejs.org> site.



hacking
================================================================================

If you want to modify the source to play with it, you'll also want to have the
`jbuild` program installed.

To install `jbuild` on Windows, use the command

    npm -g install jbuild

To install `jbuild` on Mac or Linux, use the command

    sudo npm -g install jbuild

The `jbuild` command runs tasks defined in the `jbuild.coffee` file.  The
task you will most likely use is `watch`, which you can run with the
command:

    jbuild watch

When you run this command, the application will be built from source, the server
started, and tests run.  When you subsequently edit and then save one of the
source files, the application will be re-built, the server re-started, and the
tests re-run.  For ever.  Use Ctrl-C to exit the `jbuild watch` loop.

You can run those build, server, and test tasks separately.  Run `jbuild`
with no arguments to see what tasks are available, along with a short
description of them.



license
================================================================================

Apache License, Verison 2.0

<http://www.apache.org/licenses/LICENSE-2.0.html>
