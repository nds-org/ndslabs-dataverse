FROM ndslabs/dataverse-rserve:4.2.3
MAINTAINER Craig Willis (willis8@illinois.edu)


# For Two-Ravens
RUN touch /var/lib/rpm/* && yum install -y rpm-build httpd-devel libapreq2 libapreq2-devel nc


# Build RApache 
RUN cd /tmp && wget https://github.com/jeffreyhorner/rapache/archive/v1.2.6.tar.gz -O rapache-1.2.6.tar.gz  && \
	tar xzvf rapache-1.2.6.tar.gz rapache-1.2.6/rpm/rapache.spec --strip-components 2 && \
	mkdir -p ~/rpmbuild/SOURCES && \
	mkdir -p ~/rpmbuild/SPECS && \
	mv -f rapache-1.2.6.tar.gz ~/rpmbuild/SOURCES/ && \
	mv -f rapache.spec ~/rpmbuild/SPECS/ && \
 	rpmbuild -ba ~/rpmbuild/SPECS/rapache.spec && \
 	cd ~/rpmbuild/RPMS/x86_64/ && \
	rpm -ivh rapache-1.2.6-rpm0.x86_64.rpm 

# Download TwoMasters
RUN cd /tmp && rm -f master.zip && \
	wget https://github.com/IQSS/TwoRavens/archive/master.zip && \
	unzip master.zip && \
	rm -f master.zip && \
	mv TwoRavens-master /var/www/html/dataexplore

EXPOSE 80

COPY Dockerfile /Dockerfile
COPY start-tworavens /
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["tworavens"]
