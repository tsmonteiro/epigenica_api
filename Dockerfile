FROM google/cloud-sdk
# install Python3 and pip3
RUN apt-get update && apt-get install -y python3-pip python3

RUN mkdir /app
RUN mkdir /app/funcs
WORKDIR /app


RUN pip3 install Flask gunicorn

ADD requirements.txt /app
RUN pip3 install -r requirements.txt


# Install R and required packages
RUN apt-get install -y dirmngr apt-transport-https ca-certificates software-properties-common gnupg2
RUN apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev
RUN apt-get install -y r-base r-base-dev

RUN R -e "install.packages('googledrive')"
RUN R -e "install.packages('dplyr')"
RUN R -e "install.packages('matrixStats')"


ADD ./app.py /app
ADD ./ChAMP_Process_GDrive.R /app
ADD ./funcs/champ_filter_epi.R /app/funcs/champ_filter_epi.R
ADD ./funcs/champ_import_epi.R /app/funcs/champ_import_epi.R
ADD ./funcs/impute_epi.R /app/funcs/impute_epi.R
ADD ./funcs/readIDAT_epi.R /app/funcs/readIDAT_epi.R
ADD ./*.Rda /app/


#EXPOSE 5000
EXPOSE 8080

# ENV FLASK_ENV development
CMD exec gunicorn --timeout 3600 --bind  0.0.0.0:8080 --workers 1 --threads 1 app:app
#CMD exec gunicorn --timeout 3600 --bind :8080 --workers 1 --threads 1 app:app
#ENTRYPOINT ["python", "services.py"]