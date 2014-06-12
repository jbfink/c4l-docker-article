
Docker: a Software as a Service, operating-system level virtualization framework, by John Fink

----

If you were working in library IT in the last millennium, you'll likely remember what your server room used to look like. PC towers running Novell Netware attached to huge multi-disc CDROM arrays. Refrigerator-sized Sun boxes. Digital AlphaServers running your library catalogue. To run most of the serious business of libraries, you needed serious equipment, and, as a result, machine rooms were often jumbled messes of shelves, wires and air conditioning units. With the advent of Linux running on microcomputers, these rooms became slightly smaller and maybe slightly less complex, but it wasn't until the early 2000s that the real sea change came for the server room -- the rapid adoption of easily implementable virtualization[^wikivirtualization], which allowed running multiple discrete operating systems on a single machine.

Although virtualization in the modern sense actually happened as early as the 1960s with VMs for IBM System/360 machines[^registerhistory2], and both the 286 and 386 chips contained some species of virtualization[^registerhistory1], it wasn't until 2001 when VMWare introduced its x86 virtualization products that Linux-based virtualization really took off. With technologies like KVM[^kvm] and Xen[^xen] looming large for local deployment and products like Amazon Web Services[^aws] and the OpenStack[^openstack] framework claiming the cloud, the jumbled, messy, white-box-PC-and-CDROM-tower-laden server room is more or less extinct; today, you can create multiple virtual machines out of minimal physical machines.

```
virsh # list
 Id Name                 State
----------------------------------
  1 trotsky              running
  2 eris                 running
  3 funhouse             running
  4 gorgar               running
  5 shoah                running
  6 balder2              running
  7 asgard               running
  
```
(above: a listing of virtual machines on a single server at the author's workplace)

Virtualization in Libraries
===========================

Modern virtualization needs for libraries vary greatly from institution to institution. A small to midrange IT shop that doesn't do a whole lot of software development -- as what you'd find traditionally in many libraries -- might only require a handful of virtual machines. It may need one for the library's web presence, one for the ILS, and one to control images for patron workstations, for example. As much as possible, these would be drop-in replacements for those old white boxes. Some instances, like for a given ILS, would be bound by convention or licensing to have as little deviation from a traditional install as possible. For others, the effort to customize an install to a virtualization framework might not be worth the payoff; gains in performance or convenience may very well be minimal.

Libraries with staff who develop software likely have more complex requirements. The modern development environment is one of constant iteration. Write code. Write tests. Code breaks. Write more code. Write more tests. Break more things. Imagine manually having to set up a new machine, even a virtual one, each time you wanted to test your code from scratch. Anything that makes this process more efficient lets developers spend more time doing the specific work that they're good at. The popular Virtualbox[^virtualbox] software, for instance, is very heavily GUI-oriented[^vboxscreenshot] and has therefore had an entire framework[^vagrant] built around it designed to make the creating and destroying of Virtualbox VMs scriptable.

Typical library virtualization schemes mostly utilize *machine-level virtualization*. The systems already mentioned -- KVM, VMware, Xen, Virtualbox, along with products like DOSBox[^dosbox], a multiplatform emulator specifically written to run DOS games -- are machine-level emulators. They attempt to emulate as much as possible about a computing environment in software, down to disk drives, RAM allocation, graphics, hard drive space, and even processor type. Some machine-level virtualization platforms, for instance, make it possible to emulate an ARM-based system like a Raspberry Pi[^raspiemulation] on an Intel-based platform like a desktop PC. But this type of virtualization can be resource-intensive and inefficient. When running multiple virtual machines on a single computer, you might quickly run into the limits of the physical machine by allocating large disk drives or carving out multiple Gigabytes of dedicated RAM for each VM instance. Workarounds for some of these problems are relatively simple (like mounting external drives as network shares), but others are more difficult (such as dealing with limited RAM).

Enter operating system-level virtualization[^wikioslevel], which tries to share resources amongst instances rather than emulate as much of an actual machine as possible. Typical operating system-level virtualization schemes will share RAM, disk space, and kernel with guest instances. Consequently, an arbitrary number of operating system-level virtualization instances will be less likely to run out of host system resources than an equivalent number of machine-level virtualization instances. But that flexibility comes at a cost. Because guest instances must share a kernel and therefore both a processor and operating system type[^type], you could not run that virtual Raspberry Pi on x86 or Windows under a Linux host. Despite these limitations, operating system level virtualization is emerging as a very attractive workflow option for development work due to its ease of deployment and lightweight nature.

Virtualization with Docker
==========================

Docker[^dockerhome], an open-source implementation of operating system-level virtualization, is rapidly gaining mindshare amongst developers. Like most good open source projects, Docker incorporates a lot of existing Linux technologies along with new functionality; it uses already existing technologies like copy-on-write union filesystems (usually AUFS[^aufs]) and Linux Containers[^lxc], and it couples that with a number of features that make it developer-centric (and therefore distinct from traditional virtual machines that attempt to hew as much as possible to the metaphor of *machine*): like deployment portability, versioning, re-use, and repeatability[^shykesso]. 

These features are worth considering. They transform the notion of virtual machine provisioning from a time-consuming, sysadmin-centric model to one focused more on a developer-oriented workflow,[^devops] as evidenced in particular by the git[^gitscm]-like nature of Docker's versioning system (with its diffs and tags).

At its core, Docker is a virtualization framework focused around running applications and not around emulating hardware, which seems facile at first but underscores the critical difference between operating system-level virtualization software like Docker and machine-level virtualization. Machine-level VMs are about faithful recreation of hardware -- right down to RAM allotment, how many CPUs to assign, emulating NICs, and so forth -- and operating system level virtualization is about *applications*, not machines[^shykesso2]. Most of the time when we're developing, testing, and releasing software we care about applications and not really the specific hardware environment -- real or virtual -- that we're developing in, perhaps except with emulating historical hardware[^simh] and other edge cases. When we write to mailing lists asking for help with Drupal, we don't say "I have a Dell PowerEdge 5100 with 4 Intel Core2Duo processors and 16GB of 70ns RAM and two Atheros 100GB NIC cards and I can't get this Drupal module to work correctly." Unless we have a pretty strong indicator that our problem is hardware bound, we focus on software. As it happens, this is what Docker does also. There is usually no reason to try to define for Docker how much memory it should have, how large its hard drive should be, or how much CPU it should take up; you don't generally do this for the code you write on your desktop either. 

In practice, this means a computer running Docker can run many more simultaneous virtual instances than the same computer running typical virtual machines. To illustrate: while wrestling with machine-level virtualization on an anemic desktop dating from 2007, I had trouble running two Virtualbox instances concurrently. But, on the same host, I was able to run over 40 Docker containers without a noticeable drop in host system performance. 

Running Docker
--------------

What does it look like to run Docker? After the Docker software is installed[^dockerinstall], you're left with a primary binary ("docker") with which you can start, stop, import, export, and do other[^dockercli] operations. 

Here's an example of a Docker host running a few containers, which we can see by running docker ps on the comand line.
```
CONTAINER ID        IMAGE                     COMMAND             CREATED             STATUS              PORTS                                        NAMES
1bc191f4cdbb        bedework:latest           supervisord -n      11 days ago         Up 11 days          0.0.0.0:8080->8080/tcp                       sick_newton         
b58946da298c        papyrus-demo:port6000     /bin/bash           13 days ago         Up 13 days          3000/tcp, 6000/tcp, 0.0.0.0:6001->6001/tcp   drunk_bell          
c90c0a6be88f        saucy-csclub:latest       /bin/bash           13 days ago         Up 13 days          0.0.0.0:9999->9999/tcp                       angry_shockley      
e5a0f8a71f7e        papyrus-demo:in-process   /start.sh           2 weeks ago         Up 13 days          0.0.0.0:3000->3000/tcp                       mad_poincare        
f752161937c6        ldap_update_pw:latest     supervisord -n      5 weeks ago         Up 13 days          0.0.0.0:5000->5000/tcp                       distracted_nobel    
33cf9eb89073        catmandu:in-process       /bin/bash           6 weeks ago         Up 13 days                                                       cranky_mccarthy     
```

Individual docker instances are split up into *images* and *containers*. Containers run instances of images. You can have several containers that come from the same image or variants of that image. In the above list, we can see that container id b58946da298c and e5a0f8a71f7e are running versions of the image "papyrus-demo," demonstrating that images can have tags that act similarly to git tags, representing different states of a common image. In the papyrus-demo's image, there's a tag "in-process" And a tag "port6000"; an image without a distinct tag is always "latest".

<!--- I like the idea you mentioned last week of including a simple step-by-step example. I'm guessing it would go somewhere in here and replace these paragraphs because it would illustrate the same concepts. -->

It's important to note that docker images are almost always made up of other images and layered on top of one another, rather like git commits are. When docker images are built using a Dockerfile[^dockerfile] each actionable step in that Dockerfile creates another layer and the sum total of those layers represents the final image. Dockerfiles themselves are simple-to-parse lists of actions, like so:

```
FROM ubuntu:latest
MAINTAINER John Fink <john.fink@gmail.com>
RUN apt-get update # Mon Jan 27 11:35:22 EST 2014
RUN apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-client mysql-server apache2 libapache2-mod-php5 pwgen python-setuptools vim-tiny php5-mysql openssh-server sudo php5-ldap
RUN easy_install supervisor
ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./supervisord.conf /etc/supervisord.conf
RUN echo %sudo  ALL=NOPASSWD: ALL >> /etc/sudoers
RUN rm -rf /var/www/
ADD http://wordpress.org/latest.tar.gz /wordpress.tar.gz
RUN tar xvzf /wordpress.tar.gz 
RUN mv /wordpress /var/www/
RUN chown -R www-data:www-data /var/www/
RUN chmod 755 /start.sh
RUN chmod 755 /etc/apache2/foreground.sh
RUN mkdir /var/log/supervisor/
RUN mkdir /var/run/sshd
EXPOSE 80
EXPOSE 22
CMD ["/bin/bash", "/start.sh"]
```

This Dockerfile builds a complete Wordpress environment, including a MySQL database, and finishes the image up in about 15 seconds if it can use some cached layers. From scratch there's a lot of time from running the apt-get steps, but a slow initial build is an acceptable price to pay for the ability to run subsequent builds in under a minute, making rapid iterations possible.

A Real-World Example
--------------------

In the spring of 2013 I started building a Docker Wordpress container with an eye towards using it in-house for development projects. Why Wordpress? Wordpress is the white lab rat of library software -- it's used everywhere, is well supported, is well understood, is generally easy to take care of, and has a huge host of ancillary software behind it. It's a good real-world example for testing Docker's capabilities. Initially I built the container manually -- that is, by launching a single Docker container running a bash shell and basically performing the steps in the above Dockerfile by hand (doing the normal apt-gets and vim editing of config files). I put it up on docker index[^dockerindex] and was contacted by a few folks in email about how I built it. In August of 2013 I started work on docker-wordpress[^dwgithub], a structured way of building what I had done manually that people could play with and build on.

The key problem with setting up Wordpress in a normal fashion, freezing it in a Docker image, and then running that elsewhere is that the configuration would remain the same across containers -- same MySQL passwords and Wordpress salts and keys in PHP. Ideally every time docker-wordpress is run there should be different values for all the fiddly Wordpress configuration options, so docker-wordpress contains start.sh[^startsh], which runs a series of commands at first inception to set values for things like salts in wp-config.php:

```
sed -e "s/database_name_here/$WORDPRESS_DB/
s/username_here/$WORDPRESS_DB/
s/password_here/$WORDPRESS_PASSWORD/
/'AUTH_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'SECURE_AUTH_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'LOGGED_IN_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'NONCE_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'AUTH_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'SECURE_AUTH_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'LOGGED_IN_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'NONCE_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/" /var/www/wp-config-sample.php > /var/www/wp-config.php
```

This ensures that different values for important variables get loaded each time docker-wordpress is first run. Combining this with the output from the initial build[^gistbuild] from source means a fairly long startup time, but subsequent runs usually take less than 30 seconds, and rebuilds (which can be cached) really only need to happen when major updates to component software happen. Running the docker-wordpress image is a fairly simple affair, and new containers take about a second to spawn, after which they can be accessed via internal IPs or given outward-facing ports on the host machine.

Docker-wordpress has a great advantage in that it's one image, can be run in one container, and is easy to understand. But it would be a mistake to consider it a good model for a production-type instance. In particular, its slapdash approach to logging (something Logstash[^logstash] could go a long way towards fixing) and inclusion of a local MySQL instance make it a difficult sell for a production environment as it is currently written.  Consider running 20 docker-wordpresses, each with its own database; it would make much more sense to have a single MySQL server serving multiple Wordpress instances.

Conclusion
==========

As the Docker developers state upfront, the software has not yet reached version 1.0 and is still under heavy development. <!--- Probably need a citation here linking to that statement. --> As a result, some features are still unstable. For example, Docker has had a historical disadvantage in depending on a kernel feature (AUFS) that, notably, is not part of the standard Linux kernel, making implementations on non-Ubuntu systems somewhat problematic. This was solved in more recent versions[^docker07] by introducing a storage layer API. However, Docker will probably reach a steady 1.0 with a corresponding stable API by the end of 2014; until then, it's probably best relegated to non-critical roles.

Furthermore, porting more esoteric applications to Docker is not yet an easy procedure. Docker wants to run things in foreground processes, making it necessary to convert common programs like MySQL and Apache from their usual background modes to foreground ones, and Docker's focus on one application per container (achieved in docker-wordpress and many other Docker applications through judicious use of supervisord) makes, say, running an ILS like Evergreen somewhat problematic. <!--- Expound on this. -->

Despite the work yet to be done on Docker, it is rapidly approaching a stable state[^docker10] and shows definite promise for incorporating into libraries' virtualization activities. For software development, when programmers check their code into git, a Dockerfile could be included in the source code, allowing for quick testing of code on remote servers or as a demonstration tool to let others quickly bring up their own versions of an application without having to worry about specific building instructions or dependency management. Docker could be used as a backup strategy -- as part of a backup script for a library's web site, a Docker image could be built for a rapid deployment in case of service outage. And for regular systems administration tasks, who wouldn't be happy to see a huge installation procedure[^evergreenbuh] boiled down to a single command?



[^wikivirtualization]: http://en.wikipedia.org/wiki/Virtualization

[^registerhistory2]: http://www.theregister.co.uk/2011/07/14/brief_history_of_virtualisation_part_2/

[^registerhistory1]: http://www.theregister.co.uk/2011/07/11/a_brief_history_of_virtualisation_part_one/

[^kvm]: http://linux-kvm.org

[^xen]: http://www.xenproject.org/

[^aws]: http://aws.amazon.com

[^openstack]: http://www.openstack.org

[^dosbox]: http://www.dosbox.com

[^raspiemulation]: http://cronicasredux.blogspot.ca/2011/09/installing-and-running-debian-armel-on.html

[^wikioslevel]: http://en.wikipedia.org/wiki/Operating_system-level_virtualization

[^type]: You can run different Linux *versions* even though you might commonly consider them different OSs; a Red Hat guest could run under an Ubuntu host, for instance.

[^virtualbox]: http://virtualbox.org

[^vboxscreenshot]: https://www.virtualbox.org/attachment/wiki/Screenshots/gnome.png

[^vagrant]: http://vagrantup.com

[^dockerhome]: http://docker.io

[^devops]: http://radar.oreilly.com/2012/06/what-is-devops.html

[^aufs]:  http://www.thegeekstuff.com/2013/05/linux-aufs/

[^lxc]: http://linuxcontainers.org/

[^shykesso]: http://stackoverflow.com/a/18208445/380282

[^gitscm]: http://git-scm.com/

[^shykesso2]: https://stackoverflow.com/a/22370529

[^simh]: http://simh.trailing-edge.com/

[^go]: http://golang.org

[^dockerinstall]: https://www.docker.io/gettingstarted/#h_installation

[^dockercli]: http://docs.docker.io/reference/commandline/cli/

[^dockerfile]: http://docs.docker.io/reference/builder/

[^dockerindex]: https://index.docker.io/u/jbfink/wordpress/

[^dwgithub]: http://github.com/jbfink/docker-wordpress

[^startsh]: https://github.com/jbfink/docker-wordpress/blob/master/start.sh

[^gistbuild]: https://gist.github.com/jbfink/9054707

[^logstash]: http://logstash.net/

[^docker07]: http://blog.docker.io/2013/11/docker-0-7-docker-now-runs-on-any-linux-distribution/

[^docker10]: http://blog.docker.io/2013/08/getting-to-docker-1-0/

[^evergreenbuh]: http://docs.evergreen-ils.org/2.5/_installing_the_evergreen_server.html