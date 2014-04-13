#/bin/bash
set -e

DIR="$( cd "$( dirname "$0" )" && pwd )"
APPS=${APPS:-~/mnt/apps}

killz(){
	echo "Killing all docker containers:"
	docker ps
	ids=`docker ps | tail -n +2 |cut -d ' ' -f 1`
	echo $ids | xargs docker kill
	echo $ids | xargs docker rm
}

stop(){
	echo "Stopping all docker containers:"
	docker ps
	ids=`docker ps | tail -n +2 |cut -d ' ' -f 1`
	echo $ids | xargs docker stop
	echo $ids | xargs docker rm
}

start(){
	mkdir -p $APPS/redis/data
	mkdir -p $APPS/redis/logs
	REDIS=$(docker run \
		-p 6379:6379 \
		-v $APPS/redis/data:/data \
		-v $APPS/redis/logs:/logs \
		--name="devenv_REDIS" \
		-d \
		rdgreis/redis)
	echo "Started REDIS in container $REDIS"

	mkdir -p $APPS/memcached/data
	mkdir -p $APPS/memcached/logs
	MEMCACHED=$(docker run \
		-p 11211:11211 \
		--name="devenv_MEMCACHED" \
		-d \
		rdgreis/memcached)
	echo "Started MEMCACHED in container $MEMCACHED"

	mkdir -p $APPS/mysql/data
	mkdir -p $APPS/mysql/logs
	MYSQL=$(docker run \
		-p 3306:3306 \
		-v $APPS/mysql/data:/var/lib/mysql \
		--name="devenv_MYSQL" \
		-e MYSQL_PASS="vagrant" \
		-d \
		rdgreis/mysql)
	echo "Started MYSQL in container $MYSQL"

    mkdir -p $APPS/sentry/etc
	SENTRY=$(docker run \
		-p 9000:9000 \
		-e "SENTRY_NAME=devenv_SENTRY" \
		-e "SENTRY_USER=root" \
		-e "SENTRY_PASS=vagrant" \
		-e "SENTRY_ENGINE=mysql" \
		-v $APPS/sentry/etc:/etc-sentry \
		--name="devenv_SENTRY" \
		--link devenv_MYSQL:db \
		-d \
		rdgreis/sentry)
	echo "Started SENTRY in container $SENTRY"

	#SHIPYARD=$(docker run \
	#	-p 8005:8000 \
	#	-d \
	#	shipyard/shipyard)

	sleep 1

}

setup-mysql(){
    mkdir -p $APPS/mysql/data
	MYSQL=$(docker run \
		-p 3306:3306 \
		-v $APPS/mysql/data:/var/lib/mysql \
		-e MYSQL_PASS="vagrant" \
		-d \
		rdgreis/mysql \
		/bin/bash -c "/usr/bin/mysql_install_db")
	echo "Setting up MYSQL data."
	sleep 1
}

update(){
	apt-get update
	apt-get install -y lxc-docker
	cp /vagrant/etc/docker.conf /etc/init/docker.conf

	docker pull rdgreis/redis
	docker pull rdgreis/memcached
	docker pull rdgreis/sentry
	docker pull rdgreis/mysql
	#docker pull shipyard/shipyard
}

case "$1" in
	restart)
		killz
		start
		;;
	start)
		start
		;;
	stop)
		stop
		;;
	kill)
		killz
		;;
	update)
		update
		;;
	status)
		docker ps
		;;
	setup-mysql)
	    setup-mysql
	    ;;
	*)
		echo $"Usage: $0 {start|stop|kill|update|restart|status|ssh|setup-mysql}"
		RETVAL=1
esac