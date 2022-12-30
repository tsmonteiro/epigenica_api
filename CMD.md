# docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
gcloud auth configure-docker
docker build --tag epigenica_api:0.0.3 . && \
docker tag epigenica_api:0.0.3 gcr.io/grounded-primer-372913/epigenica_api:0.0.3 && \
docker push gcr.io/grounded-primer-372913/epigenica_api:0.0.3

gcloud compute instances create-with-container epigenica-vm \
    --zone southamerica-east1-a \
    --container-image gcr.io/grounded-primer-372913/epigenica_api:0.0.3



# Create a new firewall rule that allows INGRESS tcp:8080 with VMs containing tag 'allow-tcp-8080'
# Add the 'allow-tcp-8080' tag to a VM named VM_NAME
gcloud compute firewall-rules create rule-allow-tcp-8080 --source-ranges 0.0.0.0/0 --target-tags allow-tcp-8080 --allow tcp:8080 && \
gcloud compute instances add-tags epigenica-vm --zone southamerica-east1-a --tags allow-tcp-8080





 <!-- gcloud builds submit \
   --tag us-central1-docker.pkg.dev/grounded-primer-372913/epigenica-docker-repo/epigenica_api:0.0.1 \
   --project=grounded-primer-372913 \
   --timeout=1h -->



gcloud compute ssh instance-1 --zone southamerica-east1-b



curl -i -X POST http://35.198.55.66:8080/load_and_filter  \

curl -i -X POST 35.198.55.66:8080/load_and_filter   \
 -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
 -H "Content-Type: application/json"  \
 -d '{"gfolder":"Epigenica/Dados/Test"}'  \
 -m 2000 