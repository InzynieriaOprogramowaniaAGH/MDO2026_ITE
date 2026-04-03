#!/bin/bash

cp -rf /repo/redis-8.0.0/. /code
make -j "$(nproc)" all
cp -rf /code /output
