<#ftl ns_prefixes={"D":"urn:jboss:cloud-enablement:template-config:1.0"}>

<#import "util.ftl" as util/>
<#import "common.ftl" as generic/>

<#assign includeRelease=true/>

<#macro params amq common="">
<#if common??>
<#else>
<@generic.params common false true/>,
</#if>
<#if includeRelease>
        {
            "description": "ActiveMQ Release version, e.g. 6.2, etc.",
            "name": "AMQ_RELEASE",
            "value": "6.2"
        },
</#if>
        {
            "description": "Protocol to configure.  Only openwire is supported by EAP.  amqp, amqp+ssl, mqtt, stomp, stomp+ssl, and ssl are not supported by EAP",
            "name": "${amq.@prefix?upper_case}_PROTOCOL",
            "value": "openwire"
        },
        {
            "description": "Queue names",
            "name": "${amq.@prefix?upper_case}_QUEUES",
            "value": ""
        },
        {
            "description": "Topic names",
            "name": "${amq.@prefix?upper_case}_TOPICS",
            "value": ""
<#if (amq.@configurePersistence[0]!"false") == "true">
        },
        {
            "description": "Size of persistent storage for database volume.",
            "name": "${amq.@prefix?upper_case}_VOLUME_CAPACITY",
            "value": "512Mi"
</#if>
        },
        {
            "description": "Broker user name",
            "name": "${amq.@prefix?upper_case}_USERNAME",
            "from": "user[a-zA-Z0-9]{3}",
            "generate": "expression"
        },
        {
            "description": "Broker user password",
            "name": "${amq.@prefix?upper_case}_PASSWORD",
            "from": "[a-zA-Z0-9]{8}",
            "generate": "expression"
        },
        {
            "description": "ActiveMQ Admin User",
            "name": "${amq.@prefix?upper_case}_ADMIN_USERNAME",
            "from": "user[a-zA-Z0-9]{3}",
            "generate": "expression"
        },
        {
            "description": "ActiveMQ Admin Password",
            "name": "${amq.@prefix?upper_case}_ADMIN_PASSWORD",
            "from": "[a-zA-Z0-9]{8}",
            "generate": "expression"
<#if (amq.@configureSsl[0]!"false") == "true">
        },
        {
            "description": "Name of a secret containing SSL related files",
            "name": "${amq.@prefix?upper_case}_SECRET",
            "value": "amq-app-secret"
        },
        {
            "description": "SSL trust store filename",
            "name": "${amq.@prefix?upper_case}_TRUSTSTORE",
            "value": "broker.ts"
        },
        {
            "description": "SSL key store filename",
            "name": "${amq.@prefix?upper_case}_KEYSTORE",
            "value": "broker.ks"
</#if>
        }
</#macro>

<#macro objects amq params>
        {
            "kind": "Service",
            "apiVersion": "v1",
            "spec": {
                "ports": [
                    {
                        "port": 5672,
                        "targetPort": 5672
                    }
                ],
                "selector": {
                    "deploymentConfig": "${amq.@name}"
                }
            },
            "metadata": {
                "name": "${amq.@name}-amqp",
                "labels": {
                    "application": "<@util.param params.applicationName/>"
                },
                "annotations": {
                    "description": "The broker's amqp port."
                }
            }
        },
        {
            "kind": "Service",
            "apiVersion": "v1",
            "spec": {
                "ports": [
                    {
                        "port": 5671,
                        "targetPort": 5671
                    }
                ],
                "selector": {
                    "deploymentConfig": "${amq.@name}"
                }
            },
            "metadata": {
                "name": "${amq.@name}-amqp-ssl",
                "labels": {
                    "application": "<@util.param params.applicationName/>"
                },
                "annotations": {
                    "description": "The broker's amqp ssl port."
                }
            }
        },
        {
            "kind": "Service",
            "apiVersion": "v1",
            "spec": {
                "ports": [
                    {
                        "port": 1883,
                        "targetPort": 1883
                    }
                ],
                "selector": {
                    "deploymentConfig": "${amq.@name}"
                }
            },
            "metadata": {
                "name": "${amq.@name}-mqtt",
                "labels": {
                    "application": "<@util.param params.applicationName/>"
                },
                "annotations": {
                    "description": "The broker's mqtt port."
                }
            }
        },
        {
            "kind": "Service",
            "apiVersion": "v1",
            "spec": {
                "ports": [
                    {
                        "port": 61613,
                        "targetPort": 61613
                    }
                ],
                "selector": {
                    "deploymentConfig": "${amq.@name}"
                }
            },
            "metadata": {
                "name": "${amq.@name}-stomp",
                "labels": {
                    "application": "<@util.param params.applicationName/>"
                },
                "annotations": {
                    "description": "The broker's stomp port."
                }
            }
        },
        {
            "kind": "Service",
            "apiVersion": "v1",
            "spec": {
                "ports": [
                    {
                        "port": 61612,
                        "targetPort": 61612
                    }
                ],
                "selector": {
                    "deploymentConfig": "${amq.@name}"
                }
            },
            "metadata": {
                "name": "${amq.@name}-stomp-ssl",
                "labels": {
                    "application": "<@util.param params.applicationName/>"
                },
                "annotations": {
                    "description": "The broker's stomp ssl port."
                }
            }
        },
        {
            "kind": "Service",
            "apiVersion": "v1",
            "spec": {
                "ports": [
                    {
                        "port": 61616,
                        "targetPort": 61616
                    }
                ],
                "selector": {
                    "deploymentConfig": "${amq.@name}"
                }
            },
            "metadata": {
                "name": "${amq.@name}-tcp",
                "labels": {
                    "application": "<@util.param params.applicationName/>"
                },
                "annotations": {
                    "description": "The broker's tcp (openwire) port."
                }
            }
        },
        {
            "kind": "Service",
            "apiVersion": "v1",
            "spec": {
                "ports": [
                    {
                        "port": 61617,
                        "targetPort": 61617
                    }
                ],
                "selector": {
                    "deploymentConfig": "${amq.@name}"
                }
            },
            "metadata": {
                "name": "${amq.@name}-tcp-ssl",
                "labels": {
                    "application": "<@util.param params.applicationName/>"
                },
                "annotations": {
                    "description": "The broker's tcp ssl (openwire) port."
                }
            }
        },
        {
            "kind": "DeploymentConfig",
            "apiVersion": "v1",
            "metadata": {
                "name": "${amq.@name}",
                "labels": {
                    "application": "<@util.param params.applicationName/>"
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
                                "${amq.@name}"
                            ],
                            "from": {
                                "kind": "ImageStreamTag",
                                "namespace": "<@util.param params.imageStreamNamespace/>",
                                "name": "${amq.@imageStreamName}:${amq.@imageStreamTag}"
                            }
                        }
                    }
                ],
                "replicas": 1,
                "selector": {
                    "deploymentConfig": "${amq.@name}"
                },
                "template": {
                    "metadata": {
                        "name": "${amq.@name}",
                        "labels": {
                            "deploymentConfig": "${amq.@name}",
                            "application": "<@util.param params.applicationName/>"
                        }
                    },
                    "spec": {
<#if (amq.@configureSsl[0]!"false") == "true">
                        "serviceAccount": "amq-service-account",
</#if>
                        "containers": [
                            {
                                "name": "${amq.@name}",
                                "image": "${amq.@imageStreamName}",
                                "imagePullPolicy": "Always",
                                "volumeMounts": [
<#if (amq.@configureSsl[0]!"false") == "true">
                                    {
                                        "name": "broker-secret-volume",
                                        "mountPath": "/etc/amq-secret-volume",
                                        "readOnly": true
<#if (amq.@configurePersistence[0]!"false") == "true">
                                    },
<#else>
                                    }
</#if>
</#if>
<#if (amq.@configurePersistence[0]!"false") == "true">
                                    {
                                        "mountPath": "/opt/amq/data/kahadb",
                                        "name": "${amq.@name}-pvol"
                                    }
</#if>
                                ],
                                "readinessProbe": {
                                    "exec": {
                                        "command": [
                                            "/bin/bash",
                                            "-c",
                                            "curl -s -L -u <@util.param (amq.@prefix?upper_case)+"_ADMIN_USERNAME"/>:<@util.param (amq.@prefix?upper_case)+"_ADMIN_PASSWORD"/> 'http://localhost:8161/hawtio/jolokia/read/org.apache.activemq:type=Broker,brokerName=*,service=Health/CurrentStatus' | grep -q '\"CurrentStatus\" *: *\"Good\"'"
                                        ]
                                    }
                                },
                                "ports": [
                                    {
                                        "name": "amqp",
                                        "containerPort": 5672,
                                        "protocol": "TCP"
                                    },
                                    {
                                        "name": "amqp-ssl",
                                        "containerPort": 5671,
                                        "protocol": "TCP"
                                    },
                                    {
                                        "name": "mqtt",
                                        "containerPort": 1883,
                                        "protocol": "TCP"
                                    },
                                    {
                                        "name": "stomp",
                                        "containerPort": 61613,
                                        "protocol": "TCP"
                                    },
                                    {
                                        "name": "stomp-ssl",
                                        "containerPort": 61612,
                                        "protocol": "TCP"
                                    },
                                    {
                                        "name": "tcp",
                                        "containerPort": 61616,
                                        "protocol": "TCP"
                                    },
                                    {
                                        "name": "tcp-ssl",
                                        "containerPort": 61617,
                                        "protocol": "TCP"
                                    }
                                ],
                                "env": [
                                    {
                                        "name": "AMQ_USER",
                                        "value": "<@util.param (amq.@prefix?upper_case)+"_USERNAME"/>"
                                    },
                                    {
                                        "name": "AMQ_PASSWORD",
                                        "value": "<@util.param (amq.@prefix?upper_case)+"_PASSWORD"/>"
                                    },
                                    {
                                        "name": "AMQ_PROTOCOLS",
                                        "value": "<@util.param (amq.@prefix?upper_case)+"_PROTOCOL"/>"
                                    },
                                    {
                                        "name": "AMQ_QUEUES",
                                        "value": "<@util.param (amq.@prefix?upper_case)+"_QUEUES"/>"
                                    },
                                    {
                                        "name": "AMQ_TOPICS",
                                        "value": "<@util.param (amq.@prefix?upper_case)+"_TOPICS"/>"
                                    },
                                    {
                                        "name": "AMQ_ADMIN_USERNAME",
                                        "value": "<@util.param (amq.@prefix?upper_case)+"_ADMIN_USERNAME"/>"
                                    },
                                    {
                                        "name": "AMQ_ADMIN_PASSWORD",
                                        "value": "<@util.param (amq.@prefix?upper_case)+"_ADMIN_PASSWORD"/>"
<#if (amq.@configurePersistence[0]!"false") != "true">
                                    },
                                    {
                                        "name": "AMQ_MESH_SERVICE_NAME",
                                        "value": "${amq.@name}-tcp"
</#if>
<#if (amq.@configureSsl[0]!"false") == "true">
                                    },
                                    {
                                        "name": "AMQ_KEYSTORE_TRUSTSTORE_DIR",
                                        "value": "/etc/amq-secret-volume"
                                    },
                                    {
                                        "name": "AMQ_TRUSTSTORE",
                                        "value": "<@util.param (amq.@prefix?upper_case)+"_TRUSTSTORE"/>"
                                    },
                                    {
                                        "name": "AMQ_KEYSTORE",
                                        "value": "<@util.param (amq.@prefix?upper_case)+"_KEYSTORE"/>"
</#if>
                                    }
                                ]
                            }
                        ],
                        "volumes": [
<#if (amq.@configureSsl[0]!"false") == "true">
                            {
                                "name": "broker-secret-volume",
                                "secret": {
                                    "secretName": "<@util.param (amq.@prefix?upper_case)+"_SECRET"/>"
                                }
<#if (amq.@configurePersistence[0]!"false") == "true">
                            },
<#else>
                            }
</#if>
</#if>
<#if (amq.@configurePersistence[0]!"false") == "true">
                            {
                                "name": "${amq.@name}-pvol",
                                "persistentVolumeClaim": {
                                    "claimName": "${amq.@name}-claim"
                                }
                            }
</#if>
                        ]
                    }
                }
            }
<#if (amq.@configurePersistence[0]!"false") == "true">
        },
        {
            "apiVersion": "v1",
            "kind": "PersistentVolumeClaim",
            "metadata": {
                "name": "${amq.@name}-claim",
                "labels": {
                    "application": "<@util.param params.applicationName/>"
                }
            },
            "spec": {
                "accessModes": [
                    "ReadWriteOnce"
                ],
                "resources": {
                    "requests": {
                        "storage": "<@util.param (amq.@prefix?upper_case)+"_VOLUME_CAPACITY"/>"
                    }
                }
            }
</#if>
        }
</#macro>