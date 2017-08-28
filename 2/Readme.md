
## Positional arguments:
```
  {post,category}  sub-command help
    post           Add, Delete, List or Search blog posts
    category       Add, List or Assign blog post categories
```
## Requirements
1. Python 3.6
2. Python modules: sqlite3, terminaltables

## Installation
Clone Repo after that run following command

1. Run the following command for installation of requirements,
```
user@hostname /home/user/Assignments/2 $ pip install -r /path/to/requirements.txt
Collecting terminaltables==3.1.0 (from -r requirements.txt (line 1))
Installing collected packages: terminaltables
Successfully installed terminaltables-3.1.0
```


## Usage
```
user@hostname$ python blog.py -h 
usage: Blog_Arg_script.py [-h] {post,category} ...

Command line blogging utility

positional arguments:
  {post,category}  sub-command help
    post           Add, Delete, List or Search blog posts
    category       Add, List or Assign blog post categories

```

## Example
1. First add a category before creating posts in that category

```
user@hostname$ python Blog_Arg_script.py category add cars
Blog post category 'Universe' created successfully!
```

2. Create a blog post
```
user@hostname$ python Blog_Arg_script.py post add -c Universe -a new-user -p "planets" "The following are the planets available: mars, jupiter, earth"
Blog post created successfully!
Title: 'planet'
Author: 'new-user'
Category: 'Universe'
Content: 'The following are the planets available: mars, jupiter, earth'
```

3. List blog posts
```
user@hostname$ python Blog_Arg_script.py post list
Displaying 1 blog posts.
```

4. Search blog posts
```
user@hostname$ python Blog_Arg_script.py post search "planet 1"
[1] blog posts found.
```

5. Delete a blog post
```
user@hostname$ python Blog_Arg_script.py post delete "planet 1"
[1] blog posts with Title 'planet 1' deleted successfully.
```

Note: Add a category before adding a blog post in that category
