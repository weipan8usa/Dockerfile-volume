docker build -t dockerfile-volume .
#docker run --name volume-test -v /mnt/myvol:/myvol  -ti dockerfile-volume
#docker run -d --name volume-test -p 139:139 -p 445:445 -v /mnt/CoreFiles_PRIMARY:/PRIMARY  -v /mnt/CoreFiles_SECONDARY:/SECONDARY dockerfile-volume
#docker run -d --name volume-test --hostname=container -p 139:139 -p 445:445 -v /mnt/CoreFiles_PRIMARY:/PRIMARY  -v /mnt/CoreFiles_SECONDARY:/SECONDARY dockerfile-volume
docker run -d --name volume-test --hostname=container -p 139:139 -p 445:445 -v /mnt/CoreFiles_PRIMARY/Data:/PRIMARY/Data  -v /mnt/CoreFiles_PRIMARY/HISTORY:/PRIMARY/HISTORY -v /mnt/CoreFiles_SECONDARY/Data:/SECONDARY/Data -v /mnt/CoreFiles_SECONDARY/HISTORY:/SECONDARY/HISTORY dockerfile-volume

docker exec -it volume-test bash
docker container stop volume-test

mkdir /tmp/mnt;sudo fuse-zip yichao_container_trimed.zip /tmp/mnt

docker container stop volume-test ; docker container rm volume-test ; docker rmi dockerfile-volume
