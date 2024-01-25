FROM ubuntu

ARG USER=filer

#RUN mkdir /PRIMARY /SECONDARY 
VOLUME ["/PRIMARY", "/SECONDARY"]

RUN apt update && apt install -y vim samba systemd

RUN useradd -m ${USER} 
RUN passwd ${USER} <<"!"
521161
521161
!

RUN pdbedit -a ${USER} <<"!"
521161
521161
!

RUN cat <<EOF >> /etc/samba/smb.conf 
[PRIMARY]
    comment = PRIMARY
    path = /PRIMARY
    read only = no
    browsable = yes

[SECONDARY] 
    comment = "SECONDARY"
    path = /SECONDARY
    read only = no
    browsable = yes
EOF

RUN su - ${USER} -c crontab <<EOF 
0 5 * * * { cd /home/${USER}/pao_Data/;./01.sh ./Data_config.conf;./02.sh ./Data_config.conf;./sync.sh ./Data_config.conf; }
0 17 * * * rsync -avz --delete   /SECONDARY/HISTORY/* /PRIMARY/HISTORY_SYNC
EOF

#CMD ["/bin/bash"]
#CMD ["/usr/sbin/service", "smbd", "start"]
CMD service smbd start;service cron start ;sleep 1000000000000
