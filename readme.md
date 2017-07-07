Automatic Proxy Configuration for HAProxy
====

This little script grew out of a need to create a quick way configure HAProxy when running a Docker container, as I host a number of websites in Docker containers.  HAProxy is fairly straight forward and easy to use reverse proxy solution that works with TCP and all kinds of application protocols including HTTP, which is the case here. The image is based on the official HAProxy image on Docker Hub.

The container works by reading an environmental variable that is passed into the container called **HOSTCONFIG**. The variable contains a list of host names and container names that map the hosts names to the containers internally as a reverse proxy. This allows for each container to host a site and HAProxy to act as the frontend and reverse proxy for the sites.

## Getting the Image

So to build the image, simply run docker build in the folder containing the included Dockerfile.

```
docker build --no-cache --tag auto-proxy .
```

Or you can pull the image.

```
docker pull blaize/auto-proxy
```

## Running the Image as a Container

As mentioned, you need to supply an environmental variable called **HOSTCONFIG** when the container runs. The environmental variable is a list that follows the pattern, **hostname1:containername1:container-port;hostname2:containername2:container-port**. An run command might look something like this:

```
docker run -dit --name my-proxy -e HOSTCONFIG=www2.example.com:container-name1:port;www2.example.com:container-name1:port -p 80:80 --net somenet auto-proxy
```

The HAProxy container will use whatever its DNS server is to resolve the backend hosts names, so it is recommended that you use a custom bridge network internally for backend hosts. The container names will resolve to the correct IP addresses. The default Docker network does not do this. On first run, the container will automatically generate the HAProxy config file internally. If you need to add or remove a host, delete the old container and simply rerun the command with the new host configuration.




