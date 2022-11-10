FROM centos:centos7.2.1511
MAINTAINER adrianp@stindustries.net

# If you need to use a proxy to get to the internet, build with:
#   docker build --build-arg CURL_OPTIONS="..."
#
# The default is empty (no special options).
#
ARG CURL_OPTIONS=""

# Prep environment
#
RUN yum -y install deltarpm && yum -y update

# Install build utils
#
RUN touch /var/lib/rpm/* && \
    yum -y install bison gnutls-devel gcc libidn-devel gcc-c++ bzip2 && \
    yum clean all
