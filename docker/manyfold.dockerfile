# syntax = devthefuture/dockerfile-x
# sudo docker build --file ./docker/manyfold.dockerfile --build-arg APP_VERSION=test --build-arg GIT_SHA=00 --tag openuc2verse .
# sudo docker run -p 3214:3214 -v /Users/bene/Downloads:/libraries -e PUID=1000 -e PGID=1000 -e SECRET_KEY_BASE=a_nice_long_random_string -e REDIS_URL=redis://redis:6379/1 -e DATABASE_ADAPTER=postgresql -e DATABASE_HOST=postgres -e DATABASE_USER=manyfold -e DATABASE_PASSWORD=password -e DATABASE_NAME=manyfold openuc2verse


INCLUDE docker/base.dockerfile
INCLUDE docker/build.dockerfile
INCLUDE docker/runtime.dockerfile

## STANDARD IMAGE ##########################################

FROM runtime as manyfold
