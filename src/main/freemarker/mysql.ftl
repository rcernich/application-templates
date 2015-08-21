<#ftl ns_prefixes={"D":"urn:jboss:cloud-enablement:template-config:1.0"}>

<#import "util.ftl" as util/>

<#macro params db>
        {
            "description": "Database JNDI name used by application to resolve the datasource, e.g. java:/jboss/datasources/mysql",
            "name": "${db.@prefix?upper_case}_JNDI",
            "value": ""
        },
        {
            "description": "Database name",
            "name": "${db.@prefix?upper_case}_DATABASE",
            "value": "root"
<#if (db.@configurePersistence[0]!"false") == "true">
        },
        {
            "description": "Size of persistent storage for database volume.",
            "name": "${db.@prefix?upper_case}_VOLUME_CAPACITY",
            "value": "512Mi"
</#if>
<#if (db.@configureAdvancedSettings[0]!"false") == "true">
        },
        {
            "description": "Sets xa-pool/min-pool-size for the configured datasource.",
            "name": "${db.@prefix?upper_case}_MIN_POOL_SIZE"
        },
        {
            "description": "Sets xa-pool/max-pool-size for the configured datasource.",
            "name": "${db.@prefix?upper_case}_MAX_POOL_SIZE"
        },
        {
            "description": "Sets transaction-isolation for the configured datasource.",
            "name": "${db.@prefix?upper_case}_TX_ISOLATION"
        },
        {
            "description": "Sets how the table names are stored and compared.",
            "name": "${db.@prefix?upper_case}_LOWER_CASE_TABLE_NAMES"
        },
        {
            "description": "The maximum permitted number of simultaneous client connections.",
            "name": "${db.@prefix?upper_case}_MAX_CONNECTIONS"
        },
        {
            "description": "The minimum length of the word to be included in a FULLTEXT index.",
            "name": "${db.@prefix?upper_case}_FT_MIN_WORD_LEN"
        },
        {
            "description": "The maximum length of the word to be included in a FULLTEXT index.",
            "name": "${db.@prefix?upper_case}_FT_MAX_WORD_LEN"
        },
        {
            "description": "Controls the innodb_use_native_aio setting value if the native AIO is broken.",
            "name": "${db.@prefix?upper_case}_AIO"
</#if>
        },
        {
            "description": "Database user name",
            "name": "${db.@prefix?upper_case}_USERNAME",
            "from": "user[a-zA-Z0-9]{3}",
            "generate": "expression"
        },
        {
            "description": "Database user password",
            "name": "${db.@prefix?upper_case}_PASSWORD",
            "from": "[a-zA-Z0-9]{8}",
            "generate": "expression"
        }
</#macro>

<#macro objects db params>
        {
            "kind": "Service",
            "apiVersion": "v1",
            "spec": {
                "ports": [
                    {
                        "port": 3306,
                        "targetPort": 3306
                    }
                ],
                "selector": {
                    "deploymentConfig": "${db.@name}"
                }
            },
            "metadata": {
                "name": "${db.@name}",
                "labels": {
                    "application": "<@util.param params.applicationName/>"
                },
                "annotations": {
                    "description": "The database server's port."
                }
            }
        },
        {
            "kind": "DeploymentConfig",
            "apiVersion": "v1",
            "metadata": {
                "name": "${db.@name}",
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
                                "${db.@name}"
                            ],
                            "from": {
                                "kind": "ImageStreamTag",
                                "namespace": "<@util.param params.imageStreamNamespace/>",
                                "name": "${db.@imageStreamName}:${db.@imageStreamTag}"
                            }
                        }
                    }
                ],
                "replicas": 1,
                "selector": {
                    "deploymentConfig": "${db.@name}"
                },
                "template": {
                    "metadata": {
                        "name": "${db.@name}",
                        "labels": {
                            "deploymentConfig": "${db.@name}",
                            "application": "<@util.param params.applicationName/>"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "name": "${db.@name}",
                                "image": "${db.@imageStreamName}",
                                "imagePullPolicy": "Always",
                                "ports": [
                                    {
                                        "containerPort": 3306,
                                        "protocol": "TCP"
                                    }
                                ],
                                "volumeMounts": [
<#if (db.@configurePersistence[0]!"false") == "true">
                                    {
                                        "mountPath": "/var/lib/mysql/data",
                                        "name": "${db.@name}-pvol"
                                    }
</#if>
                                ],
                                "env": [
                                    {
                                        "name": "MYSQL_USER",
                                        "value": "<@util.param (db.@prefix?upper_case)+"_USERNAME"/>"
                                    },
                                    {
                                        "name": "MYSQL_PASSWORD",
                                        "value": "<@util.param (db.@prefix?upper_case)+"_PASSWORD"/>"
                                    },
                                    {
                                        "name": "MYSQL_DATABASE",
                                        "value": "<@util.param (db.@prefix?upper_case)+"_DATABASE"/>"
<#if (db.@configureAdvancedSettings[0]!"false") == "true">
                                    },
                                    {
                                        "name": "MYSQL_LOWER_CASE_TABLE_NAMES",
                                        "value": "<@util.param (db.@prefix?upper_case)+"_LOWER_CASE_TABLE_NAMES"/>"
                                    },
                                    {
                                        "name": "MYSQL_MAX_CONNECTIONS",
                                        "value": "<@util.param (db.@prefix?upper_case)+"_MAX_CONNECTIONS"/>"
                                    },
                                    {
                                        "name": "MYSQL_FT_MIN_WORD_LEN",
                                        "value": "<@util.param (db.@prefix?upper_case)+"_FT_MIN_WORD_LEN"/>"
                                    },
                                    {
                                        "name": "MYSQL_FT_MAX_WORD_LEN",
                                        "value": "<@util.param (db.@prefix?upper_case)+"_FT_MAX_WORD_LEN"/>"
                                    },
                                    {
                                        "name": "MYSQL_AIO",
                                        "value": "<@util.param (db.@prefix?upper_case)+"_AIO"/>"
</#if>
                                    }
                                ]
                            }
                        ],
                        "volumes": [
<#if (db.@configurePersistence[0]!"false") == "true">
                            {
                                "name": "${db.@name}-pvol",
                                "persistentVolumeClaim": {
                                    "claimName": "${db.@name}-claim"
                                }
                            }
</#if>
                        ]
                    }
                }
            }
<#if (db.@configurePersistence[0]!"false") == "true">
        },
        {
            "apiVersion": "v1",
            "kind": "PersistentVolumeClaim",
            "metadata": {
                "name": "${db.@name}-claim",
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
                        "storage": "<@util.param (db.@prefix?upper_case)+"_VOLUME_CAPACITY"/>"
                    }
                }
            }
</#if>
        }
</#macro>