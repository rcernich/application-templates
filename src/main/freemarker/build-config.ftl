<#ftl ns_prefixes={"D":"urn:jboss:cloud-enablement:template-config:1.0"}>

<#import "util.ftl" as util/>
<#macro config common imageStreamName imageStreamTag buildImageStreamTag>
        {
            "kind": "ImageStream",
            "apiVersion": "v1",
            "metadata": {
                "name": "${imageStreamName}",
                "labels": {
                    "application": "<@util.param common.params.applicationName/>"
                }
            }
        },
        {
            "kind": "BuildConfig",
            "apiVersion": "v1",
            "metadata": {
                "name": "${imageStreamName}",
                "labels": {
                    "application": "<@util.param common.params.applicationName/>"
                }
            },
            "spec": {
                "source": {
                    "type": "Git",
                    "git": {
                        "uri": "<@util.param common.params.gitUri/>",
                        "ref": "<@util.param common.params.gitRef/>"
                    },
                    "contextDir": "<@util.param common.params.gitContextDir/>"
                },
                "strategy": {
                    "type": "Source",
                    "sourceStrategy": {
                        "from": {
                            "kind": "ImageStreamTag",
                            "namespace": "<@util.param common.params.imageStreamNamespace/>",
                            "name": "${buildImageStreamTag}"
                        }
                    }
                },
                "output": {
                    "to": {
                        "kind": "ImageStreamTag",
                        "name": "${imageStreamName}:${imageStreamTag}"
                    }
                },
                "triggers": [
                    {
                        "type": "GitHub",
                        "github": {
                            "secret": "<@util.param common.params.githubTriggerSecret/>"
                        }
                    },
                    {
                        "type": "Generic",
                        "generic": {
                            "secret": "<@util.param common.params.genericTriggerSecret/>"
                        }
                    },
                    {
                        "type": "ImageChange",
                        "imageChange": {}
                    }
                ]
            }
        }
</#macro>