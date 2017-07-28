
TEMP="`mktemp`"

	function ee_info()
	{
			echo $(tput setaf 7)$@$(tput sgr0)
	}

	
		function ee_echo()
		{
				echo $(tput setaf 4)$@$(tput sgr0)
		}
		
			function ee_fail()
			{
					echo $(tput setaf 1)$@$(tput sgr0)
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
	
#Creating security of Wp-config
sed -i 's/\(.*'\''AUTH_KEY'\'',\)\(.*\)/\1'\''Ap2g08@ON7e-j]?+E.csw>-{2hkE!()#rb7gD]q|\&;C4@3455AL_=1LQZ92u|IH}'\'');/' /var/www/$example_com/wp-config.php
sed -i 's/\(.*'\''SECURE_AUTH_KEY'\'',\)\(.*\)/\1'\''OKuteSM`D=6LVHR+cDbG_cBQ}w@-;>!{T*fy?g{.O(^{V }ygFO:Gc$m9.Iwz~I{'\'');/' /var/www/$example_com/wp-config.php
sed -i 's/\(.*'\''LOGGED_IN_KEY'\'',\)\(.*\)/\1'\''eKR=za5g(>GZr(`{-n8j86aM]L>Imhg@hO\/kyv954MVeslHtT+sCq}^|OVQrrq^B'\'');/' /var/www/$example_com/wp-config.php
sed -i 's/\(.*'\''NONCE_KEY'\'',\)\(.*\)/\1'\''e_Cc;YTW,y3Cplk{4^AFcnQOvtL%+G6CYAK$=yiq;#d?%11SlkYR8CQD$C\/S|8Mq'\'');/' /var/www/$example_com/wp-config.php
sed -i 's/\(.*'\''AUTH_SALT'\'',\)\(.*\)/\1'\''sDj8\&?Blr|r_x%;wqA069^O8?5+G8@7hZD`{0|RN=kp>H)Us(]wv.6Mu,M)%cF.a'\'');/' /var/www/$example_com/wp-config.php
sed -i 's/\(.*'\''SECURE_AUTH_SALT'\'',\)\(.*\)/\1'\''do}{{It04FMH+Su+#[(0lC-Khvc2[DO`Xy;}348?_Ah|INH[t~5:|m.JlegN%t\&g'\'');/' /var/www/$example_com/wp-config.php
sed -i 's/\(.*'\''LOGGED_IN_SALT'\'',\)\(.*\)/\1'\''O7|C5K-u+jkc~kf^hlf6t:|-;,5HI]d4G 2mK_h|~FZ!uifbcE:UAHExyB)$0a.+'\'');/' /var/www/$example_com/wp-config.php
sed -i 's/\(.*'\''NONCE_SALT'\'',\)\(.*\)/\1'\''k:d6U3,|YiE^36Un-8xl99?Uz|M[x#{yI-K?0{-- \&2T-J-mfr#;|XxrQFop\&^Z+'\'');/' /var/www/$example_com/wp-config.php


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
