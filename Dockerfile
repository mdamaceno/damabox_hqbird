FROM centos:7

RUN \
  yum -y update

RUN \
  yum install -y java-1.8.0-openjdk

RUN \
  yum install -y file openssl-devel initscripts sudo

COPY ./scripts/install_fb25_hqbird_server_2017r2.sh .

RUN chmod a+x install_fb25_hqbird_server_2017r2.sh

RUN bash -c "./install_fb25_hqbird_server_2017r2.sh"

COPY ./config/firebird/firebird.conf /opt/firebird/

RUN bash -c "echo \"process\" | /opt/firebird/bin/changeMultiConnectMode.sh"

EXPOSE 3050
EXPOSE 8083
EXPOSE 8765

RUN yum clean all

RUN bash -c "rm -rf /var/cache/yum"

COPY config/hqbird/conf /opt/hqbird/conf

COPY run.sh .

RUN chmod a+x run.sh

CMD ./run.sh
