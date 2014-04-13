FROM ubuntu

RUN dpkg --configure -a --force-all
RUN apt-get clean
RUN apt-get update

RUN apt-get install -y language-pack-en
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

RUN apt-get install -y openssh-server git-core libxml2-dev curl python build-essential make gcc python-dev wget python2.7-dev
RUN apt-get install -y libpq-dev
RUN apt-get install -y mysql-client
RUN apt-get install -y libmysqlclient-dev
RUN apt-get install -y postgresql-client-9.1 postgresql-client-common libpq5
RUN apt-get install -y libpq-dev

RUN wget http://python-distribute.org/distribute_setup.py
RUN python distribute_setup.py

RUN wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py
RUN python get-pip.py

RUN pip install psycopg2
RUN pip install sentry
RUN pip install MySQL-python

EXPOSE 9000

ADD sentry.conf.py /sentry.conf.py
ADD admin_user.json /initial_data.json

ENTRYPOINT ["/usr/local/bin/sentry", "--config=/sentry.conf.py"]

CMD ["start"]