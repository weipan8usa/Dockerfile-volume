FROM ubuntu

#ARG USER=filer
ENV USER=filer

#RUN mkdir /PRIMARY /SECONDARY 
VOLUME ["/PRIMARY", "/SECONDARY"]

RUN apt update && apt install -y vim samba systemd rsync

RUN useradd -m -s /bin/bash ${USER} 
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
#  valid users = blk161

[SECONDARY] 
  comment = "SECONDARY"
  path = /SECONDARY
  read only = yes 
  browsable = yes
#  valid users = blk161

[HISTORY]
  comment "HISTORY on /SECONDARY"
  writable = no
#  valid users = blk161
  path = /SECONDARY/HISTORY

[HISTORY_SYNC]
  comment "Backup of HISTORY Sync on /PRIMARY"
  writable = no
#  valid users = blk161
  path = /PRIMARY/HISTORY/

EOF

USER ${USER}
RUN crontab <<EOF 
0 5 * * * { cd /home/${USER}/;./01.sh ./Data_config.conf;./02.sh ./Data_config.conf;./sync.sh ./Data_config.conf; }
0 17 * * * rsync -avz --delete   /SECONDARY/HISTORY/* /PRIMARY/HISTORY
EOF

RUN cat >> $HOME/01.sh <<EOF
#!/bin/bash
set -x
CONFIG_FILE=\${1:-\$PWD/config.conf}
#source ~surrey/pao02/config.conf
#source ~blk161/pao03/config.conf
#source /pao03/config.conf
source \$CONFIG_FILE
# conclude a file list of BACKUP
#cd \$BACKUP_DIR 
#cd \$BACKUP_DIR/\$(basename \$SOURCE_DIR) 
cd \$BACKUP_DIR_TO_FOLDER
#find . -mount -type f >\$BACKUP_FILE_LIST-\$SOURCE_DIR_BASE_NAME
find . -mount \${EXCLUDE:- } -type f -print >\$BACKUP_FILE_LIST-\$SOURCE_DIR_BASE_NAME
#echo \$BACKUP_FILE_LIST-\$SOURCE_DIR_BASE_NAME
EOF

RUN chmod u+x $HOME/01.sh

RUN cat >> $HOME/02.sh <<EOF
#!/bin/bash
set -x
#source ~surrey/pao02/config.conf
#source ~blk161/pao03/config.conf

CONFIG_FILE=\${1:-\$PWD/config.conf}
source \$CONFIG_FILE
set +x
#source /pao03/config.conf
#cd ~surrey/BACKUP
cd \$SOURCE_DIR #get into \$SOURCE_DIR

# make a slice 
slice=\$(date +%Y_%m_%d_%H_%M)_\$SOURCE_DIR_BASE_NAME
#mkdir /Data02/HISTORY/\$slice
mkdir \$HISTORY_DIR/\$slice
while read x 
do # First Senario files has deleted in current DATA
  ls -l "\$x" >/dev/null 2>&1
  if [[ \$? -ne 0 ]] #if \$x not exist in \$SOURCE_DIR
  then
    echo \#move \$x to \$HISTORY_DIR/\$slice
    echo cp -ip \"BACKUP_DIR_TO_FOLDER/\$x\" \$HISTORY_DIR/\$slice
    (cd \$BACKUP_DIR_TO_FOLDER;tar cf - "\$x" ) |(cd \$HISTORY_DIR/\$slice;tar xf - )
    continue
  fi
# 2nd Senario file has changed in current DATA
  string1="\$x"
  string2=\$BACKUP_DIR_TO_FOLDER/"\$x"
  if [ "\$string1" -nt "\$string2" ]
  then
      echo \# \$x is not same need copy to \$HISTORY_DIR/\$slice
      echo cp -ip \"\$BACKUP_DIR_TO_FOLDER/\$x\\" \$HISTORY_DIR/\$slice
#      mv "\$BACKUP_DIR/\$x" \$HISTORY_DIR/\$slice
      (cd \$BACKUP_DIR_TO_FOLDER;tar cf - "\$x" ) |(cd \$HISTORY_DIR/\$slice;tar xf - )
#      Now delete the old file(has been modified) so when run rsyn.sh the new file can be copied over
      (cd \$BACKUP_DIR_TO_FOLDER;rm "\$x")
  fi
done<\$BACKUP_FILE_LIST-\$SOURCE_DIR_BASE_NAME>\$NEED_TO_CP_TO_SLICE_LIST-\$SOURCE_DIR_BASE_NAME # a complete list of Secondary files

mv \$NEED_TO_CP_TO_SLICE_LIST-\$SOURCE_DIR_BASE_NAME \$HISTORY_DIR/\$slice
mv \$BACKUP_FILE_LIST-\$SOURCE_DIR_BASE_NAME \$HISTORY_DIR/\$slice
EOF
RUN chmod u+x $HOME/02.sh

RUN cat >> $HOME/new <<EOF
===== Find out update of BACKUP to ARCHIVE and move them to slice
1. cd to ARCHIVE
2. generate a file list of ARCHIVE
3. use this list to find out difference of ARCHIVE and BACKUP based on ARCHIVE
4. move out the files of ARCHIVE to a slice fold which are different to BACKUP or no longer exist in BACKUP.
===== Sync BACKUP to ARCHIVE
5. cd to BACKUP
6. generate a file list of BACKUP.
7. compare BACKUP to ARCHIVE based on BACKUP.
8. cp those different files in BACKUP to ARCHIVE.
EOF

RUN cat >> $HOME/Data_config.conf <<EOF
# BACKUP_DIR is the source
# ARCHIVE_DIR is the destination

SOURCE_DIR="/PRIMARY/Data"
SOURCE_DIR_BASE_NAME=\$(basename \$SOURCE_DIR)
BACKUP_DIR="/SECONDARY"
BACKUP_DIR_TO_FOLDER="\$BACKUP_DIR/\$SOURCE_DIR_BASE_NAME" # the directory in BACKUP_DIR with basename of SOURCE_DIR, BACKUP_DIR can hold data from multiple Different SOURCE_DIR
BACKUP_FILE_LIST="/tmp/01-list"  #a complete list of BACKUP_DIR files 
NEED_TO_CP_TO_SLICE_LIST="/tmp/need_to_cp_to_slice_list"
HISTORY_DIR="/SECONDARY/HISTORY"
EXCLUDE=" -path ./Exclude -prune  -o "
EOF

RUN cat >> $HOME/sync.sh <<EOF
#!/bin/bash
CONFIG_FILE=\${1:-\$PWD/config.conf}
source \$CONFIG_FILE

#rsync -av  /Data/blk161/HOME /Data02
#rsync -avz --delete /Data/blk161/HOME /Data02

#rsync -avz --delete \$SOURCE_DIR \${BACKUP_DIR%/*}
rsync -avz --delete \$SOURCE_DIR \${BACKUP_DIR}


EOF
RUN chmod u+x $HOME/sync.sh

RUN cat >> $HOME/README.md <<EOF
# new_ver_Container_Daily_backup_Script
it is a major upgrade 2021-01-16
1) it can run multiple basename, ie Family and Media at same time
2) it will not backup files cross mount point
EOF

USER root
#CMD ["/bin/bash"]
#CMD ["/usr/sbin/service", "smbd", "start"]
CMD chown -R ${USER}:${USER} /PRIMARY /SECONDARY;service smbd start;service cron start ;sleep 1000000000000
