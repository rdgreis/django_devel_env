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
	sudo chmod 777 -R $APPS/mysql/data
	MYSQL=$(docker run \
		-p 3306:3306 \
		-v $APPS/mysql/data:/var/lib/mysql \
		-v $APPS/mysql/logs:/logs \
		--name="devenv_MYSQL" \
		-e MYSQL_PASS="vagrant" \
		-d \
		rdgreis/mysql)
	echo "Started MYSQL in container $MYSQL"

    mkdir -p $APPS/sentry/etc
    while netstat -lnt | awk '$4 ~ /:3306$/ {exit 1}'; do sleep 1; done
    sleep 1
    echo "CREATE DATABASE IF NOT EXISTS devenv_SENTRY;" \
    | mysql -uadmin -pvagrant --protocol=TCP

	SENTRY=$(docker run \
		-p 9000:9000 \
		-e "SENTRY_NAME=devenv_SENTRY" \
		-e "SENTRY_USER=admin" \
		-e "SENTRY_PASS=vagrant" \
		-e "SENTRY_ENGINE=mysql" \
		-e "SENTRY_URL_PREFIX=http://localhost:9000" \
		-v $APPS/sentry/etc:/etc-sentry \
		--name="devenv_SENTRY" \
		--link devenv_MYSQL:db \
		-d \
		rdgreis/sentry)
	echo "Started SENTRY in container $SENTRY"
	while netstat -lnt | awk '$4 ~ /:9000$/ {exit 1}'; do sleep 1; done
	sleep 1
	echo "delete from auth_user where id=1;" \
    | mysql -uadmin -pvagrant -Ddevenv_SENTRY --protocol=TCP
    echo "insert into auth_user(id,
                                username,
                                email,
                                password,
                                is_staff,
                                is_active,
                                is_superuser)
                                values (1,
                                'admin',
                                'root@root.com',
                                'pbkdf2_sha256$10000$4mazdeya2WoA$7M/RIM7qHRoQyxpTxiFS0q6xfyG9yZHiHDWHGnbskrQ=',1,1,1);" \
    | mysql -uadmin -pvagrant -Ddevenv_SENTRY --protocol=TCP

	#SHIPYARD=$(docker run \
	#	-p 8005:8000 \
	#	-d \
	#	shipyard/shipyard)

	sleep 1

}

setup-mysql(){
    mkdir -p $APPS/mysql/data
    sudo chmod 777 -R $APPS/mysql/data
	MYSQL=$(docker run \
		-p 3306:3306 \
		-v $APPS/mysql/data:/var/lib/mysql \
        -v $APPS/mysql/logs:/logs \
		-e MYSQL_PASS="vagrant" \
		--rm \
		rdgreis/mysql \
		/bin/bash -c "/usr/bin/mysql_install_db")

    echo "Setting up MYSQL data."
	sleep 1

	MYSQL=$(docker run \
		-p 3306:3306 \
		-v $APPS/mysql/data:/var/lib/mysql \
        -v $APPS/mysql/logs:/logs \
		-e MYSQL_PASS="vagrant" \
		--rm \
		rdgreis/mysql \
		/bin/bash -c /create_mysql_admin_user.sh )

	echo "Setting up MYSQL admin user."
	sleep 1
}

update(){
	apt-get update
	apt-get install -y lxc-docker
	cp /vagrant/etc/docker.conf /etc/init/docker.conf

	docker pull rdgreis/redis
	docker pull rdgreis/memcached
	docker pull rdgreis/mysql
	docker pull rdgreis/sentry
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