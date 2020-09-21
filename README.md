# https://github.com/kun391/phpup

## Maintained by: [KUN](https://github.com/kun391/phpup)

This is the Git repo of the DOCKER NGINX-PHP7.4 & Supervisor


# Tutorial

Follow these steps to deploy a simple  _Hello, world!_ app into production:

## Dockerfile

This is the step I hope to be able to eliminate eventually. 

```
vim Dockerfile
```

Copy and save the following:

```
# Dockerfile
FROM kun391/phpup:1.0

MAINTAINER Some Guy 

....


WORKDIR /your-application-dir

....

```

## Start Web Server with docker-compose (http) same the file [docker-compose](https://github.com/kun391/phpup/blob/master/docker-compose-deployment.yaml)

Step 1
```
vim docker-compose.yml
```
Copy and save the following:

```
version: '3'
services:
  # container for API
  app:
    image: kun391/phpup:1.0
    ports:
      - 8000:80
    depends_on:
      - db
    working_dir: /var/www/app
    volumes:
      - './demo:/var/www/app'
      - ./demo/queue.conf:/etc/supervisor/conf.d/queue.conf
  ...

```

Assuming all steps were followed correctly, this will pull all the required images and start serving the app:
```
docker-compose -f docker-compose up -d
```

NOW, We can access this with localhost:8000 for Web Server

## Start web server with docker-compose (https)

We using traefik, dnsmasq, mkcert for this sample.

We can following [docker-compose](https://github.com/kun391/phpup/blob/master/docker-compose.yaml)

# Contributing

# License
MIT
