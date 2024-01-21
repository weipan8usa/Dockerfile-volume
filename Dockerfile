FROM ubuntu

ARG USER=blk161

RUN mkdir /CoreFiles_PRIMARY /CoreFiles_SECONDARY /RawData_PRIMARY /RawData_SECONDARY
#RUN echo "hello world" > /myvol/greeting
VOLUME [/CoreFiles_PRIMARY, /CoreFiles_SECONDARY, /RawData_PRIMARY, /RawData_SECONDARY]

RUN apt update && apt install -y vim samba systemd
#RUN echo "test" >> /etc/samba/smb.conf 

#RUN systemctl enable smbd

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
[Family_PRIMARY]
    comment = Family_PRIMARY
;    path = /CoreFiles_PRIMARY/Family
    path = /CoreFiles_PRIMARY
    read only = no
    browsable = yes
;  valid users = blk161

[Family_SECONDARY] 
    comment = "Family_SECONDARY"
;   path = /CoreFiles_SECONDARY/Family
    path = /CoreFiles_SECONDARY
    read only = no
    browsable = yes
;  valid users = blk161

[RawData_PRIMARY] 
    comment = "RawData_PRIMARY"
;   path = /RawData_PRIMARY/RawData
    path = /RawData_PRIMARY
    read only = no
    browsable = yes
;  valid users = blk161

[RawData_SECONDARY] 
    comment = "RawData_SECONDARY"
;   path = /RawData_SECONDARY/RawData
    path = /RawData_SECONDARY
    read only = no
    browsable = yes
;  valid users = blk161


EOF

#CMD ["/bin/bash"]
#CMD ["/usr/sbin/service", "smbd", "start"]
CMD service smbd start ;sleep 1000000000000
