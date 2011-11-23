### Prerequisites

 - Ubuntu 10.04+ (I bet it will work under many other OS, it is just ones I tested with.)
 - cpanm
 - SQLite3/MySQL/PostgreSql
 - Amazon S3 account 
 
### Installation

Install application dependencies by:

    cpanm --installdeps .

Copy ubitious_sample.conf to ubitious.conf:

    cp ubitious_sample.conf ubitious.conf

Obtain keys at Amazon S3 panel and put these into ubitious.conf.

Prepopulate sqlite3 DB:

    sqlite3 ubitious.db < schema.sql 

Configure bitcoind login/password/host and GA account settings in ubitious.conf.

### Run 

Run script/ubitious_server.pl to test the application.

    UBITIOUS_DEBUG=1 ./script/ubitious_server.pl -r

### Deployment under Apache

Enable FastCGI module:

    a2enmod fastcgi 

In /etc/apache2/sites-available/ubitious.conf:

    FastCgiServer /home/ubitious/web/ubitious_fastcgi.pl -processes 2
    
    <VirtualHost *:80>
      ServerName ubitious.example.com
      DocumentRoot  /home/ubitious/web/root
      Alias /static /home/ubitious/web/root/static
      Alias / /home/ubitious/web/script/ubitious_fastcgi.pl/
    </VirtualHost>

Enable newly created virtual host config:

    a2ensite ubitious.conf 

Restart Apache:

    /etc/init.d/apache2 restart 
