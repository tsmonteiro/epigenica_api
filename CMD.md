# docker rmi $(docker images --filter "dangling=true" -q --no-trunc)


 gcloud artifacts repositories create epigenica-docker-repo --repository-format=docker \
    --location=us-central1 --project=grounded-primer-372913 --description="Docker repository"


 gcloud builds submit \
   --tag us-central1-docker.pkg.dev/grounded-primer-372913/epigenica-docker-repo/epigenica_api:0.0.1 \
   --project=grounded-primer-372913 \
   --timeout=1h
#   --disk-size=100GB \

gcloud beta run deploy attribution \
   --image us-central1-docker.pkg.dev/grounded-primer-372913/epigenica-docker-repo/epigenica_api:0.0.1 \
   --memory=64Gi \
   --timeout=3600s \
   --max-instances=1 \
   --cpu=8 \
   --platform managed \
   --no-allow-unauthenticated \
   --region=us-central1


curl --connect-timeout 3600 \
   -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
   -d '{"gfolder":"Epigenica/Dados/Test"}' \
   https://attribution-grounded-primer-372913-ew.a.run.app/load_and_filter