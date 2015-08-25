<#ftl ns_prefixes={"D":"urn:jboss:cloud-enablement:template-config:1.0"}>

<#import "eap.ftl" as eap/>
<#import "amq.ftl" as amq/>

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
<#list .node.config?children as deployment>
    <#switch deployment?node_name>
        <#case "eap">
<@eap.params deployment, .node.config.common />
        <#break>
        <#case "amq">
<@amq.params deployment/>
        <#break>
    </#switch>
</#list>
    ],
    "objects": [
<#list .node.config?children as deployment>
    <#switch deployment?node_name>
        <#case "eap">
<@eap.objects deployment, .node.config.common />
        <#break>
        <#case "amq">
<@amq.objects deployment, .node.config.common.params />
        <#break>
    </#switch>
</#list>
    ]
}
