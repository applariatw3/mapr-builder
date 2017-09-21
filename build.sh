#!/bin/sh
#mapr server entrypoint script

export JAVA_HOME=/usr/lib/jvm/java-openjdk
export MAPR_HOME=/opt/mapr
export MAPR_ENVIRONMENT=docker

#set environment
MAPR_PKG_GROUP=( $MAPR_BUILD )
PACKAGES=
CONTAINER_PORTS=${MAPR_PORTS:-22}
MAPR_MONITORING=${MAPR_MONITORING:-true}
MAPR_LOGGING=${MAPR_LOGGING:-true}
MAPR_INSTALLER_DIR=${MAPR_INSTALLER_DIR:-$MAPR_HOME/installer}
MAPR_CONTAINER_DIR=$MAPR_HOME/installer/docker
MAPR_LIB_DIR=${MAPR_LIB_DIR:-$MAPR_HOME/lib}
MAPR_VERSION_CORE=${MAPR_VERSION_CORE:-5.2.2}
MAPR_VERSION_MEP=${MAPR_VERSION_MEP:-3.0.1}
MAPR_PKG_URL=${MAPR_PKG_URL:-http://package.mapr.com/releases}
MAPR_CORE_URL=$MAPR_PKG_URL
MAPR_ECO_URL=$MAPR_PKG_URL
SPRVD_CONF=/etc/supervisor/conf.d/supervisord.conf

START_ZK=0
START_WARDEN=1

add_package() {
    PACKAGES="$PACKAGES mapr-$1"
}

for p in "${MAPR_PKG_GROUP[@]}"; do
	add_package $p
	
	[ "$p" = zk ] && START_ZK=1
done

echo "Installing the following pakcages in image: $PACKAGES"

/opt/mapr/installer/docker/mapr-setup.sh -r http://package.mapr.com/releases container core $PACKAGES

#Add entries to supervisord.conf
if [ $START_ZK -eq 1 ]; then
	cat >> $SPRVD_CONF << EOC

[program:mapr-zookeeper]
command=/etc/init.d/mapr-zookeeper start
autorestart=false
EOC

echo "Added zookeeper to start list"
fi

if [ $START_WARDEN -eq 1 ]; then
	cat >> $SPRVD_CONF << EOC

[program:mapr-warden]
command=/etc/init.d/mapr-warden start
autorestart=false
EOC

echo "Added warden to start list"
fi


exit 0



