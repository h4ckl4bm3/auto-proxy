#!/bin/bash

# script variables
hostidx=0
hostmap=""
backends=""

if [ -z ${var+HOSTCONFIG} ]; then 

	configs=$(echo $HOSTCONFIG | tr ";" "\n")

	# Parses the environmental HOSTCONFIG and sets up the host mappings to backend containers.
	
	for pair in $configs
	do
		IFS=: read -r host dockerhost port <<< "$pair"

		echo "Mapping $host to $dockerhost:$port"
		
		hostidx=$((hostidx+1))

		hostmap="$hostmap
    use_backend host${hostidx}_container if { hdr(host) -i $host }"		
		
		backends="$backends
		
backend host${hostidx}_container
	option httpclose
	option forwardfor
	cookie JSESSIONID prefix
	server host$hostid_container $dockerhost:$port"
		
	done
	
	# Writes out the config file.
	
	echo "#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    log         127.0.0.1 local2
    maxconn     4000
    daemon

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000
	default-server 			init-addr none
	
frontend http-in
    bind *:80
    $hostmap
	
$backends" >> /usr/local/etc/haproxy/haproxy.cfg


else 

	echo "HOSTCONFIG environmental variable is set to '$var'"; 

fi