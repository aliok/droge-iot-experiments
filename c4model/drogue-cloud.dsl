workspace {

    model {
        appUser = person "User"
        iotDevice = softwareSystem "Device" "This is your device, your code and your data you want to transmit." "Robot"

        enterprise "Drogue Cloud" {
            drogueCloud = softwareSystem "Drogue Cloud" {

                keycloak = container "Keycloak" "A single sign-on (SSO) service, used to authenticate users for interacting with the other Drogue IoT services." "" "3rd Party" {
                    keycloakRealm = component "Realm"
                    drogueKeycloakClient = component "Drogue Client"
                    grafanaKeycloakClient = component "Grafana Client"
                }

                // Messaging
                messaging = container "Messaging"{
                    broker = component "Broker"
                    iotChannel = component "IOT Channel"
                    iotCommandChannel = component "IOT Command Channel"
                    registryChannel = component "Registry Channel"

                    kafka = component "Apache Kafka" "" "" "3rd Party"

                    broker -> kafka "Syncs on topic"
                    iotChannel -> kafka "Syncs on topic"
                    iotCommandChannel -> kafka "Syncs on topic"
                    registryChannel -> kafka "Syncs on topic"
                }

                // Monitoring
                monitoring = container "Monitoring"{
                    influxDBPusher = component "InfluxDB Pusher"
                    influxDB = component "influxDB" "" "" "3rd Party"
                    grafana = component "Grafana" "" "" "3rd Party"

                    influxDBPusher -> influxDB "Pushes data to"
                    iotChannel -> influxDBPusher "Pushes CloudEvents to"

                    grafana -> influxDB "Reads from"
                    grafana -> grafanaKeycloakClient "Authenticates with"
                }

                endpoints = container "Endpoints" {
                    httpEndpoint = component "HTTP Endpoint"
                    mqttEndpoint = component "MQTT Endpoint"
                    commandEndpoint = component "Command Endpoint"

                    mqttEndpoint -> iotChannel "Converts device messages to CloudEvents and sends them to"
                    iotCommandChannel -> mqttEndpoint "Sends device commands over HTTP to"
                    // TODO mqttEndpoint -> "http://authentication-service:8080"
                    // TODO mqttEndpoint -> Keycloak ????

                    httpEndpoint -> iotChannel "Converts device messages to CloudEvents and sends them to"
                    iotCommandChannel -> httpEndpoint "Sends CloudEvents to"
                    // TODO httpEndpoint -> "http://authentication-service:8080"
                    // TODO httpEndpoint -> Keycloak ????

                    commandEndpoint -> iotCommandChannel "Sends CloudEvents to"
                }

                console = container "Console" {
                    consoleBackend = component "Console Backend"
                    consoleFrontendServer = component "Console Frontend Server"
                    consoleFrontend = component "Console Frontend"

                    consoleFrontendServer -> consoleFrontend "Serves"
                    consoleFrontend -> consoleBackend "Sends requests to"

                    iotChannel -> consoleBackend "Sends messages to for spying"
                    // TODO consoleBackend -> drogueKeycloakClient "Authenticates with"
                }

                deviceRegistry = container "Device Registry" {
                    postgres = component "Postgres"
                    databaseMigration = component "Database Migration"
                    deviceAuthService = component "Device Authentication Service"
                    deviceManagementService = component "Device Management Service"
                    outboxController = component "Outbox Controller"
                    userAuthService = component "User Auth Service" "The user authorization service evaluates if a user, as authenticated by the sigle sign-on service, has access to a resource."

                    databaseMigration -> postgres "Migrates"

                    deviceAuthService -> postgres "Checks devices in"
                    deviceAuthService -> drogueKeycloakClient "Authenticates with"

                    deviceManagementService -> postgres "Stores applications and devices in"
                    deviceManagementService -> drogueKeycloakClient "Authenticates with"
                    deviceManagementService -> registryChannel "Sends messages to"

                    registryChannel -> outboxController "Sends messages to"
                    outboxController -> postgres "Stores applications and devices in"
                    outboxController -> registryChannel "Resends messages to"

                    userAuthService -> postgres "Checks resources from"
                    userAuthService -> drogueKeycloakClient "Authenticates with"
                    consoleBackend -> userAuthService "Authenticates with"
                }

                // testCertGenerator = container "Test Cert Generator"
                // authenticationService = container "Authentication Service"
                // mqttIntegration = container "MQTT Integration"

                ditto = container "Eclipse Ditto" "Acts as digital twin example." "" "3rd Party"
            }
        }

        // external software systems
        loraWan = softwareSystem "LoRaWan" "The LoRa gateway acts as the local entry point for LoRa devices to a TCP/IP network." "Existing System"
        ttn = softwareSystem "The Things Network" "TTN is a service provider, which takes on pre-processing LoRa messages received by their gateways." "Existing System"
        hono = softwareSystem "Eclipse Hono" "Eclipse Hono provides remote service interfaces for connecting large numbers of IoT devices regardless of the communication protocol." "Existing System"

        // flows from devices
        iotDevice -> httpEndpoint "Sends and receives data over HTTP"
        iotDevice -> mqttEndpoint "Sends and receives data over MQTT"
        iotDevice -> loraWan "Sends data to"
        iotDevice -> hono "Sends data to"

        // flows from external systems loraWan TTN
        loraWan -> ttn "Sends data to"
        ttn -> httpEndpoint "Forwards data to"
        hono -> httpEndpoint "Forwards data to"

        // User actions
        appUser -> grafana "Monitors dashboards in"
        appUser -> consoleFrontend "Manages Drogue Cloud in"
    }

    views {
        styles {
            element "Person" {
                background #08427b
                color #ffffff
                fontSize 22
                shape Person
            }

            element "Robot" {
                shape Component
            }

            element "Software System" {
                background #1168bd
                color #ffffff
            }

            element "Existing System" {
                background #999999
                color #ffffff
            }

            element "Container" {
                background #438dd5
                color #ffffff
            }

            element "3rd Party" {
                background #999999
                color #ffffff
            }
        }
    }

}
