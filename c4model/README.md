
# Exports

Export as PlantUml format

```bash
docker run --rm -v "${PWD}":/root/data ghcr.io/aidmax/structurizr-cli-docker:latest \
   export  -f plantuml -o /root/data/out/ -w /root/data/drogue-cloud.dsl
```

Export as C4 PlantUml format

```bash
docker run --rm -v "${PWD}":/root/data ghcr.io/aidmax/structurizr-cli-docker:latest \
   export  -f plantuml/c4plantuml -o /root/data/out/ -w /root/data/drogue-cloud.dsl
```

# Integration with a local Structurizr server

Download the war file from https://structurizr.com/help/on-premises.

DO NOT SHARE `structurizr-onpremises-XXXX.war` file as it is licensed. 

Start the server:

```bash
# tmp directory to store Structurizr server data
STRUCTURIZR_SERVER_DATA_PATH=/tmp/structurizr

# Structurizr WAR file
STRUCTURIZR_WAR_PATH=/path/to/structurizr-onpremises-XXXX.war

mkdir -p STRUCTURIZR_SERVER_DATA_PATH 

docker run -it --rm -p 8080:8080 \ 
    -v ${STRUCTURIZR_WAR_PATH}:/usr/local/tomcat/webapps/ROOT.war \
    -v /tmp/structurizr:/usr/local/structurizr \
     tomcat:9.0.38-jdk11-openjdk
```

Create a workspace and get the API key and secret:

- Open http://localhost:8080, username: structurizr, password: password
- Go to http://localhost:8080/dashboard
- Click "Create a new workspace"
- Go to workspace settings: http://localhost:8080/workspace/1/settings
- Copy API key and secret

Run the CLI to push to the sever:

```bash
# Replace the Key and Secret below
docker run --rm --net=host -v "${PWD}":/root/data ghcr.io/aidmax/structurizr-cli-docker:latest \
   push  -workspace /root/data/drogue-cloud.dsl -url http://localhost:8080/api -id 1 \
   -key "26fa3992-7c7e-4a5c-a637-76a8ae1abba1" \
   -secret "426e3268-a337-42ec-bd3c-6edf4c591a45"
```

Go to http://localhost:8080/workspace/1 and enjoy nice diagrams! 

# Integration with Structurizr.com

Procedure is pretty much the same with "Integration with a local Structurizr server" above, except you need to get the api key, secret and the workspace id from
Structurizr.com and also get rid of the `url` parameter in the `push` command.

```bash
# Replace Key, Secret and id below
docker run --rm --net=host -v "${PWD}":/root/data ghcr.io/aidmax/structurizr-cli-docker:latest \
   push  -workspace /root/data/drogue-cloud.dsl \
   -id 12345 \
   -key "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx" \
   -secret "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"
```

