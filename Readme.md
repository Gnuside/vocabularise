Vocabulari.se
=============


1. Requirements
---------------

First, make install ruby and a proper version of rubygems (>=1.7) on your system

    sudo apt-get install rubygems1.8

Then, install  headers packages required to build some gems

    sudo apt-get install libmysqlclient-dev libsqlite3-dev

Also install mandatory gem packages on your system

    sudo gem install bundle 
    sudo gem install capistrano capistrano-ext
    sudo gem install thin

And make sure that `/var/lib/gems/1.8/bin` is in your path. Update your
`~.profile` or `~/.bashrc` or simply run

    export PATH=$PATH:/var/lib/gems/1.8/bin/

Finally, from the project directory, run the following command to install
locally into the `vendor/` directory the gems required by this project and all
their dependencies :

    bundle install --path vendor


2. Configuration
----------------


3. Running (development mode)
-----------------------------

Simply type the following command, from the project directory :

    ./run.sh


4. Deploying 
------------


### 4.1. Configuring the web server


Install a reverse proxy server, like nginx :

    sudo apt-get install nginx

In the directory `/etc/nginx/sites-enabled/`, create a configuration file for 
a virtual host called `vocabulari.se`, with the following content :

    upstream vocabularise_cluster {
        server  unix:/var/tmp/vocabularise.sock;
    }

    server {
        listen          80
        server_name     vocabulari.se;
    
        access_log      /var/log/nginx/vocabulari-se.access_log;
        error_log       /var/log/nginx/vocabulari-se.error_log warn;
    
        root            /var/www;
        index           index.php index.html;

        location / {
            break;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-Proto https;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://vocabularise_cluster;

            # in order to support COPY and MOVE, etc
            set  $dest  $http_destination;
            if ($http_destination ~ "^https://(.+)") {
                set  $dest   http://$1;
            }
            proxy_set_header  Destination   $dest;
        }
    }


The web server will then redirect any external request to internal unix
socket `/var/tmp/vocabularise.sock` .

Enable the configuration :

    ln -s /etc/nginx/sites-available/vocabulari.se \
        /etc/nginx/sites-enabled/vocabulari.se

Restart nginx :

    /etc/init.d/nginx restart


### 4.2. Remotely updating code

To deploy, get in the source directory on you computer (not the server), and type:

    cap production deploy

It will update the remote source from the reference Git repository.

Then control the server run with :

    cap production deploy:stop
    cap production deploy:start

P.S: all that requires login & password access to the server.


### 4.1. Configuring 

FIXME: explain vocabularise.json

