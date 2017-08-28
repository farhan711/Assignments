```user@hostname$ python3 Blog_Arg_script.py -h ```
usage: Blog_Arg_script.py [-h] {post,category}

positional arguments:
```
  {post,category}  sub-command help
    post           Add, Delete, List or Search blog posts
    category       Add, List or Assign blog post categories
```


<b>Creating a post</b>
```
user@hostname$ python3 Blog_Arg_script.py post add -c Universe -a farhan -p "planets" "The following are the Universe available: Mercury, Venus , Earth";```

Blog post created successfully!
```
Title: 'planets'
Author: 'farhan'
Category: Universe
Content: 'The following are the planets available: Mercury, Venus , Earth'
```


<b>List a post</b>
```
user@hostname$ python3 Blog_Arg_script.py post list
```
Displaying 1 blog posts.


<b>Search a post</b>
```
user@hostname$ python3 Blog_Arg_script.py post search "planets 1"
```

<b>Delete a post</b>
```
user@hostname$ python3 Blog_Arg_script.py post delete "planets 1"
```

Note: Use only python if system don't have multi python versions.

Requirement :

** Python 3.6 **
