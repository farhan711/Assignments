# Assignments
DevOps Engineer Assignment

## Assignment-1: Web Server Setup for WordPress
Please create a command-line script, preferably in bash, to perform following tasks in order.

Your script will check if PHP, Mysql & Nginx are installed. If not present, missing packages will be installed.

The script will then ask user for domain name. (Suppose user enters example.com)

Create a /etc/hosts entry for example.com pointing to localhost IP.

Create nginx config file for example.com

Download WordPress latest version from http://wordpress.org/latest.zip and unzip it locally in example.com document root.

Create a new mysql database for new WordPress. (database name “example.com_db” )

Create wp-config.php with proper DB configuration. (You can use wp-config-sample.php as your template)

You may need to fix file permissions, cleanup temporary files, restart or reload nginx config.

Tell user to open example.com in browser (if all goes well


## Assignment-2: Blogging Command-Line App

Please create a small command-line blogging application which implements following in bash.

For this assignment you need to use a database. You can use sqlite.

```blog.sh``` will be name of application itself.

```blog.sh``` --help will list help and commands available

```blog.sh``` post add "title" "content" will add a new blog a new blog post with title and content.

```blog.sh``` post list will list all blog posts

```blog.sh``` post search "keyword" will list all blog posts where “keyword” is found in title and/or content.

```blog.sh``` category add "category-name" create a new category

```blog.sh``` category list list all categories

```blog.sh``` category assign <post-id> <cat-id> assign category to post

```blog.sh``` post add "title" "content" --category "cat-name" will add a new blog a new blog post with title, content and assign a category to it. It category doesn’t exist, it will be created first.

Please Note : I have created Blog_Arg_script.py instead of blog.py 
