
# Vocabulari.se

## 1. Requirements

First, make install ruby and a proper version of rubygems (>=1.7) on your system :

    sudo apt-get install rubygems1.8

Then, install  headers packages required to build some gems :

    sudo apt-get install libmysqlclient-dev libsqlite3-dev

Also install mandatory gem packages on your system :

    sudo gem install bundle 
    sudo gem install capistrano capistrano-ext
    sudo gem install thin

And make sure that `/var/lib/gems/1.8/bin` is in your path. Update your
`~.profile` or `~/.bashrc` or simply run :

    export PATH=$PATH:/var/lib/gems/1.8/bin/

Finally, from the project directory, run the following command to install
locally into the `vendor/` directory the gems required by this project and all
their dependencies :

    bundle install --path vendor


## 2. Configuration

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


## 3. Running (development mode)

From the source directory, simply type the following command, from the project
directory :

    ./run.sh


## 4. Deploying (production mode)

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


### 4.4. Remotely updating code

To deploy, get in the source directory on you computer (not the server), and type :

    cap production deploy

It will update the remote source from the reference Git repository.

Then control the server run with :

    cap production deploy:stop
    cap production deploy:start

## 5. API

Some interesting URL, if you want to directly access computed data :

### 5.1. /search/expected

Search returns words co-tagged unfrequently yet effectively with the query in
research publications, ranked according to readership on Mendeley, and the
associated publications.


#### Examples 

  * http://vocabulari.se/search/expected?query=neutrino
  * http://vocabulari.se/search/expected?query=climate%20change


#### Method

<table>
    <tr>
	<th>URI</th>
	<th>Method</th>
	<th>Authentication</th>
    </tr>
    </tr>
	<td>http://vocabulari.se/search/controversial</td>
	<td>GET</td>
	<td>none</td>
    </tr>
</table>


#### Parameters

<table>
    <tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Description</th>
    </tr>
    </tr>
	<td>query</td>
	<td>String</td>
	<td>A tag to be searched</td>
    </tr>
</table>


#### Response example


### 5.2. /search/controversial

Search returns words co-appearing with the query in the most discussed
Wikipedia entries, according to controversial power, and the associated
entries.


#### Examples

  * http://vocabulari.se/search/controversial?query=neutrino
  * http://vocabulari.se/search/controversial?query=climate%20change

#### Method

<table>
    <tr>
	<th>URI</th>
	<th>Method</th>
	<th>Authentication</th>
    </tr>
    </tr>
	<td>http://vocabulari.se/search/controversial</td>
	<td>GET</td>
	<td>none</td>
    </tr>
</table>


#### Parameters

<table>
    <tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Description</th>
    </tr>
    </tr>
	<td>query</td>
	<td>String</td>
	<td>A tag to be searched</td>
    </tr>
</table>


#### Response example



### 5.3. /search/aggregating

Search returns words co-tagged with the query in research publications, ranked
according to the diversity of readers&rsquo; disciplines on Mendeley, and the
associated disciplines.


#### Examples

  * http://vocabulari.se/search/aggregating?query=neutrino
  * http://vocabulari.se/search/aggregating?query=climate%20change

#### Method

<table>
    <tr>
	<th>URI</th>
	<th>Method</th>
	<th>Authentication</th>
    </tr>
    </tr>
	<td>http://vocabulari.se/search/aggregating</td>
	<td>GET</td>
	<td>none</td>
    </tr>
</table>


#### Parameters

<table>
    <tr>
	<th>Parameter</th>
	<th>Type</th>
	<th>Description</th>
    </tr>
    </tr>
	<td>query</td>
	<td>String</td>
	<td>A tag to be searched</td>
    </tr>
</table>

#### Response example

