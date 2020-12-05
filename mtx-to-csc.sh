#!/usr/bin/env bash

ConverterJava="MtxToCscConverter"

if [[ ! -f ${BaseDir}/utils/${ConverterJava}.class ]]
then
    BaseDir=$(dirname ${BASH_SOURCE[0]})
    javac ${BaseDir}/utils/${ConverterJava}.java
fi

java -cp ${BaseDir}/utils ${ConverterJava} $1 $2

