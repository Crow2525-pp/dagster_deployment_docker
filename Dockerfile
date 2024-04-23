#### dagster core image
FROM python:3.10-slim as dagster

RUN apt-get update && apt-get upgrade -yqq
RUN apt-get install git -y

# Set $DAGSTER_HOME and copy dagster instance and workspace YAML there
ENV DAGSTER_HOME=/opt/dagster/dagster_home/

#Create Dagster Home directory
RUN mkdir -p $DAGSTER_HOME

#set working directory
WORKDIR $DAGSTER_HOME

#copy config files
COPY dagster.yaml workspace.yaml $DAGSTER_HOME

#install packages
RUN pip install \
    dagster \
    dagster-postgres \
    dagster-aws 

#### Webserver image
FROM dagster as webserver
#install packages
RUN pip install \
    dagster-graphql \
    dagster-webserver 
