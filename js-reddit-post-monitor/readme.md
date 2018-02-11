## What it does

This single HTML page monitors Reddit in certain subreddits for any new posts. It check Reddit periodically.  

## Why I code it

Because I myself need it. Because I myself wasted a lot of time on refreshing different subreddit page to look for new posts. I need a tool to automate it thus we have this code.

## How to run

Just load the index.html in your web browser, or put the index.html on your web server and load there.

## How to config

Edit index.html in your favorite editor, the config is in the line ```var config```.  
- ```refreshInterval```: The time in seconds between each refreshing. 0 to disable auto refreshing.
- ```firstSeenPostsCount```: The number of latest post when the tool is first launched.
- ```urlList```: The URLs to check for.

## How to use

The tool will display the latest posts on the page. Each post can be clicked to navigate to Reddit.  
There are also two buttons,  
- Reload: refresh the page immediately instead of wait for ```refreshInterval``` seconds.
- Mark read: mark all posts read. Otherwise, the posts will be always on the pages.

## What to improve

This tool is so simple with so little functions so there is not much room to improve.  
But the CSS is ugly, we may improve the CSS styles, though I myself only needs the result links rather than visual effect.
