#!/usr/bin/env bash

mkdir -p package
pip install -r requirements.txt --target package
cd package
zip -r ../app.zip .
cd ../
zip app.zip app.py