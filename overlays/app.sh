#!/bin/bash

op=$1
name=$2

if test -z "$name" ;then
    exit 1
fi

if [ "$op" = "d" ];then
    sed "s/@NAME@/$name/g" deploy-app.yaml | kubectl delete  -f -
elif [ "$op" = "r" ];then
    sed "s/@NAME@/$name/g" deploy-app.yaml | kubectl delete  -f -
    sed "s/@NAME@/$name/g" deploy-app.yaml | kubectl create -f -
else
    sed "s/@NAME@/$name/g" deploy-app.yaml | kubectl create -f -
fi

