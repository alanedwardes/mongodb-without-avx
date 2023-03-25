About
=====
This repository contains automation to build MongoDB from source with no AVX requirement. The artifact generated is an `x86_64` Docker container for Linux, and it is pushed to my own public AWS ECR space: https://gallery.ecr.aws/alanedwardes/mongodb-without-avx

> Since I need this for my own projects, I intend to keep the above repository up to date with the major MongoDB versions. I am not intending to build every single minor or patch version, though can do on request (raise an issue).

See the forked repository for the original `Dockerfile`, and a solution to build for non-Docker use cases.

Usage
=====
The docker container includes the following binaries in `/usr/local/bin/`
* `mongod`
* `mongos`
* `mongo`

The `ENTRYPOINT` is exposed as `/usr/local/bin/mongod`, so a `docker-compose.yml` file could be crafted like so:

```yaml
services:
  mongodb:
    image: public.ecr.aws/alanedwardes/mongodb-without-avx:6.0.5
    restart: always
    container_name: mongodb
    command: --config=/etc/mongodb.conf
    volumes:
      - ./mongodb.conf:/etc/mongodb.conf
      - ./mongo:/data
```

The `mongodb.conf` in the same directory can specify settings such as:

```yaml
# mongod.conf
# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

storage:
  dbPath: /data
  directoryPerDB: false

net:
  port: 27017
  unixDomainSocket:
    enabled: true
  ipv6: false
  bindIpAll: true

replication:
  replSetName: rs0
  enableMajorityReadConcern: true

setParameter:
   enableLocalhostAuthBypass: true

security:
  authorization: disabled
```

If you need to set up a replica set on first run, you can use the mongo shell:

```bash
docker exec -it mondodb mongo
```

And then enter `rs.initiate()` as normal.
