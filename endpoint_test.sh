#! /bin/bash

cd /home/thiago/Epigenica/workspace/projects/preproc_service

docker build --tag epigenica_api .

docker run -p 8080:8080 --name epigenica_service epigenica_api &

sleep 3

# Test call
printf '\n\n|||Request processing\n\n'
curl -i -X POST http://127.0.0.1:8080/load_and_filter  \
 -d '{"gfolder":"Epigenica/Dados/Test"}'  \
 -H "Content-Type: application/json"  \
 -H 'Accept-Language: pt_br'
 printf "\n----------------------------------------------------------\n"
 sleep 1

docker container stop epigenica_service
docker image rm -f epigenica_api