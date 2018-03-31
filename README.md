# Hadoop Docker 

# Build the image :

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

# Run the image :
There are two ways to run hadoop single-node and multi-node (default config of image is single-node). You can change image 
 behavior with some environment variable and change it to multi-node.
 
# single-node
just run this: 
```
docker run -it cnp2 
```

# multi-node



# run map-red
