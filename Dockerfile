FROM ubuntu

ARG USER=filer

RUN mkdir /PRIMARY_DRIVE /SECONDARY_DRIVE 
VOLUME [/PRIMARY_DRIVE, /SECONDARY_DRIVE]

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
[PRIMARY_DRIVE]
    comment = PRIMARY
    path = /PRIMARY_DRIVE
    read only = no
    browsable = yes

[SECONDARY_DRIVE] 
    comment = "SECONDARY"
    path = /SECONDARY_DRIVE
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
