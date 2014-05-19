

 Docker: a Software as a Service operating system level virtualization framework, by John Fink

----

If you were working in library IT in the last millennium, you'll likely remember what your server room looked like -- PC towers running Novell Netware attached to huge multi-disc CDROM arrays, refrigerator-sized Sun boxes, Digital AlphaServers running your library catalogue. To run most of the serious business of libraries, you needed serious equipment to go with them. Machine rooms were jumbled messes of shelves, wires and air conditioning units. With the advent of Linux running on microcomputers, these rooms got slightly smaller and maybe slightly less complex, but it wasn't until the early 2000s that the real sea change came for the server room -- the rapid adoption of easily implementable virtualization[^wikivirtualization], or the running of multiple discrete operating systems in a single machine.

Although virtualization in the modern sense actually happened as early as the 1960s with VMs for IBM System/360 machines[^registerhistory2] and both the 286 and 386 chips contained some species of virtualization[^registerhistory1] it wasn't until 2001 when VMWare introduced its x86 virtualization products that virtualization in the Linux space really took off. With technologies like KVM[^kvm] and Xen[^xen] looming large in the local space and products like Amazon Web Services[^aws] and the OpenStack[^openstack] framework claiming the cloud the old server room being a jumble of white box PCs and CDROM towers is more or less extinct; today, multiple virtual machines can be created out of minimal physical machines.

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

Modern virtualization schemes break down into largely one of two areas: *machine level virtualization* and *operating system level virtualization*. The systems already mentioned -- KVM, VMware, Xen, along with products like DOSBox[^dosbox], a multiplatform emulator specifically written to run DOS games -- are machine level emulators; that is, they attempt as much as possible to emulate everything about a computing environment in software, down to disk drives, RAM allocation, graphics, hard drive space, even processor type; it is entirely possible with some virtualization platforms, for instance, to emulate an ARM-based system like a Raspberry Pi[^raspiemulation] on an Intel-based platform like a desktop PC. However, when running multiple virtual machines on a single computer, you can quickly run into the limits of your machine by carving out, say, 1GB or 2GB of dedicated RAM for each instance of a VM or allocating large disk drives. Some of these problems can be worked around (mounting external drives as network shares, say) but some are more difficult (RAM, certainly). 

So, at a small-to-midrange IT shop that doesn't do a whole lot of software development -- as what you'd find traditionally in most libraries -- there might be a call for a handful of machine level virtualization instances. Maybe one for the library's web presence, another for the ILS, another to control images for patron workstations. These would be as much as possible drop-in replacements for those old white boxes; some instances, like for a given ILS, would be bound by convention or licensing to have as little deviation from a traditional install as possible; in others, the effort to customize an install to a virtualization framework might not be worth the payoff; gains in performance or convenience may very well be minimal.

Operating system level virtualization[^wikioslevel] is somewhat different; rather than try to emulate as much of an actual machine as possible, operating system level virtualization tries to share resources amongst instances; typical operating system level virtualization schemes will share RAM, disk space, and kernel with guest instances. Consequently, an arbitrary number of operating system level virtualization instances will be less likely to run out of host system resources than an equivalent number of machine level virtualization instances, but that flexibility comes at a cost. Because guest instances must share a kernel and therefore both a processor and operating system type[^type], you could not run, say, that virtual Raspberry Pi on x86 or Windows under a Linux host. Despite these limitations, operating system level virtualization is emerging as a very attractive workflow option for development work due to its ease of deployment and lightweight nature.

The modern development environment is one of constant iteration. Write code. Write tests. Code breaks. Write more code. Write more tests. Break more things. The less time that developers spend sitting around waiting for code to compile or interpret and tests to break means that they can spend more time doing the specific work that they're good at; imagine having to set up a new machine, even a virtual one, each time you wanted to test your code from scratch. The popular Virtualbox[^virtualbox] machine level virtualization framework, for instance, is very heavily GUI-oriented[^vboxscreenshot] and has therefore had an entire framework[^vagrant] built around it designed to make the creating and destroying of Virtualbox VMs scriptable. 

Docker[^dockerhome] is emerging as a very attractive implementation of  operating system level virtualization. Open source, its focus on DevOps[^devops] methodology, its ease of replication, version control-ish metaphors and re-use of machine images has it rapidly gaining mindshare amongst developers. But like most good open source projects, Docker incorporates a lot of existing Linux technologies along with new functionality;t it uses already existing technologies like copy-on-write union filesystems (usually AUFS[^aufs]) and Linux Containers[^lxc], and couples that with a number of features that make it developer centric (and therefore distinct from traditional virtual machines that attempt to hew as much as possible to the metaphor of *machine*): like deployment portability, versioning, re-use, and  repeatability[^shykesso]. 

These are features worth thinking about as they transform the notion of virtual machine provisioning from a time consuming, sysadmin-centric model to one focused more on a developer-oriented workflow; in particular, the git[^gitscm]-like nature of Docker's versioning system (with its diffs and tags).

At it's core, Docker is a virtualization framework focused around running applications and not around emulating hardware, which sounds facile at first read but underscores the critical difference between the two methodologies. The essential difference between machine level virtualization and Docker's operating system level virtualization is this: machine level VMs are about faithful *recreation* of hardware -- right down to RAM allotment, how many CPUs to assign, emulating NICs, and so forth -- and operating system level virtualization is about *applications*, not machines[^shykesso2]. And most of the time when we're developing, testing, and releasing software we care about applications and not really the specific hardware environment -- real or virtual -- that we're developing in, with the exception of, say, emulation of historical hardware[^simh] or other edge cases. When we write to mailing lists asking for help with Drupal, we don't say "I have a Dell PowerEdge 5100 with 4 Intel Core2Duo processors and 16GB of 70ns RAM and two Atheros 100GB NIC cards and I can't get this Drupal module to work correctly." Unless we have a pretty strong indicator that our problem is hardware bound, we focus on software. As it happens, this is what Docker does also. There is usually no reason to try to define for Docker how much memory it should have, how large its hard drive should be, or how much CPU it should take up; you don't generally do this for the code you write on your desktop either.

I first became interested in Docker in early 2013; I was talking about the Go[^Go] programming language with a colleague and asking where the killer Go applications were; he had mentioned that he had heard about a recently open source visualization framework called Docker that was written in Go and that it had been getting some traction; I filed this away under "things to investigate at some point" but it wasn't until I was wrestling with machine level virtualization on a desktop dating from 2007 that I saw the light -- this anemic box had trouble running two Virtualbox instances concurrently, but I tried to run Docker and ran over 40 docker containers on the same host without a noticeable drop in host system performance. 

But how does Docker look when you're actually running it? After the Docker software is installed[^dockerinstall], you're left with a primary binary ("docker") with which you can start, stop, import, export, and do other[^dockercli] operations. 

Here's an example of a Docker host running a few containers.
```
CONTAINER ID        IMAGE                     COMMAND             CREATED             STATUS              PORTS                                        NAMES
1bc191f4cdbb        bedework:latest           supervisord -n      11 days ago         Up 11 days          0.0.0.0:8080->8080/tcp                       sick_newton         
b58946da298c        papyrus-demo:port6000     /bin/bash           13 days ago         Up 13 days          3000/tcp, 6000/tcp, 0.0.0.0:6001->6001/tcp   drunk_bell          
c90c0a6be88f        saucy-csclub:latest       /bin/bash           13 days ago         Up 13 days          0.0.0.0:9999->9999/tcp                       angry_shockley      
e5a0f8a71f7e        papyrus-demo:in-process   /start.sh           2 weeks ago         Up 13 days          0.0.0.0:3000->3000/tcp                       mad_poincare        
f752161937c6        ldap_update_pw:latest     supervisord -n      5 weeks ago         Up 13 days          0.0.0.0:5000->5000/tcp                       distracted_nobel    
33cf9eb89073        catmandu:in-process       /bin/bash           6 weeks ago         Up 13 days                                                       cranky_mccarthy     
```

Individual docker instances are split up into *images* and *containers*. Containers are running instances of images. You can have several containers that come from 

Wordpress is the white lab rat of library software -- used everywhere, well supported, well understood, generally easy to take care of, and with a huge host of ancillary software behind it. In the spring of 2013 I started building a Docker wordpress container manually; by launching a single Docker container running a bash shell and doing the normal apt-gets and vim editing of config files. In August of 2013 I started work on docker-wordpress[^dwgithub], a Docker image that contains Wordpress, Apache, MySQL and supervisord[^supervisord], and is a fairly good, self-contained example of a moderately complex Docker application.

The key problem with setting up Wordpress in a normal fashion, freezing it in a Docker image, and then running that wherever is that the configuration would remain the same across containers -- same MySQL passwords, same Wordpress salts and keys in PHP. Ideally every time docker-wordpress is run there should be different values for all the fiddly Wordpress configuration options, so docker-wordpress contains start.sh[^startsh], which runs a series of commands at first inception to set values for things like salts in wp-config.php:

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

This ensures that different values for important variables get slotted in each time docker-wordpress is first run; combining this with the output from the initial build[^gistbuild] from source means a fairly long startup time, but subsequent runs usually take less than 30 seconds, and rebuilds (which can be cached) really only need to happen when major updates to component software happen. Running the docker-wordpress image is a fairly simple affair, and new containers take about a second to spawn, after which they can be accessed via internal IPs or given outward-facing ports on the host machine.

Porting more esoteric applications to Docker is not yet an easy procedure. Docker wants to run things in foreground processes, making it necessary to convert common programs like MySQL and Apache from their usual background modes to foreground ones, and Docker's focus on one application per container (achieved in docker-wordpress and many other Docker applications through judicious use of supervisord) makes, say, running an ILS like Evergreen somewhat problematic. However, with Docker rapidly approaching a stable state[^docker10] and more focus on making applications work with Docker-style operating system level virtualization as well as more traditional VMs and physical servers as a probable result, who wouldn't be happy to see a huge installation procedure[^evergreenbuh] boiled down to a single command?




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

[^dwgithub]: http://github.com/jbfink/docker-wordpress

[^supervisord]: http://supervisord.org/

[^startsh]: https://github.com/jbfink/docker-wordpress/blob/master/start.sh

[^gistbuild]: https://gist.github.com/jbfink/9054707

[^docker10]: http://blog.docker.io/2013/08/getting-to-docker-1-0/

[^evergreenbuh]: http://docs.evergreen-ils.org/2.5/_installing_the_evergreen_server.html