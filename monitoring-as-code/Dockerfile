FROM centos:centos7.2.1511

 ARG CURL_OPTIONS=""

 # Prep environment
 #
 # RUN yum -y install deltarpm && yum -y update

 # Install build utils
 #
 RUN touch /var/lib/rpm/* && \
     yum -y install bison && \
     yum clean all
