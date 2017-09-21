FROM applariat/mapr-base:5.2.2_3.0.1
#Starting from mapr base image
#ARG MAPR_PACKAGES="fileserver nodemanager tasktracker"

ARG artifact_root="."

ENV MAPR_BUILD=${MAPR_PACKAGES:-"fileserver nodemanager tasktracker"}
ENV MAPR_HOME="/opt/mapr"
ENV container docker

#Copy files into place
COPY $artifact_root/build.sh /build.sh
COPY $artifact_root/entrypoint.sh /entrypoint.sh
COPY $artifact_root/code/ /code/
COPY $artifact_root/config/ /config/

#Install mapr packages
RUN chmod +x /build.sh /entrypoint.sh && /build.sh

WORKDIR $MAPR_HOME

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
