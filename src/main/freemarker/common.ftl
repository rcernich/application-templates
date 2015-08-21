<#ftl ns_prefixes={"D":"urn:jboss:cloud-enablement:template-config:1.0"}>

<#import "util.ftl" as util/>

<#macro params common includeSti=false noRoutes=true>
        {
            "description": "The name for the application.",
            "name": "${common.params.applicationName}",
            "value": "${common.params.applicationName.@default[0]!""}"
<#if !noRoutes>
        },
        {
            "description": "Custom hostname for service routes.  Leave blank for default hostname, e.g.: <application-name>.<project>.<default-domain-suffix>",
            "name": "${common.params.applicationHostName}",
            "value": "${common.params.applicationHostName.@default[0]!""}"
</#if>
<#if includeSti>
        },
        {
            "description": "Git source URI for application",
            "name": "${common.params.gitUri}",
            "value": "${common.params.gitUri.@default[0]!""}"
        },
        {
            "description": "Git branch/tag reference",
            "name": "${common.params.gitRef}",
            "value": "${common.params.gitRef.@default[0]!""}"
        },
        {
            "description": "Path within Git project to build; empty for root project directory.",
            "name": "${common.params.gitContextDir}",
            "value": "${common.params.gitContextDir.@default[0]!""}"
        },
        {
            "description": "GitHub trigger secret",
            "name": "${common.params.githubTriggerSecret}",
            "from": "[a-zA-Z0-9]{8}",
            "generate": "expression"
        },
        {
            "description": "Generic build trigger secret",
            "name": "${common.params.genericTriggerSecret}",
            "from": "[a-zA-Z0-9]{8}",
            "generate": "expression"
</#if>
        },
        {
            "description": "Namespace in which the ImageStreams for Red Hat Middleware images are installed. These ImageStreams are normally installed in the openshift namespace. You should only need to modify this if you've installed the ImageStreams in a different namespace/project.",
            "name": "${common.params.imageStreamNamespace}",
            "value": "${common.params.imageStreamNamespace.@default[0]!""}"
        }
</#macro>
