FROM ubuntu

ARG USER=blk161

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

#CMD ["/bin/bash"]
#CMD ["/usr/sbin/service", "smbd", "start"]
CMD service smbd start ;sleep 1000000000000
