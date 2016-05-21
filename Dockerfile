# This is a dockerized development environment for rapido
FROM debian
MAINTAINER Ronnie Mitra

#setup dev environment
RUN apt-get update
RUN apt-get install -y git-core curl
RUN apt-get install -y nodejs
RUN apt-get install -y npm
RUN apt-get install -y openssh-server
RUN apt-get install -y supervisor
RUN apt-get install -y sudo

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#Create a development user account
RUN useradd --create-home --shell /bin/bash rapido
RUN echo "rapido:rapido" | chpasswd
RUN adduser rapido sudo

#We probably don't need this anymore.
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

#The project directory that will be shared via samba
RUN mkdir --mode=777 /opt/projects

# Share a SMB volume for the host machine (do something different for OSX)
RUN apt-get install -y samba
RUN rm /etc/samba/smb.conf
COPY smb.conf /etc/samba/smb.conf

#Expose ports Samba daemons
EXPOSE 139
EXPOSE 445
EXPOSE 137
EXPOSE 138

#Expose port for SSH daemon
EXPOSE 22

#Expose port for rapido webapp
EXPOSE 8090

#This directory is needed for the ssh daemon
RUN mkdir /var/run/sshd

#The debian node package installs a binary called nodejs, but we need it to be node
RUN ln -s /usr/bin/nodejs /usr/bin/node

#clone latest rapido repo
#github account credentials will come from environment variables
USER rapido
WORKDIR /opt/projects
RUN git clone https://github.com/mitraman/react-rapido.git
#RUN npm install

USER root
CMD ["/usr/bin/supervisord"]
