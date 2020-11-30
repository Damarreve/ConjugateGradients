#!/usr/bin/env bash

julia --version >/dev/null 2>&1

[[ $? -ne 0 ]] && echo -e "Приложение \033[0;34mJulia\033[0m \033[1mне найдено\033[0m!" && exit 127

pushd $(dirname ${BASH_SOURCE[0]}) >/dev/null 2>&1
for File in $(find ./src -type f -name *.jl)
do
    echo -e "\033[0;4$[${RANDOM}%5+1]m"$(basename ${File})"\033[0m:"
    julia ${File}
    echo
done
popd >/dev/null 2>&1
