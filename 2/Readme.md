user@hostname$ python Blog_Arg_script.py -h 
usage: Blog_Arg_script.py [-h] {post,category}

positional arguments:
  {post,category}  sub-command help
    post           Add, Delete, List or Search blog posts
    category       Add, List or Assign blog post categories



Creating a post

user@hostname$ python Blog_Arg_script.py post add -c Universe -a farhan -p "planets" "The following are the Universe available: Mercury, Venus , Earth";
Blog post created successfully!
Title: 'planets'
Author: 'farhan'
Category: Universe
Content: 'The following are the planets available: Mercury, Venus , Earth'



List a post

user@hostname$ python Blog_Arg_script.py post list
Displaying 1 blog posts.


Search a post

user@hostname$ python Blog_Arg_script.py post search "planets 1"


Delete a post

user@hostname$ python Blog_Arg_script.py post delete "planets 1"