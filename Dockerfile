FROM centos:7

RUN \
  yum -y update

RUN \
  yum install -y java-1.8.0-openjdk

RUN \
  yum install -y \
    file \
    openssl-devel \
    initscripts \
    sudo \
    libtommath \
    libicu

COPY ./scripts/install_fb30_hqbird_server_2017R2.sh .

RUN chmod a+x install_fb30_hqbird_server_2017R2.sh

RUN bash -c "./install_fb30_hqbird_server_2017R2.sh"

COPY ./config/firebird/firebird.conf /opt/firebird/

RUN bash -c "echo \"\" | /opt/firebird/bin/changeServerMode.sh"

EXPOSE 3050
EXPOSE 8082
EXPOSE 8765

RUN yum clean all

RUN bash -c "rm -rf /var/cache/yum"

COPY config/hqbird/conf /opt/hqbird/conf

RUN chmod a+w /opt/hqbird/conf/access.properties

COPY run.sh .

RUN chmod a+x run.sh

CMD ./run.sh
