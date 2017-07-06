FROM centos:7.2.1511
MAINTAINER Craig Willis (willis8@illinois.edu)

# For RServe
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum update -y && yum install -y \ 
    ed \
    git \
    libcurl \
    libcurl-devel \
    libpng-devel \
    libxml2-devel \
    mesa-libGL-devel \
    mesa-libGLU-devel \
    mysql-devel \
    postgresql-devel \
    openssl-devel \
    R \
    R-devel \
    wget 

# Install dependent packages for Dataverse
RUN R -q -e "source('https://bioconductor.org/biocLite.R'); biocLite('Rgraphviz')" && \
    R -q -e "source('https://bioconductor.org/biocLite.R'); biocLite('graph')" && \
    R -q -e "install.packages(c('AER'), INSTALL_opts=c('--no-test-load'), repos='http://cran.r-project.org', quiet=T, dependencies=T)" && \
    R -q -e "install.packages(c('Amelia'), INSTALL_opts=c('--no-test-load'), repos='http://cran.r-project.org', quiet=T, dependencies=T)" && \
    R -q -e "install.packages(c('devtools'), INSTALL_opts=c('--no-test-load'), repos='http://cran.r-project.org', quiet=T, dependencies=T)" && \
    R -q -e "install.packages(c('DescTools'), INSTALL_opts=c('--no-test-load'), repos='http://cran.r-project.org', quiet=T, dependencies=T)" && \
    R -q -e "install.packages(c('dplyr'), INSTALL_opts=c('--no-test-load'), repos='http://cran.r-project.org', quiet=T, dependencies=T)" && \
    R -q -e "install.packages(c('geepack'), INSTALL_opts=c('--no-test-load'), repos='http://cran.r-project.org', quiet=T, dependencies=T)" && \
    R -q -e "install.packages(c('jsonlite'), INSTALL_opts=c('--no-test-load'), repos='http://cran.r-project.org', quiet=T, dependencies=T)" && \
    R -q -e "install.packages(c('maxLik'), INSTALL_opts=c('--no-test-load'), repos='http://cran.r-project.org', quiet=T, dependencies=T)" && \
    R -q -e "install.packages(c('quantreg'), INSTALL_opts=c('--no-test-load'), repos='http://cran.r-project.org', quiet=T, dependencies=T)" && \
    R -q -e "install.packages(c('R2HTML'), INSTALL_opts=c('--no-test-load'), repos='http://cran.r-project.org', quiet=T, dependencies=T)" && \
    R -q -e "install.packages(c('rjson'), INSTALL_opts=c('--no-test-load'), repos='http://cran.r-project.org', quiet=T, dependencies=T)" && \
    R -q -e "install.packages(c('Rook'), INSTALL_opts=c('--no-test-load'), repos='http://cran.r-project.org', quiet=T, dependencies=T)" && \
    R -q -e "install.packages(c('Rserve'), INSTALL_opts=c('--no-test-load'), repos='http://cran.r-project.org', quiet=T, dependencies=T)" && \
    R -q -e "install.packages(c('VGAM'), INSTALL_opts=c('--no-test-load'), repos='http://cran.r-project.org', quiet=T, dependencies=T)" 


# Install pinned Zelig version
RUN cd /tmp &&  \
     git clone https://github.com/IQSS/Zelig.git -b v5.0-17 && \
     cd Zelig && \
     R -q -e "setwd('/tmp'); library(devtools); install('Zelig')" 

RUN /usr/sbin/groupadd -g 97 -o -r rserve  && \
    /usr/sbin/useradd -g rserve -o -r -d /usr/lib64/R/library -s /bin/bash -c "Rserve User" -u 97 rserve 

COPY Dockerfile /Dockerfile
COPY Rserv.* /tmp/

RUN cd /tmp/  && \
    install -o rserve -g rserve /tmp/Rserv.conf /etc/Rserv.conf && \ 
    install -m 0600 -o rserve -g rserve /tmp/Rserv.pwd /etc/Rserv.pwd 

EXPOSE 6311

CMD ["R", "CMD", "Rserve.dbg", "--vanilla"]
