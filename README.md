Django Development Environment
=============================

My default Django development stack for Vagrant+docker.


Inspired, based and forked from:
* [docker_public](https://github.com/relateiq/docker_public)
* [docker-sentry](https://github.com/grue/docker-sentry)
* [tutum-docker-mysql](https://github.com/tutumcloud/tutum-docker-mysql)
* [docker-memcached](https://index.docker.io/u/borja/docker-memcached/)

Installation:
-------------

Download and install [VirtualBox](http://www.virtualbox.org/)

Download and install [Vagrant](http://vagrantup.com/)

Clone this repository

Go to the repository folder and launch the box

    $ cd [repo]
    $ vagrant up
    $ vagrant ssh

Setting up the env
-------------------

You should run this only once.

    $ devenv.sh update
    $ devenv.sh setup-mysql


Starting the env
-----------------

    $ devenv.sh start


What's inside:
--------------

Installed software:

* Django custom settings.py sample
* Redis
* MySQL
* Memcached
* Sentry
