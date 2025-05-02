---
title: "Containers Land: docker setup on WSL2" # Title of the blog post.
date: 2025-05-01 # Date of post creation.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: false # Controls if a table of contents should be generated for first-level links automatically.
image: "2025/05/01/containers-land-docker-setup-on-wsl2/images/containers_land_01.png"
tags: ['docker', 'wsl2']
categories: ['containers']
---

Whole series, assumptions, and map: [Container Lands](/containers-land)

The story starts slowly in a small village close to the YAML Mountains. Before you leave your house to learn about containers, you must install Docker. You are brave, you are strong, and you have a Windows operating system. And you want to use WSL2...

## ... leaving Docker Desktop behind

Wait. What? Stop for a second. Why not Docker Desktop? It's easy, intuitive, and free? Three reasons, my friend:

1. It's free for personal use use. Companies need to pay a fee, and sometimes they do not want to buy commercial software hence - use of the docker command in the WSL2 terminal
2. I suck at Linux. I know a few commands and some basics (I know how to exit vim!), but I'm far from feeling comfortable. I like Ubuntu; I used it a while ago, so why not use it again and upgrade some skills along the way?
3. I want to run all commands by hand and remember as many as I can - so I use a terminal

> If you do not have WSL2 installed, the recent documentation version suggests running the following command in an elevated prompt (as administrator) and restarting your computer:
>
> `wsl.exe --install`
>
> This installs the default Ubuntu distribution, but it can sometimes cause issues (in my case - problems with `systemctl` and running Docker as daemon), so I use the latest Ubuntu distribution by executing
>
> `wsl.exe --install -d Ubuntu-24.04`
>
> To get the distributions list, execute the command `wsl.exe --list --online` and select the value from the left column (NAME) as a parameter. For more information - [visit the official documentation](https://learn.microsoft.com/en-us/windows/wsl/install)

## Installing Docker on WSL

While there are installation steps [in the official documentation](https://docs.docker.com/engine/install/ubuntu/), I use the way I read a long time ago at [Nick Janetakis' blog](https://nickjanetakis.com/blog/install-docker-in-wsl-2-without-docker-desktop). I run a sequence of the following commands one by one (not in a script):

```bash
# Install Docker; you can ignore the warning from Docker about using WSL
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to the Docker group
sudo usermod -aG docker $USER

# Sanity check that both tools were installed successfully
docker --version
docker compose version

# Using Ubuntu 22.04 or Debian 10+? You need to do 1 extra step for iptables
# compatibility, you'll want to choose option (1) to use iptables-legacy from
# the prompt that'll come up when running the command below.
#
# You'll likely need to reboot Windows or at least restart WSL after applying
# this, otherwise networking inside of your containers won't work.
sudo update-alternatives --config iptables
```

As of May 2025, this set of commands is enough to get `docker` and `docker-compose` up and running. If something is not working, restart your WSL session.

Well, this was quick—like a very short game prologue. Nevertheless, you earn 100 XP and deserve 1 point to upgrade your statistics. I choose Perception +1

{{< rpg-character
    image="/img/rpg/Jaesika%20Kelamin%20-%20Deorum%20character.png"
    alt="RPG Character"
>}}
Strength:7
Agility:6
Endurance:5
Perception:5 -> 6
Cunning:6
Charisma:4
Level 1: XP 100 / 300
{{< /rpg-character >}}
