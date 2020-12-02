#!/usr/bin/env bash

julia --version >/dev/null 2>&1
[[ $? -ne 0 ]] && echo -e "Приложение \033[0;34mJulia\033[0m \033[1mне найдено\033[0m!" && exit 127

julia <<< "import Pkg; Pkg.add(\"MatrixMarket\")"
