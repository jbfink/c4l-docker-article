c4l-docker-article
==================
(note: none of this would have happened without Jason Thomale's editing work; thanks so much, Jason!)


An article for [code4lib journal](http://journal.code4lib.org/) about virtualization in general and [Docker](http://docker.io) in particular. I am doing the writing in [StackEdit](https://stackedit.io) so the commit messages for the article text will not be that descriptive. Most of the action will probably be in the [from-stackedit](https://github.com/jbfink/c4l-docker-article/tree/from-stackedit) branch until things firm up a little more. Also, an outline for this article appears as a [gist](https://gist.github.com/jbfink/8789677) so you can take a look at that as well. 

This is licensed under a [CC-BY](http://creativecommons.org/licenses/by/2.5/ca/) license, so please feel free to adopt/steal/share/post on a tree/skywrite in whatever way most delights you.

As a fun bonus (thanks @ruebot) this repo can now build a simple Docker container that will serve the article. To do that, just do:

```
docker build -rm -t <yourname>/c4l-article-docker git://github.com/jbfink/c4l-docker-article.git
```

Run as:

```
docker run -Pd <yourname>/c4l-docker-article
```

Then check docker ps for the exposed port and hit it with a web browser! There! Wasn't that much easier than just going directly to the article itself????



![cc-by-sa](http://i.creativecommons.org/l/by-sa/3.0/88x31.png)
