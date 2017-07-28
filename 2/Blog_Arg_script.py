import argparse
import sqlite3
import terminaltables


class Blog:
    def __init__(self):
        self.args = None
        self.arg_parser = None
        self.connection = None
        self.db_handle = None

    def parser(self):
       
        self.arg_parser = argparse.ArgumentParser(description='Command line blogging utility')
        subparsers = self.arg_parser.add_subparsers(help='sub-command help')

        #
        # Blog post subparser
        parser_blog_post = subparsers.add_parser('post', help='Add, Delete, List or Search blog posts')
        parser_blog_post_subparsers = parser_blog_post.add_subparsers(help='sub-command help')

        # Add Blog post parser
        parser_blog_post_add = parser_blog_post_subparsers.add_parser('add', help='Add a blog post')
        parser_blog_post_add.add_argument('title', help='Title of the Blog post')
        parser_blog_post_add.add_argument('content', help='Content of the Blog post')
        parser_blog_post_add.add_argument('-c', '--category', help='Blog post category')
        parser_blog_post_add.add_argument('-a', '--author', help='Author of the Blog post')
        parser_blog_post_add.add_argument('-p', '--timestamp', action='store_true',
                                          help='Include current date and time as publishing date')
        parser_blog_post_add.set_defaults(func=self.post_add)

        # List Blog posts
        parser_blog_post_list = parser_blog_post_subparsers.add_parser('list', help='List all blog posts')
        parser_blog_post_list.set_defaults(func=self.post_list)

        # Search Blog posts
        parser_blog_post_search = parser_blog_post_subparsers.add_parser('search', help='Search blog posts')
        parser_blog_post_search.add_argument('keyword', help='Keyword to be searched in Blog posts')
        parser_blog_post_search.set_defaults(func=self.post_search)

        # Delete Blog parser
        parser_blog_post_delete = parser_blog_post_subparsers.add_parser('delete', help='Delete a blog post')
        parser_blog_post_delete.add_argument('title', help='Title of the Blog post')
        parser_blog_post_delete.set_defaults(func=self.post_delete)

        #
        # Blog category subparser
        parser_blog_category = subparsers.add_parser('category', help='Add, List or Assign blog post categories')
        parser_blog_category_subparsers = parser_blog_category.add_subparsers(help='sub-command help')

        # Add Blog post category
        parser_blog_category_add = parser_blog_category_subparsers.add_parser('add', help='Add a blog post category')
        parser_blog_category_add.add_argument('name', help='Blog post category name')
        parser_blog_category_add.set_defaults(func=self.category_add)

        # List Blog post category
        parser_blog_category_list = parser_blog_category_subparsers.add_parser('list', help='List blog post categories')
        parser_blog_category_list.set_defaults(func=self.category_list)

        # Assign Blog post category
        parser_blog_category_assign = parser_blog_category_subparsers.add_parser('assign',
                                                                                 help='Assign category to a blog post')
        parser_blog_category_assign.add_argument('category-name', help='Category name')
        parser_blog_category_assign.add_argument('blog-post-title', help='Blog post name')
        parser_blog_category_assign.set_defaults(func=self.category_assign)

        self.args = self.arg_parser.parse_args()

    def db_init(self):
        """
        Initialize SQLite database connection
        :return: None
        """
        # Establishing SQLite database connection
        self.connection = sqlite3.connect('blog.db')
        self.db_handle = self.connection.cursor()

        # Create 'blog' table
        self.db_handle.execute('''CREATE TABLE IF NOT EXISTS `blog` ( `id` INTEGER PRIMARY KEY AUTOINCREMENT,
                                                                      `title` TEXT(1000) NOT NULL ,
                                                                      `author` VARCHAR(255) DEFAULT NULL ,
                                                                      `category` VARCHAR(255) DEFAULT NULL ,
                                                                      `content` LONGTEXT NOT NULL ,
                                                                      `timestamp` DATETIME DEFAULT NULL,
                                                                      CONSTRAINT constraint_name UNIQUE (title, author)
                                                                      ON CONFLICT REPLACE)''')
        # Create 'categories' table
        self.db_handle.execute('''CREATE TABLE IF NOT EXISTS `categories` (
                                                                `id` INTEGER PRIMARY KEY AUTOINCREMENT,
                                                                `categories` VARCHAR(255) UNIQUE NOT NULL)''')
        self.connection.commit()

    def db_close(self):
        """
        Terminate SQLite database connection
        :return: None
        """
        self.connection.close()

    def post_add(self):
        """
        Create a blog post with title, content and other attributes passed as arguments
        :return: None
        """
        self.db_init()

        # Remove unspecified arguments
        details = vars(self.args)
        details.pop('func')
        details = {key: repr(val) for key, val in details.items() if val}

        # Check if specified category exists, else exit
        if 'category' in details:
            self.db_handle.execute('SELECT * FROM categories WHERE categories="%s"' % (vars(self.args))['category'])
            if len(self.db_handle.fetchall()) == 0:
                print("Category '%s' does not exist.\n"
                      "Create the new category before creating a blog post under the category (or) \n"
                      "Create a blog post without the category argument (-a option) and then after creating "
                      "the category assign it using 'category assign' "
                      "sub-command (See category -h)" % (vars(self.args)['category']))
                exit()

        if 'timestamp' in details:
            details['timestamp'] = 'datetime("now", "localtime")'

        try:
            self.db_handle.execute('INSERT OR REPLACE INTO blog (%s) VALUES (%s)' % (','.join(details.keys()),
                                                                                     ','.join(details.values())))
            self.connection.commit()
        except Exception as exception:
            print('Error occurred during execution: {0}'.format(type(exception).__name__))
            exit()

        print("Blog post created successfully!\n"
              "Title: '%s'\n"
              "Author: '%s'\n"
              "Category: '%s'\n"
              "Content: '%s'" %
              (vars(self.args)['title'], vars(self.args)['author'],
               vars(self.args)['category'], vars(self.args)['content']))

    def post_list(self):
        """
        List all bog posts
        :return: None
        """
        self.db_init()
        try:
            self.db_handle.execute('SELECT * FROM blog')
            blog_posts_list = self.db_handle.fetchall()
        except Exception as exception:
            print('Error occurred during execution: {0}'.format(type(exception).__name__))
            exit()

        print('Displaying %i blog posts.' % (len(blog_posts_list)))
        blog_posts_list.insert(0, ('Id', 'Title', 'Author', 'Category', 'Content', 'Date Published'))

        # Display list of blog posts in terminal table
        table = terminaltables.DoubleTable(blog_posts_list, title='Blog Posts')
        table.inner_row_border = True
        print(table.table)

    def post_search(self):
        """
        Search bog posts
        :return: None
        """
        self.db_init()
        try:
            query_statement = """SELECT * FROM blog WHERE title LIKE '%{0}%' OR
                                                          author LIKE '%{0}%' OR
                                                          category LIKE '%{0}%' OR
                                                          content LIKE '%{0}%'""".format(vars(self.args)['keyword'])
            self.db_handle.execute(query_statement)
            blog_posts_search = self.db_handle.fetchall()
        except Exception as exception:
            print('Error occurred during execution: {0}'.format(type(exception).__name__))
            exit()

        print('[%i] blog posts found.' % (len(blog_posts_search)))
        blog_posts_search.insert(0, ('Id', 'Title', 'Author', 'Category', 'Content', 'Date Published'))

        # Display list of blog posts in terminal table
        table = terminaltables.DoubleTable(blog_posts_search, title='Blog Posts')
        table.inner_row_border = True
        print(table.table)

    def post_delete(self):
        """
        Delete a blog post having a specific title passed as an argument
        :return:
        """
        self.db_init()
        try:
            result = self.db_handle.execute('DELETE FROM blog WHERE title="%s"' % (vars(self.args)['title']))
            self.connection.commit()
        except Exception as exception:
            print('Error occurred during execution: {0}'.format(repr(exception)))
            exit()

        print("[%i] blog posts with Title '%s' deleted successfully." % (result.rowcount, vars(self.args)['title']))

    def category_add(self):
        """
        Create a new category
        :return: None
        """
        self.db_init()
        try:
            self.db_handle.execute('INSERT INTO categories (categories) VALUES ("%s")' % (vars(self.args)['name']))
            self.connection.commit()
        except sqlite3.IntegrityError:
            print("Category '%s' already exists" % (vars(self.args)['name']))
            exit()
        except Exception as exception:
            print('Error occurred during execution: {0}'.format(type(exception).__name__))
            exit()

        print("Blog post category '%s' created successfully!" % (vars(self.args)['name']))

    def category_list(self):
        """
        List all available categories
        :return: None
        """
        self.db_init()
        try:
            self.db_handle.execute('SELECT * FROM categories')
            categories = self.db_handle.fetchall()
        except Exception as exception:
            print('Error occurred during execution: {0}'.format(type(exception).__name__))
            exit()

        print('Displaying %i blog post categories.' % (len(categories)))
        categories.insert(0, ('Id', 'Categories'))

        # Display category list in terminal table
        table = terminaltables.DoubleTable(categories, title='Blog Categories')
        table.inner_row_border = True
        print(table.table)

    def category_assign(self):
        """
        Assign an existing category to an existing blog post
        :return: None
        """
        self.db_init()

        # Check if category exists
        self.db_handle.execute('SELECT * FROM categories WHERE categories="%s"' % (vars(self.args)['category-name']))
        if len(self.db_handle.fetchall()) == 0:
            print("Category '%s' does not exist.\nCreate the category before assigning." %
                  (vars(self.args)['category-name']))
            exit()

        # Check if blog post with the specified title exists
        self.db_handle.execute('SELECT * FROM blog WHERE title="%s"' % (vars(self.args)['blog-post-title']))
        if len(self.db_handle.fetchall()) == 0:
            print("Could not assign category.\nBlog post with title '%s' does not exist." %
                  (vars(self.args)['blog-post-title']))
            exit()

        try:
            self.db_handle.execute('UPDATE blog SET category="%s" WHERE title="%s"' %
                                   (vars(self.args)['category-name'], vars(self.args)['blog-post-title']))
            self.connection.commit()
        except Exception as exception:
            print('Error occurred during execution: {0}'.format(type(exception).__name__))
            exit()

        print("Category '%s' assigned to blog post '%s'" %
              (vars(self.args)['category-name'], vars(self.args)['blog-post-title']))


if __name__ == "__main__":
    blog = Blog()
    blog.parser()
    if blog.args.__dict__.keys():
        blog.args.func()
        blog.db_close()
    else:
        blog.arg_parser.print_help()