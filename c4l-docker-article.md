

Docker Article Title, by John Fink

----

If you were working in library IT in the last millenium, you'll likely remember what your server room looked like -- PC towers running Novell Netware attached to huge multi-disc CDROM arrays, refrigerator-sized Sun boxes, Digital AlphaServers running INNOPAC. To run most of the serious business of libraries, you needed serious equipment to go with them. Machine rooms were jumbled messes of shelves, wires and air conditioning units. With the advent of Linux running on microcomputers, these rooms got slightly smaller and maybe slightly less complex, but it wasn't until the early 2000s that the real sea change came for the server room -- the rapid adoption of easily implementable virtualization, or the running of multiple discrete operating systems in a single machine.

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





[^registerhistory2]: http://www.theregister.co.uk/2011/07/14/brief_history_of_virtualisation_part_2/

[^registerhistory1]: http://www.theregister.co.uk/2011/07/11/a_brief_history_of_virtualisation_part_one/

[^kvm]: http://linux-kvm.org

[^xen]: http://www.xenproject.org/

[^aws]: http://aws.amazon.com

[^openstack]: http://www.openstack.org

[^dosbox]: http://www.dosbox.com

[^raspiemulation]: http://cronicasredux.blogspot.ca/2011/09/installing-and-running-debian-armel-on.html