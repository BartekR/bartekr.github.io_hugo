---
title: "Containers Land: Docker Basics" # Title of the blog post.
date: 2025-05-18 # Date of post creation.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: false # Controls if a table of contents should be generated for first-level links automatically.
image: "2025/05/18/containers-land-docker-basics/images/docker_cli.png"
tags: ['docker', 'wsl2']
categories: ['containers']
---

Whole series, assumptions, and map: [Container Lands](/containers-land)

The morning was quite chilly. You stood in the hut's open doorway and watched the rising sun. You know you need to leave the cosy WSL2 village soon. "Tomorrow", you think, and grab your stuff. Time for the morning training.

## Using basic commands

As the warm up, you run few commands to stretch your fingers: `docker ps`, `docker run hello-world`, `docker image rm hello-world --force`, `docker image ls`, `docker pull nginx`.

You stop. "Too fast", you think. Although your fingers run as if they were doing it thousands of times, you take a breath and repeat the commands, slower. Adding more steps and context.

```sh
# list all running containers
docker ps

# list all running containers, be more explicit
docker container ps

# run the container using basic docker image; all tutorials use it, so why not - it's a warm up
docker run hello-world

# run the container again, be more explicit
docker container run hello-world

# run the container again, be even more explicit
docker container run hello-world:latest

# run one more hello-world container, be as explicit as you can - even add the default repository name
docker container run docker.io/hello-world:latest

# show all containers, even the ones not active
docker ps -a

# show all containers, even the ones not active, be explicit
docker container ps -a

# bartekr@Kelsier:~$ docker container ps -a
# CONTAINER ID   IMAGE                COMMAND    CREATED         STATUS                     PORTS     NAMES
# 7f5ad6d558a6   hello-world:latest   "/hello"   2 minutes ago   Exited (0) 2 minutes ago             trusting_rhodes
# 5872980752a4   hello-world:latest   "/hello"   2 minutes ago   Exited (0) 2 minutes ago             objective_feistel
# f51f0ca12cb7   hello-world          "/hello"   2 minutes ago   Exited (0) 2 minutes ago             inspiring_beaver

# remove container using id
docker rm 7f5ad6d558a6

# remove another container using its name, be more explicit
docker container rm inspiring_beaver

# remove all remaining stopped containers, use --force, so it does not ask for confirmation
docker container prune --force
```

"Break", you say. Repeating containers basics with so attention to detail is tiring. Yet, you summarise the first part:

- by default, Docker assumes you work with containers, so usually you omit the `container` part in the commands
- the default repository is Docker Hub (docker.io), no need to provide it if you need images from there
- you can provide the `:latest` tag, but it's not required - by default you get the latest version
- *hello-world* container prints the information on the screen and exits - we are back in the terminal after command stops running

After a few minutes, you stretch, take a breath, and run a second round.

```sh
# run hello world container again, and give it your own name
docker container run --name hw1 hello-world:latest

# docker run fetches image from repository if it is not available locally, so this time split the operations into two steps
# first - fetch latest nginx image
docker pull nginx:latest

# second - run the container using the pulled image, give it your own name
docker container run --name nginx1 nginx:latest

# unlike the previous docker run commands - this time we started the container, and we are still inside - no prompt available
# bartekr@Kelsier:~$ docker container run --name nginx1 nginx:latest
# /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
# /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
# /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
# 10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
# 10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
# /docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
# /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
# /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
# /docker-entrypoint.sh: Configuration complete; ready for start up
# 2025/05/18 10:11:57 [notice] 1#1: using the "epoll" event method
# 2025/05/18 10:11:57 [notice] 1#1: nginx/1.27.5
# 2025/05/18 10:11:57 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14)
# 2025/05/18 10:11:57 [notice] 1#1: OS: Linux 5.15.167.4-microsoft-standard-WSL2
# 2025/05/18 10:11:57 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
# 2025/05/18 10:11:57 [notice] 1#1: start worker processes
# 2025/05/18 10:11:57 [notice] 1#1: start worker process 29
# (...)
# 2025/05/18 10:11:57 [notice] 1#1: start worker process 56

# Hit Ctrl+C to exit and stop the container

# ^C2025/05/18 10:16:54 [notice] 1#1: signal 2 (SIGINT) received, exiting
# 2025/05/18 10:16:54 [notice] 31#31: exiting
# 2025/05/18 10:16:54 [notice] 31#31: exit
# 2025/05/18 10:16:54 [notice] 29#29: exiting
# (...)
# 2025/05/18 10:16:54 [notice] 1#1: worker process 29 exited with code 0
# 2025/05/18 10:16:54 [notice] 1#1: signal 17 (SIGCHLD) received from 42
# 2025/05/18 10:16:54 [notice] 1#1: worker process 42 exited with code 0
# 2025/05/18 10:16:54 [notice] 1#1: exit

# run the container in the background (aka "detached mode" -d/--detach)
docker container run -d --name nginx2 nginx:latest

# nice, back in the prompt, use another method to list all containers (including inactive)
docker container ls -a

# bartekr@Kelsier:~$ docker container ls -a
# CONTAINER ID   IMAGE                COMMAND                  CREATED              STATUS                      PORTS     NAMES
# 7e1c115bd021   nginx:latest         "/docker-entrypoint.…"   About a minute ago   Up 59 seconds               80/tcp    nginx2
# 3d4c46d46447   nginx:latest         "/docker-entrypoint.…"   7 minutes ago        Exited (0) 2 minutes ago              nginx1
# 7e5d48855261   hello-world:latest   "/hello"                 12 minutes ago       Exited (0) 12 minutes ago             hw1

# container nginx2 is up and running, and nginx listens on port 80, check it
curl localhost:80

# bartekr@Kelsier:~$ curl localhost:80
# curl: (7) Failed to connect to localhost port 80 after 1 ms: Couldn't connect to server

# publish container's ports during container creation (-p/--publish) to use them
docker container run --detach --name nginx3 --publish 80:80 nginx:latest

# CONTAINER ID   IMAGE                COMMAND                  CREATED              STATUS                      PORTS                               NAMES
# 6dc82ca97b27   nginx:latest         "/docker-entrypoint.…"   About a minute ago   Up About a minute           0.0.0.0:80->80/tcp, :::80->80/tcp   nginx3
# 7e1c115bd021   nginx:latest         "/docker-entrypoint.…"   13 minutes ago       Up 13 minutes               80/tcp                              nginx2
# 3d4c46d46447   nginx:latest         "/docker-entrypoint.…"   19 minutes ago       Exited (0) 14 minutes ago                                       nginx1
# 7e5d48855261   hello-world:latest   "/hello"                 24 minutes ago       Exited (0) 24 minutes ago                                       hw1

# test the port now
curl localhost:80

# bartekr@Kelsier:~$ curl localhost:80
# <!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>

# I don't like being exposed everywhere (0.0.0.0), limit to localhost
docker container run --detach --name nginx4 --publish 127.0.0.1:80:80 nginx:latest

# error - the port is already in use
# docker: Error response from daemon: driver failed programming external connectivity on endpoint nginx4 (e1f51be7fc10ad848a30a746c40cede978b366b949eaf1286a9fab3dc3444b75): failed to bind port 127.0.0.1:80/tcp: Error starting userland proxy: listen tcp4 127.0.0.1:80: bind: address already in use.
# clean up nginx4, and use local port 81
docker rm nginx4 --force
docker container run --detach --name nginx4 --publish 127.0.0.1:81:80 nginx:latest

# bartekr@Kelsier:~$ docker container ls -a
# CONTAINER ID   IMAGE                COMMAND                  CREATED              STATUS                      PORTS                               NAMES
# 35c54f5e00da   nginx:latest         "/docker-entrypoint.…"   6 seconds ago        Up 5 seconds                127.0.0.1:81->80/tcp                nginx4
# 6dc82ca97b27   nginx:latest         "/docker-entrypoint.…"   About a minute ago   Up About a minute           0.0.0.0:80->80/tcp, :::80->80/tcp   nginx3
# 7e1c115bd021   nginx:latest         "/docker-entrypoint.…"   13 minutes ago       Up 13 minutes               80/tcp                              nginx2
# 3d4c46d46447   nginx:latest         "/docker-entrypoint.…"   19 minutes ago       Exited (0) 14 minutes ago                                       nginx1
# 7e5d48855261   hello-world:latest   "/hello"                 24 minutes ago       Exited (0) 24 minutes ago                                       hw1

# test the port again
curl localhost:81

# bartekr@Kelsier:~$ curl localhost:81
# <!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>
```

"Whoa!". You are a little tired, but happy. Second round summary:

- containers exit on completion, but usually they are running until stopped - use *detached mode* (`-d` / `--detach`) to run them in the background
- if the container exposes a port, you need to `--publish` it (or `-p` for short) if you plan to use it
- only one container can use one host's port (like: each nginx's container port has to be mapped to a separate host port)
- when publishing ports, first part is the host (IP:port), the second part is the container
- if only port is provided for host, the container's port is exposed to `0.0.0.0`

> *sidenote*: while oftentimes using 0.0.0.0 or 127.0.0.1 makes no difference, there is one important thing:
>
> - `127.0.0.1` means localhost, and is available only from the local computer
> - `0.0.0.0` means *all defined IPv4 addresses on this machine* - so if you are connected to the network, and have assigned network IP address(es) (example: 10.0.0.4, 192.168.1.4) - all these addresses have port opened, and can be reached from another machine

The last, third round. You want to confirm the assumption: "I see the same content, when I run `curl localhost:80` and `curl localhost:81` commands. How can I be sure they are not served from one place?"

```sh
# "connect" to container's shell, and modify the index.html file - write "Hello from <container name>"
# after execution - pay attention, you are now in the container's shell - your prompt is now root@<container id>
docker exec -it nginx3 bash

# <in the container> by default, nginx uses /usr/share/nginx/html to store HTML content, edit it
ls /usr/share/nginx/html

# root@6dc82ca97b27:/# ls /usr/share/nginx/html
# 50x.html  index.html

# <in the container> there is neither vi or nano, so overwrite the content from the prompt
echo '<h1>Hello from nginx3, 6dc82ca97b27</h1>' > /usr/share/nginx/html/index.html
cat /usr/share/nginx/html/index.html

# root@6dc82ca97b27:/# echo '<h1>Hello from nginx3, 6dc82ca97b27</h1>' > /usr/share/nginx/html/index.html
# root@6dc82ca97b27:/# cat /usr/share/nginx/html/index.html
# <h1>Hello from nginx3, 6dc82ca97b27</h1>

# <in the container> leave the container, and return to the command prompt
exit

# root@6dc82ca97b27:/# exit
# exit
# bartekr@Kelsier:

# repeat with the second nginx container, be more explicit
docker exec --interactive --tty nginx4 bash

# <in the container>
echo '<h1>Hello from nginx4, 35c54f5e00da</h1>' > /usr/share/nginx/html/index.html
cat /usr/share/nginx/html/index.html
exit

# back in the host's prompt, fetch again pages from both running nginx containers
curl localhost:80
curl localhost:81

# bartekr@Kelsier:~$ curl localhost:80
# <h1>Hello from nginx3, 6dc82ca97b27</h1>
# bartekr@Kelsier:~$ curl localhost:81
# <h1>Hello from nginx4, 35c54f5e00da</h1>
```

Nice. The third round showed:

- executing commands in running containers
- nginx containers run with the `root` user
- ports from the container need to be explicitly published to be available on the host

Uff. Enough. Time for cleanup.

```sh
# remove hello-world container and the image using separate commands for clarity
docker container rm hw1
docker image rm hello-world

# remove all nginx containers
docker container rm $(docker container ls -qa) --force

# remove nginx image
docker image rm nginx
```

Wait wait wait. What is the `docker container rm $(docker container ls -qa) --force` command doing?

- `docker container ls -a` - show all containers, even inactive ones
- `docker container ls -q` - show only identifiers of all active containers

The command forcibly (`--force`) removes (`rm`) all (`-a`) containers (`container`), taking the identifiers (`$(docker container ls -qa)`) as input. It works on Linux, not on Windows.

Training is over. It's already afternoon, so you take your gear, and go for lunch. Looking behind you, you see **+200 XP**, and you glow for a moment. "Next level!" you smile, and as you receive another point, add it to your stats. Why not *Endurance*?

{{< rpg-character
    image="/img/rpg/Jaesika%20Kelamin%20-%20Deorum%20character.png"
    alt="RPG Character"
>}}
Strength:7
Agility:6
Endurance:5 -> 6
Perception:6
Cunning:6
Charisma:4
Level 2:XP 300 / 800
{{< /rpg-character >}}
