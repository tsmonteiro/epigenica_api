#! /bin/bash

cd /home/thiago/Epigenica/workspace/projects/preproc_service

docker build --tag epigenica_api:0.0.1 .

docker run -p 8080:8080 --name epigenica_service epigenica_api:0.0.3 &

sleep 3

# Test call
printf '\n\n|||Request processing\n\n'
curl -i -X POST http://35.198.55.66:8080/load_and_filter  \
 -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
 -d '{"gfolder":"Epigenica/Dados/COVID_Test"}'  \
 -m 2000 
 -H "Content-Type: application/json"  \
 -H 'Accept-Language: pt_br'
 printf "\n----------------------------------------------------------\n"
 sleep 1

docker container stop epigenica_service
docker image rm -f epigenica_api

# /home/thiago/Epigenica/workspace/projects/preproc_service/grounded-primer-372913-f3ab872c29c7.json

Rscript ChAMP_Process_GDrive.R /Dados/Epigenica tsmonteiro@gmail.com $(cat /home/thiago/Epigenica/workspace/projects/preproc_service/grounded-primer-372913-f3ab872c29c7.json)

JSON=$(cat /home/thiago/Epigenica/workspace/projects/preproc_service/grounded-primer-372913-f3ab872c29c7.json)

docker cp  /home/thiago/Epigenica/workspace/projects/preproc_service/grounded-primer-372913-f3ab872c29c7.json \
     epigenica_service_v3:/app/grounded-primer-372913-f3ab872c29c7.json

#Epigenica/Dados/Test -> https://drive.google.com/drive/folders/1mTCN1MOtxn2KygIE6NPqMAZBVooHOVnI
curl -X POST http://127.0.0.1:8080/load_and_filter  \
 -d '{"gfolder":"https://drive.google.com/drive/folders/1mTCN1MOtxn2KygIE6NPqMAZBVooHOVnI", "email":"tsmonteiro@gmail.com", "token":"$(cat /home/thiago/Epigenica/workspace/projects/preproc_service/grounded-primer-372913-f3ab872c29c7.json)"}'  \
 -H "Content-Type: application/json"  \
 -m 2000 -o tmp_file.Rda