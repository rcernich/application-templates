<#ftl ns_prefixes={"D":"urn:jboss:cloud-enablement:template-config:1.0"}>

<#import "eap.ftl" as eap/>

{
    "kind": "Template",
    "apiVersion": "v1",
    "metadata": {
        "annotations": {
            "iconClass": "${.node.config.@templateIcon[0]!""}",
            "description": "${(.node.config.description[0]!"No description!!!")?trim}"
        },
        "name": "${.node.config.@templateName[0]!"custom-template"}"
    },
    "labels": {
        "template": "${.node.config.@templateName[0]!"custom-template"}"
    },
    "parameters": [
<#if .node.config.eap?has_content>
<@eap.params .node.config.common, .node.config.eap/>
</#if>
    ],
    "objects": [
<#if .node.config.eap?has_content>
<@eap.objects .node.config.common, .node.config.eap/>
</#if>
    ]
}
