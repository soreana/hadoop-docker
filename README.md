Hadoop Docker 
=============

# Build the image

If you'd like to pull this image directly from the Docker hub you can build the image as:

1. Using caches :

```
docker build  -t cnp2 .
```

2. Don't use caches :
If you want to refresh config files in your image use below command to build your image. This ignores any cache for line
 after `ARG RECONFIG=1` and execute  every line. It is useful if you want to change config files.

```
docker build -t cnp2 --build-arg RECONFIG=$(date +%s) .
```

# Run the image
There is two way to run hadoop single-node and multi-node (default config of image is single-node). You can change image 
 behavior with some environment variable and change it to multi-node.
 
## Single-node
Just run this: 
```
docker run -it cnp2 
```

## Multi-node

First create the net:
```
docker network create --subnet=172.20.0.0/16 hadoop-cluster
```

Then run the created container:
```
docker run --net hadoop-cluster --ip 172.20.0.22 -it ubuntu bash
```

At last, run slave and master nodes:
```
docker run --net hadoop-cluster --ip 172.20.0.11 -it -e HADOOP_HOSTS="172.20.0.10 master, 172.20.0.11 slave1" cnp2
docker run --net hadoop-cluster --ip 172.20.0.10 -it -e HADOOP_HOSTS="172.20.0.10 master,172.20.0.11 slave1" -e MY_ROLE="master" cnp2
```

# Run Map-Reduce