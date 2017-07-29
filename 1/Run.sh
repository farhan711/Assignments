
TEMP="`mktemp`"
#defining colors
	function ee_info()
	{
			echo $(tput setaf 7)$@$(tput sgr0)
			#White for Success.
	}

		function ee_echo()
		{
				echo $(tput setaf 4)$@$(tput sgr0)
				#Blue for running
		}
		
			function ee_fail()
			{
					echo $(tput setaf 1)$@$(tput sgr0)
					#Red for error
			}
clear
			
# Authentication
	if [[ $EUID -eq 0 ]]; then
		ee_info "Sudo user privilage."
	else
		ee_fail "FAILED."
		ee_fail "Sudo bash failed."
	exit 1
	fi

ee_info "Authenticated."


ee_echo "Updating your current system..."   
#check for system version and update it if found old version.
	apt-get update &>> /dev/null
ee_info "Installing in process Wordpress with SQL Database, NginX Server..."

		ee_echo "dpkg found or not.."
	if [[ ! -x /usr/bin/dpkg ]]; then
		ee_echo "dpkg is not installed in your system, please wait while we install it for you..."
	apt-get -y install dpkg &>> /dev/null
	else
		ee_info "Here we Go.."	
fi

		ee_echo "wget found or not.."
	if [[ ! -x /usr/bin/wget ]]; then
		ee_fail "wget not installed."
		ee_echo "wget is not installed in your system, please wait while we install it for you..."
	apt-get -y install wget &>> /dev/null
	else
		ee_info "Here we Go.."
	fi
	
#TAR file extraction is available or not.


		ee_echo "tar found or not.."
	dpkg -s tar &>> /dev/null
	if [ $? -ne 0 ]; then
		ee_fail "wget is not installed in your system, please wait while we install it for you..."
		ee_echo "installing..."
	apt-get -y install tar &>> /dev/null
	else
		ee_info "Here we Go.."
	fi
	
	
	
#PHP5 Required for further installation.



		ee_echo "php found or not..."
	dpkg -s php5 &>> /dev/null && dpkg -s php5-fpm &>> /dev/null dpkg -s php5-mysql &>> /dev/null
	if [ $? -ne 0 ]; then
	        ee_fail "PHP5 is not installed in your system or might be dependencies is not found, please wait while we install it for you..."
	apt-get -y install php5 &>> /dev/null && apt-get -y install php5-fpm &>> /dev/null && apt-get -y install php5-mysql &>> /dev/null
		if [ $? -ne 0 ]; then
		ee_fail "Dependencies error please rerun the php setup again..."
		fi
	else
		ee_info "Here we Go!"
	fi



		ee_echo "SQL found or not.."
	dpkg -s mysql-server &>> /dev/null
	if [ $? -ne 0 ]; then
		ee_fail "SQL is not installed in your system, please wait while we install it for you..."
		
		
		
	#MySQL Root password
	
	
	
	password=$(date | md5sum | head -c 9)
	echo mysql-server mysql-server/root_password password $password | sudo debconf-set-selections
	echo mysql-server mysql-server/root_password_again password $password | sudo debconf-set-selections
	apt-get install -y mysql-server &>> /dev/null
		ee_fail " Your MySQL PASSWORD is = $password "
	else
		ee_info "Her we GO... SQL is already up..."
	fi
	

		ee_echo "Nginx found or not.."
	dpkg -s nginx &>> /dev/null
	if [ $? -ne 0 ]; then
		ee_fail "Nginx is not installed in your system, please wait while we install it for you..."
		apt-get install -y nginx &>> /dev/null
	else
		ee_info "Here we Go.. Nginx is up.."
	fi
	
	
#Domain Assignment to user
	for (( ;; )); do
	read -p "Please enter your required domain address(like: farhanansari.in) :: " example_com
	grep $example_com /etc/hosts &>> /dev/null
	if [ $? -eq 0 ]; then
	ee_fail "Sorry domain already in use.."
	else
	break
	fi
	done
	ee_info "You inputed this domain $example_com"
	echo "127.0.0.1 $example_com" | tee -a /etc/hosts &>> /dev/null 
	
	
#Here creating NginX config file to run at server


	tee /etc/nginx/sites-available/$example_com << EOF
server {
        listen   80;


        root /var/www/$example_com;
        index index.php index.html index.htm;

        server_name $example_com;

        location / {
                try_files \$uri \$uri/ /index.php?q=\$uri&\$args;
        }

        error_page 404 /404.html;

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
              root /usr/share/nginx/www;
        }

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        location ~ \.php\$ {
                try_files \$uri =404;
                
                
                fastcgi_pass unix:/var/run/php5-fpm.sock;
                fastcgi_index index.php;
                include fastcgi_params;
				#fastcgi_pass 127.0.0.1:9000;
                 }
   }
EOF
	ln -sF /etc/nginx/sites-available/$example_com /etc/nginx/sites-enabled/$example_com
	rm -rf /etc/nginx/sites-available/default &>> /dev/null
	service nginx restart >> $TEMP 2>&1
	if [ $? -eq 0 ]; then
		ee_info "Nginx is successfully installed..."
	else
		ee_fail "ERROR! Use:>>>sudo nginx -t<<<< in Terminal"
	fi	
	service php5-fpm restart >> $TEMP 2>&1
	ee_fail "This is Config File.."
	

		ee_echo "Wordpress is fetching data from official directory http://wordpress.org/latest.tar.gip "
	 cd ~ && wget http://wordpress.org/latest.tar.gz >> $TEMP 2>&1
        if [ $? -eq 0 ]; then
	 	ee_info "Latest version of wordpress is installed."
	else
		ee_fail "ERROR:Failed to get latest tar file, Please check log files $TEMP" 1>&2
	fi
	
	
	
	
#Extracting file from source address...




		ee_echo "Extraction is in progress..."
	cd ~ && tar xzvf latest.tar.gz &>> /dev/null && mv wordpress $example_com &>> /dev/null
	if [ $? -eq 0 ]; then
		ee_info "Extracted Successfully"
	cp -rf $example_com /var/www/
	fi 
	rm -rf latest.tar.gz &>> /dev/null
	
	
	
#Creating user database for wordpress installation



	db_name="_db"
	db_root_passwd="$password"
	mysql -u root -p$db_root_passwd << EOF
	CREATE DATABASE ${example_com//./_}$db_name;
	CREATE USER ${example_com//./_}@localhost;
	SET PASSWORD FOR ${example_com//./_}@localhost=PASSWORD("$password");
	GRANT ALL PRIVILEGES ON ${example_com//./_}$db_name.* TO ${example_com//./_}@localhost IDENTIFIED BY '$password';
	FLUSH PRIVILEGES;
	#exit;
EOF
	if [ $? -eq 0 ]; then
		ee_info "Database is successfully established."
		ee_info "DB NAME = ${example_com//./_}$db_name "
 		ee_info "DB password = $password"
		ee_fail "MYSQL-ROOT password = $db_root_passwd "
	else
		ee_fail "Something went wrong... please rerun this setup."
	fi
     
	 #Creating wp-config file with database name, user, password
	
	
	
	
	cp /var/www/$example_com/wp-config-sample.php /var/www/$example_com/wp-config.php
	sed -i "s/\(.*'DB_NAME',\)\(.*\)/\1'${example_com//./_}$db_name');/" /var/www/$example_com/wp-config.php
	sed -i "s/\(.*'DB_USER',\)\(.*\)/\1'${example_com//./_}');/" /var/www/$example_com/wp-config.php
	sed -i "s/\(.*'DB_PASSWORD',\)\(.*\)/\1'$password');/" /var/www/$example_com/wp-config.php




#define('AUTH_KEY',         's{#03M9G9-%WU@0-@noq`zH_jqi0f-Y5{5_N[/=}/)qS),vRhAj,cq4AMz Y?k:5');
#define('SECURE_AUTH_KEY',  'Ur)ievgz:#[TyucD7}Oct#}mD[`v6SjwoUlMxu-&aO8k4/dGVx>*Gd0pJit%2J}t');
#define('LOGGED_IN_KEY',    'lRm:GT]qk5+A;;49N  08>~des>{+.^zYX+9($5V]#++1&wT|EJ*f.o!$4@6&awY');
#define('NONCE_KEY',        '_KXrLr6Xvz7rwX)//1vLB>[~LiXL[JaUt^2SD5bf|jjr>4P6y^?t^MBdfaRRv$FL');
#define('AUTH_SALT',        'J;g1)ULv`leJr4Hi*;X3D#b?I@y9.d 5dPIF27pV=/q?UX_?(l{^dS:4DC-SB|M&');
#define('SECURE_AUTH_SALT', 'c->1W!N0rm#h |`7etHKUt,N;WTW&}B^K`|u_KGQ~V|ChhH;B,d?HHW_0drKM}$2');
#define('LOGGED_IN_SALT',   '*s8[]},Gy,V_KWT4{!n( Ef-Ffh]8d:z[,ha;o)U~[osDd+Vf3-,fvxrdw>?++[c');
#define('NONCE_SALT',       'y K3Z+T&Az=FdRc.8@=Z(=A-R^r_cX[FZ&ieL%2*/]Ra,s4Eg:jIY2PiESEj%tF$');
#Creating security of Wp-config
sed -i 's/\(.*'\''AUTH_KEY'\'',\)\(.*\)/\1'\''s{#03M9G9-%WU@0-@noq`zH_jqi0f-Y5{5_N[/=}/)qS),vRhAj,cq4AMz Y?k:5'\'');/' /var/www/$example_com/wp-config.php
sed -i 's/\(.*'\''SECURE_AUTH_KEY'\'',\)\(.*\)/\1'\''Ur)ievgz:#[TyucD7}Oct#}mD[`v6SjwoUlMxu-&aO8k4/dGVx>*Gd0pJit%2J}t'\'');/' /var/www/$example_com/wp-config.php
sed -i 's/\(.*'\''LOGGED_IN_KEY'\'',\)\(.*\)/\1'\''lRm:GT]qk5+A;;49N  08>~des>{+.^zYX+9($5V]#++1&wT|EJ*f.o!$4@6&awY'\'');/' /var/www/$example_com/wp-config.php
sed -i 's/\(.*'\''NONCE_KEY'\'',\)\(.*\)/\1'\''_KXrLr6Xvz7rwX)//1vLB>[~LiXL[JaUt^2SD5bf|jjr>4P6y^?t^MBdfaRRv$FL'\'');/' /var/www/$example_com/wp-config.php
sed -i 's/\(.*'\''AUTH_SALT'\'',\)\(.*\)/\1'\''J;g1)ULv`leJr4Hi*;X3D#b?I@y9.d 5dPIF27pV=/q?UX_?(l{^dS:4DC-SB|M&'\'');/' /var/www/$example_com/wp-config.php
sed -i 's/\(.*'\''SECURE_AUTH_SALT'\'',\)\(.*\)/\1'\''c->1W!N0rm#h |`7etHKUt,N;WTW&}B^K`|u_KGQ~V|ChhH;B,d?HHW_0drKM}$2'\'');/' /var/www/$example_com/wp-config.php
sed -i 's/\(.*'\''LOGGED_IN_SALT'\'',\)\(.*\)/\1'\''*s8[]},Gy,V_KWT4{!n( Ef-Ffh]8d:z[,ha;o)U~[osDd+Vf3-,fvxrdw>?++[c'\'');/' /var/www/$example_com/wp-config.php
sed -i 's/\(.*'\''NONCE_SALT'\'',\)\(.*\)/\1'\''y K3Z+T&Az=FdRc.8@=Z(=A-R^r_cX[FZ&ieL%2*/]Ra,s4Eg:jIY2PiESEj%tF$'\'');/' /var/www/$example_com/wp-config.php



	chown www-data:www-data * -R /var/www/
	chmod -R 755 /var/www
	service nginx restart >> $TEMP 2>&1
	if [ $? -eq 0 ]; then
		ee_info "NginX is successfully installed."
	else
		ee_fail "ERROR! Use:>>>sudo nginx -t<<<< in Terminal"
	fi	
	service php5-fpm restart >> $TEMP 2>&1

ee_info "Visit your domain to see Howdy!!"
