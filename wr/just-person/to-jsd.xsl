<?xml version="1.0" encoding="UTF-8"?>
<stylesheet 
  version="2.0"
  xmlns:catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog"
  xmlns:data="http://example.org/data"
  xmlns:f="http://example.org/local"
  xmlns:nc="http://release.niem.gov/niem/niem-core/3.0/"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/1999/XSL/Transform">

  <output method="text"/>

  <variable name="context" as="element(data:mapping)+">
    <data:mapping prefix="nc" namespace="http://release.niem.gov/niem/niem-core/3.0/"/>
    <data:mapping prefix="j" namespace="http://release.niem.gov/niem/domains/jxdm/5.2/"/>
  </variable>

  <variable name="picked-elements" as="xs:QName*"
            select="xs:QName('nc:Person'), 
                    xs:QName('nc:Vehicle'), 
                    xs:QName('nc:ItemCategory')"/>

  <function name="f:get-prefix" as="xs:string">
    <param name="namespace-uri" as="xs:string"/>
    <variable name="mappings" as="element(data:mapping)*"
              select="$context[@namespace = $namespace-uri]"/>
    <choose>
      <when test="count($mappings) = 0">
        <message terminate="yes">No context mapping found for namespace <value-of select="$namespace-uri"/>.</message>
      </when>
      <when test="count($mappings) gt 1">
        <message terminate="yes">Too many context mappings found for namespace <value-of select="$namespace-uri"/>.</message>
      </when>
      <otherwise>
        <value-of select="exactly-one($mappings)/@prefix"/>
      </otherwise>
    </choose>
  </function>
  
  <variable name="catalog" as="document-node(element(catalog:catalog))" select="/"/>

  <function name="f:resolve-namespace" as="document-node(element(xs:schema))">
    <param name="namespace" as="xs:string"/>
    <variable name="uri" as="xs:anyURI"
              select="$catalog/catalog:catalog/catalog:uri[@name = $namespace]/@uri"/>
    <variable name="resolved-uri" as="xs:anyURI"
              select="resolve-uri($uri, base-uri($catalog))"/>
    <if test="not(doc-available($resolved-uri))">
      <message terminate="yes">
        <text>doc not available: </text>
        <value-of select="$resolved-uri"/>
      </message>
    </if>
    <sequence select="doc($resolved-uri)"/>
  </function>

  <function name="f:resolve-element" as="element(xs:element)">
    <param name="element-qname" as="xs:QName"/>
    <sequence select="exactly-one(
                        f:resolve-namespace(namespace-uri-from-QName($element-qname))
                          //xs:element[@name eq local-name-from-QName($element-qname)])"/>
  </function>
  
  <variable name="substitutions" select="f:get-all-substitutions(/)"/>

  <function name="f:get-all-substitutions" as="element(data:subst)+">
    <param name="catalog-root" as="document-node(element(catalog:catalog))"/>
    <for-each select="$catalog/catalog:catalog/catalog:uri/@name">
      <for-each select="f:resolve-namespace(.)">
        <for-each select="//xs:element[@name and @substitutionGroup]">
          <variable name="derived" as="xs:QName"
                    select="QName(ancestor::xs:schema/@targetNamespace, @name)"/>
          <variable name="base" as="xs:QName"
                    select="resolve-QName(@substitutionGroup, .)"/>
          <data:subst
            derived-namespace="{namespace-uri-from-QName($derived)}"
            derived-local-name="{local-name-from-QName($derived)}"
            base-namespace="{namespace-uri-from-QName($base)}"
            base-local-name="{local-name-from-QName($base)}"/>
        </for-each>
      </for-each>
    </for-each>
  </function>

  <function name="f:is-substitutable-for" as="xs:boolean">
    <param name="derived" as="xs:QName"/>
    <param name="base" as="xs:QName"/>
    <sequence select="($derived eq $base)
                      or (some $subst in $substitutions[
                            @derived-namespace = namespace-uri-from-QName($derived)
                            and @derived-local-name = local-name-from-QName($derived)
                          ] satisfies (
                            ($subst/@base-namespace = namespace-uri-from-QName($base)
                             and $subst/@base-local-name = local-name-from-QName($base))
                            or f:is-substitutable-for(
                                 QName($subst/@base-namespace, $subst/@base-local-name),
                                 $base)))"/>
  </function>

  <function name="f:get-substitutions" as="xs:QName*">
    <param name="element-qname" as="xs:QName"/>
    <sequence select="$element-qname,
                      for $subst in $substitutions,
                          $derived in QName($subst/@derived-namespace, 
                                            $subst/@derived-local-name)
                      return (
                        if (f:is-substitutable-for($derived,$element-qname))
                        then $derived
                        else ())"/>
  </function>

  <function name="f:to-clark-name" as="xs:string">
    <param name="qname" as="xs:QName"/>
    <value-of select="concat('{', namespace-uri-from-QName($qname),
                      '}', local-name-from-QName($qname))"/>
  </function>

  <function name="f:to-qname" as="xs:string">
    <param name="qname" as="xs:QName"/>
    <value-of select="concat(f:get-prefix(namespace-uri-from-QName($qname)), ':',
                      local-name-from-QName($qname))"/>
  </function>

  <function name="f:quote" as="xs:string">
    <param name="string" as="xs:string"/>
    <value-of select="concat('&quot;', $string, '&quot;')"/>
  </function>

  <function name="f:get-description" as="xs:string">
    <param name="component" as="element()"/>
    <value-of>
      <text>"description" : &quot;</text>
      <value-of select="exactly-one($component/xs:annotation/xs:documentation[1])"/>
      <text>&quot;&#10;</text>
    </value-of>
  </function>

  <function name="f:get-definition-ref" as="xs:string">
    <param name="element-decl" as="element(xs:element)"/>
    <variable name="type" as="xs:string"
              select="f:to-qname(resolve-QName($element-decl/@type, $element-decl))"/>
    <value-of>
      <text>"$ref" : &quot;#/definitions/</text>
      <value-of select="$type"/>
      <text>&quot;</text>
    </value-of>
  </function>

  <template match="/">
    <text>{
  "$schema" : "http://json-schema.org/draft-04/schema#",
  "properties" : {&#10;</text>

    <for-each select="$picked-elements">
      <variable name="element-decl" select="f:resolve-element(.)"/>
      <value-of select="f:quote(f:to-qname(.))"/>
      <text> : {&#10;</text>
      <value-of select="f:get-description($element-decl)"/>
      <choose>
        <when test="empty($element-decl/@abstract) and exists($element-decl/@type)">
          <text>"oneOf" : [&#10;</text>
          <text>{ </text>
          <value-of select="f:get-definition-ref($element-decl)"/>
          <text>}&#10;</text>
          <text>{ type : array&#10;</text>
          <text>items : { </text>
          <value-of select="f:get-definition-ref($element-decl)"/>
          <text>}}]&#10;</text>
        </when>
        <otherwise>"$ref" : "#/definitions/_property_is_placeholder"&#10;</otherwise>
      </choose>
      <text>}&#10;</text>
    </for-each>
      
    <text>  }
  "definitions" : {
      "_not_in_subset" : {
          "title" : "Property not included in the subset",
          "description" : "The property that referenced this definition is not included in the subset. If you wish to use this property, add the property to the subset and generate a new JSON Schema."
          "type" : "null"
      }
      "_property_is_placeholder" : {
          "title" : "Property is a placeholder"
          "description" : "The property is a placeholder, which is not allowed to occur in a JSON document. It appears in this schema for documentation purposes, to help the reader understand a core concept on which a concrete property is based."
          "type" : "null"
      }
      "structures:ObjectType" : {
        type : object
        patternProperties : {
          "^ism:.*" : {
      type : string
      }
      "^ntk:.*" : {
      type : string
      }
      }
            properties : {
      "@id" : {
      format : uriref
      }
      "@base" : {
      format : uriref
      } 
            }
        }
  }
}&#10;</text>
  </template>

</stylesheet>
