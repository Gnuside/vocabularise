
vocabulari.se install (obsolete)
================================

1. Requirements
---------------

First, make sure your have a recent ruby installation on your system (if
possible with rbenv or rvm).

    sudo apt-get install rubygems1.9

Then, install some headers packages required to build dependencies :

    sudo apt-get install libmysqlclient-dev libsqlite3-dev

Also install mandatory gem packages on your system :

    sudo gem install bundle

Finally, from the project directory, run the following command to install
locally into the `vendor/` directory the gems required by this project and all
their dependencies :

    bundle install --path vendor/bundle


2. Configuration
----------------

Fill required fields in the `config/vocabularise.json` file :

    {
        "cache_dir" : "cache",
        "cache_duration_min" : 7200,
        "cache_duration_max" : 604800,

        "consumer_key" : "",
        "consumer_secret" : "",

        "db_adapter" : "mysql",
        "db_database" : "",
        "db_host" : "",
        "db_username" : "",
        "db_password" : "",

        "dictionary" : "config/dictionary.example"
    }


3. Running in development mode
------------------------------

From the source directory, simply type the following command, from the project
directory :

    ./script/server-dev.sh


4. Running in production mode
-----------------------------

### 4.1. Setting up the web server


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


### 4.2. Setting up vocabularise user

On the remote server, type (as root) :

    adduser vocabularise

Also make sure you have a SSH server enabled to allow remote access.
If not, type type (as root) :

    apt-get install openssh-server

From you own computer, generate you ssh key :

    ssh-keygen -t dsa

And upload it to the list of authorized keys on server, either by editing the `~/.ssh/authorized_keys` file on the server, or typing the following command from you own machine : 

    ssh-copy-id vocabularise@vocabulari.se


### 4.4. Deploy the code

To deploy, get in the source directory on you computer (not the server), and type :

    cap production deploy

It will update the remote source from the reference Git repository.

Then control the server run with :

    cap production deploy:stop
    cap production deploy:start

