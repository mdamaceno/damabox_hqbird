FROM centos:7

RUN \
  yum -y update

RUN \
  yum install -y java-1.8.0-openjdk

RUN \
  yum install -y file openssl-devel initscripts sudo

COPY ./install_fb25_hqbird_server_2017r2.sh .

RUN chmod a+x install_fb25_hqbird_server_2017r2.sh

RUN bash -c "./install_fb25_hqbird_server_2017r2.sh"

COPY firebird.conf /opt/firebird/

RUN bash -c "echo \"thread\" | /opt/firebird/bin/changeMultiConnectMode.sh"

EXPOSE 3050
EXPOSE 8082
EXPOSE 8765

COPY run.sh .

RUN chmod a+x run.sh

CMD ./run.sh
