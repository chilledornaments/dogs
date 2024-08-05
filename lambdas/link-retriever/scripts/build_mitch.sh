#!/usr/bin/env bash

# https://docs.aws.amazon.com/lambda/latest/dg/golang-handler.html#golang-handler-naming
docker run --rm -it -v $PWD:/opt/code -w /opt/code golang:1.21 go build -o bootstrap

zip app.zip bootstrap 

rm bootstrap
