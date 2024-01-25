docker build -t dockerfile-volume .
docker run --name volume-test -v /mnt/myvol:/myvol  -ti dockerfile-volume
docker run -d --name volume-test -p 139:139 -p 445:445 -v /mnt/CoreFiles_PRIMARY:/PRIMARY_DRIVE  -v /mnt/CoreFiles_SECONDARY:/SECONDARY_DRIVE dockerfile-volume
docker exec -it volume-test bash
docker container stop volume-test

sudo fuse-zip yichao_container_trimed.zip /home/blk161/projects/Dockerfile-volume/mnt

docker container stop volume-test ; docker container rm volume-test ; docker rmi dockerfile-volume
