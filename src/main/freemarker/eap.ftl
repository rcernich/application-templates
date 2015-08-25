<#ftl ns_prefixes={"D":"urn:jboss:cloud-enablement:template-config:1.0"}>

<#import "util.ftl" as util/>
<#import "common.ftl" as generic/>
<#import "build-config.ftl" as build/>
<#import "mysql.ftl" as mysql/>
<#import "amq.ftl" as amq/>

<#macro service_prefix_mapping services>
<@compress true>
  <#list services as service>
${service.@name}=${service.@prefix?upper_case}
    <#if service_has_next>
,
    </#if>
  </#list>
</@compress>
</#macro>

<#macro params eap common>
<@generic.params common true false/>,
        {
            "description": "EAP Release version, e.g. 6.4, etc.",
            "name": "EAP_RELEASE",
            "value": "6.4"
<#if (eap.@configureHornetQ[0]!"false") == "true">
        },
        {
            "description": "Queue names",
            "name": "HORNETQ_QUEUES",
            "value": ""
        },
        {
            "description": "Topic names",
            "name": "HORNETQ_TOPICS",
            "value": ""
        },
        {
            "description": "HornetQ cluster admin password",
            "name": "HORNETQ_CLUSTER_PASSWORD",
            "from": "[a-zA-Z0-9]{8}",
            "generate": "expression"
</#if>
<#if (eap.@configureSsl[0]!"false") == "true">
        },
        {
            "description": "The name of the secret containing the keystore file",
            "name": "EAP_HTTPS_SECRET",
            "value": "eap-app-secret"
        },
        {
            "description": "The name of the keystore file within the secret",
            "name": "EAP_HTTPS_KEYSTORE",
            "value": "keystore.jks"
        },
        {
            "description": "The name associated with the server certificate",
            "name": "EAP_HTTPS_NAME",
            "value": ""
        },
        {
            "description": "The password for the keystore and certificate",
            "name": "EAP_HTTPS_PASSWORD",
            "value": ""
</#if>
        }
<#list eap?children as service>
    <#switch service?node_name>
        <#case "db">
            <#switch service.@type>
                <#case "mysql">
,<@mysql.params service/>
                <#break>
            </#switch>
        <#break>
        <#case "amq">
,<@amq.params service/>
        <#break>
    </#switch>
</#list>
</#macro>

<#macro objects eap common>
        {
            "kind": "Service",
            "apiVersion": "v1",
            "spec": {
                "ports": [
                    {
                        "port": 8080,
                        "targetPort": 8080
                    }
                ],
                "selector": {
                    "deploymentConfig": "${eap.@name}"
                }
            },
            "metadata": {
                "name": "${eap.@name}",
                "labels": {
                    "application": "<@util.param common.params.applicationName/>"
                },
                "annotations": {
                    "description": "The web server's http port."
                }
            }
        },
<#if (eap.@configureSsl[0]!"false") == "true">
        {
            "kind": "Service",
            "apiVersion": "v1",
            "spec": {
                "ports": [
                    {
                        "port": 8443,
                        "targetPort": 8443
                    }
                ],
                "selector": {
                    "deploymentConfig": "${eap.@name}"
                }
            },
            "metadata": {
                "name": "secure-${eap.@name}",
                "labels": {
                    "application": "<@util.param common.params.applicationName/>"
                },
                "annotations": {
                    "description": "The web server's https port."
                }
            }
        },
</#if>
        {
            "kind": "Service",
            "apiVersion": "v1",
            "spec": {
                "ports": [
                    {
                        "port": 8888,
                        "targetPort": 8888
                    }
                ],
                "portalIP": "None",
                "selector": {
                    "deploymentConfig": "${eap.@name}"
                }
            },
            "metadata": {
                "name": "${eap.@name}-ping",
                "labels": {
                    "application": "<@util.param common.params.applicationName/>"
                },
                "annotations": {
                    "description": "Ping service for clustered applications."
                }
            }
        },
        {
            "kind": "Route",
            "apiVersion": "v1",
            "id": "${eap.@name}-http-route",
            "metadata": {
                "name": "${eap.@name}-http-route",
                "labels": {
                    "application": "<@util.param common.params.applicationName/>"
                },
                "annotations": {
                    "description": "Route for application's http service."
                }
            },
            "spec": {
                "host": "<@util.param common.params.applicationHostName/>",
                "to": {
                    "name": "${eap.@name}"
                }
            }
        },
<#if (eap.@configureSsl[0]!"false") == "true">
        {
            "kind": "Route",
            "apiVersion": "v1",
            "id": "${eap.@name}-https-route",
            "metadata": {
                "name": "${eap.@name}-https-route",
                "labels": {
                    "application": "<@util.param common.params.applicationName/>"
                },
                "annotations": {
                    "description": "Route for application's https service."
                }
            },
            "spec": {
                "host": "<@util.param common.params.applicationHostName/>",
                "to": {
                    "name": "secure-${eap.@name}"
                },
                "tls": {
                    "termination": "passthrough"
                }
            }
        },
</#if>
<@build.config common, eap.@imageStreamName, eap.@imageStreamTag, eap.@buildImageStreamTag/>,
        {
            "kind": "DeploymentConfig",
            "apiVersion": "v1",
            "metadata": {
                "name": "${eap.@name}",
                "labels": {
                    "application": "<@util.param common.params.applicationName/>"
                }
            },
            "spec": {
                "strategy": {
                    "type": "Recreate"
                },
                "triggers": [
                    {
                        "type": "ImageChange",
                        "imageChangeParams": {
                            "automatic": true,
                            "containerNames": [
                                "${eap.@name}"
                            ],
                            "from": {
                                "kind": "ImageStream",
                                "name": "${eap.@imageStreamName}"
                            }
                        }
                    }
                ],
                "replicas": 1,
                "selector": {
                    "deploymentConfig": "${eap.@name}"
                },
                "template": {
                    "metadata": {
                        "name": "${eap.@name}",
                        "labels": {
                            "deploymentConfig": "${eap.@name}",
                            "application": "<@util.param common.params.applicationName/>"
                        }
                    },
                    "spec": {
<#if (eap.@configureSsl[0]!"false") == "true">
                        "serviceAccount": "eap-service-account",
</#if>
                        "containers": [
                            {
                                "name": "${eap.@name}",
                                "image": "${eap.@imageStreamName}",
                                "imagePullPolicy": "Always",
                                "volumeMounts": [
<#if (eap.@configureSsl[0]!"false") == "true">
                                    {
                                        "name": "eap-keystore-volume",
                                        "mountPath": "/etc/eap-secret-volume",
                                        "readOnly": true
                                    }
</#if>
                                ],
                                "readinessProbe": {
                                    "exec": {
                                        "command": [
                                            "/bin/bash",
                                            "-c",
                                            "/opt/eap/bin/readinessProbe.sh"
                                        ]
                                    }
                                },
                                "ports": [
                                    {
                                        "name": "http",
                                        "containerPort": 8080,
                                        "protocol": "TCP"
                                    },
<#if (eap.@configureSsl[0]!"false") == "true">
                                    {
                                        "name": "https",
                                        "containerPort": 8443,
                                        "protocol": "TCP"
                                    },
</#if>
                                    {
                                        "name": "ping",
                                        "containerPort": 8888,
                                        "protocol": "TCP"
                                    }
                                ],
                                "env": [
                                    {
                                        "name": "OPENSHIFT_DNS_PING_SERVICE_NAME",
                                        "value": "<@util.param common.params.applicationName/>-ping"
                                    },
                                    {
                                        "name": "OPENSHIFT_DNS_PING_SERVICE_PORT",
                                        "value": "8888"
<#if (eap.@configureSsl[0]!"false") == "true">
                                    },
                                    {
                                        "name": "EAP_HTTPS_KEYSTORE_DIR",
                                        "value": "/etc/eap-secret-volume"
                                    },
                                    {
                                        "name": "EAP_HTTPS_KEYSTORE",
                                        "value": "<@util.param "EAP_HTTPS_KEYSTORE"/>"
                                    },
                                    {
                                        "name": "EAP_HTTPS_NAME",
                                        "value": "<@util.param "EAP_HTTPS_NAME"/>"
                                    },
                                    {
                                        "name": "EAP_HTTPS_PASSWORD",
                                        "value": "<@util.param "EAP_HTTPS_PASSWORD"/>"
</#if>
<#if (eap.@configureHornetQ[0]!"false") == "true">
                                    },
                                    {
                                        "name": "HORNETQ_CLUSTER_PASSWORD",
                                        "value": "<@util.param "HORNETQ_CLUSTER_PASSWORD"/>"
                                    },
                                    {
                                        "name": "HORNETQ_QUEUES",
                                        "value": "<@util.param "HORNETQ_QUEUES"/>"
                                    },
                                    {
                                        "name": "HORNETQ_TOPICS",
                                        "value": "<@util.param "HORNETQ_TOPICS"/>"
</#if>
<#if eap.db?has_content>
                                    },
                                    {
                                        "name": "DB_SERVICE_PREFIX_MAPPING",
                                        "value": "<@service_prefix_mapping eap.db/>"
                                    },
                                    {
                                        "name": "TX_DATABASE_PREFIX_MAPPING",
                                        "value": "<@service_prefix_mapping eap.db/>"
<#list eap.db as db>
                                    },
                                    {
                                        "name": "${db.@prefix?upper_case}_JNDI",
                                        "value": "<@util.param (db.@prefix?upper_case)+"_JNDI"/>"
                                    },
                                    {
                                        "name": "${db.@prefix?upper_case}_USERNAME",
                                        "value": "<@util.param (db.@prefix?upper_case)+"_USERNAME"/>"
                                    },
                                    {
                                        "name": "${db.@prefix?upper_case}_PASSWORD",
                                        "value": "<@util.param (db.@prefix?upper_case)+"_PASSWORD"/>"
                                    },
                                    {
                                        "name": "${db.@prefix?upper_case}_DATABASE",
                                        "value": "<@util.param (db.@prefix?upper_case)+"_DATABASE"/>"
<#if (db.@configureAdvancedSettings[0]!"false") == "true">
                                    },
                                    {
                                        "name": "${db.@prefix?upper_case}_MIN_POOL_SIZE",
                                        "value": "<@util.param (db.@prefix?upper_case)+"_MIN_POOL_SIZE"/>"
                                    },
                                    {
                                        "name": "${db.@prefix?upper_case}_MAX_POOL_SIZE",
                                        "value": "<@util.param (db.@prefix?upper_case)+"_MAX_POOL_SIZE"/>"
                                    },
                                    {
                                        "name": "${db.@prefix?upper_case}_TX_ISOLATION",
                                        "value": "<@util.param (db.@prefix?upper_case)+"_TX_ISOLATION"/>"
</#if>
</#list>
</#if>
<#if eap.amq?has_content>
                                    },
                                    {
                                        "name": "MQ_SERVICE_PREFIX_MAPPING",
                                        "value": "<@service_prefix_mapping eap.amq/>"
<#list eap.amq as mq>
                                    },
                                    {
                                        "name": "${mq.@prefix?upper_case}_JNDI",
                                        "value": "<@util.param (mq.@prefix?upper_case)+"_JNDI"/>"
                                    },
                                    {
                                        "name": "${mq.@prefix?upper_case}_USERNAME",
                                        "value": "<@util.param (mq.@prefix?upper_case)+"_USERNAME"/>"
                                    },
                                    {
                                        "name": "${mq.@prefix?upper_case}_PASSWORD",
                                        "value": "<@util.param (mq.@prefix?upper_case)+"_PASSWORD"/>"
                                    },
                                    {
                                        "name": "${mq.@prefix?upper_case}_PROTOCOL",
                                        "value": "tcp"
                                    },
                                    {
                                        "name": "${mq.@prefix?upper_case}_QUEUES",
                                        "value": "<@util.param (mq.@prefix?upper_case)+"_QUEUES"/>"
                                    },
                                    {
                                        "name": "${mq.@prefix?upper_case}_TOPICS",
                                        "value": "<@util.param (mq.@prefix?upper_case)+"_TOPICS"/>"
</#list>
</#if>
                                    }
                                ]
                            }
                        ],
                        "volumes": [
<#if (eap.@configureSsl[0]!"false") == "true">
                            {
                                "name": "eap-keystore-volume",
                                "secret": {
                                    "secretName": "<@util.param "EAP_HTTPS_SECRET"/>"
                                }
                            }
</#if>
                        ]
                    }
                }
            }
        }
<#list eap?children as service>
    <#switch service?node_name>
        <#case "db">
            <#if (service.@isExternal[0]!"false") == "true">
            <#else>
                <#switch service.@type>
                    <#case "mysql">
,<@mysql.objects service, common.params/>
                    <#break>
                </#switch>
            </#if>
        <#break>
        <#case "amq">
,<@amq.objects service, common.params/>
        <#break>
    </#switch>
</#list>
</#macro>