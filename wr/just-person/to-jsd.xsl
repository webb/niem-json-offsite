<?xml version="1.0" encoding="UTF-8"?>
<stylesheet 
  version="2.0"
  xmlns:catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog"
  xmlns:f="http://example.org/functions"
  xmlns:nc="http://release.niem.gov/niem/niem-core/3.0/"
  xmlns:subst="http://example.org/substitutions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/1999/XSL/Transform">

  <output method="text"/>

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
  
  <variable name="substitutions" select="f:get-all-substitutions(/)"/>

  <function name="f:get-all-substitutions" as="element(subst:subst)+">
    <param name="catalog-root" as="document-node(element(catalog:catalog))"/>
    <for-each select="$catalog/catalog:catalog/catalog:uri/@name">
      <for-each select="f:resolve-namespace(.)">
        <for-each select="//xs:element[@name and @substitutionGroup]">
          <variable name="derived" as="xs:QName"
                    select="QName(ancestor::xs:schema/@targetNamespace, @name)"/>
          <variable name="base" as="xs:QName"
                    select="resolve-QName(@substitutionGroup, .)"/>
          <subst:subst
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

  <template match="/">
    <text>{
  "$schema" : "http://json-schema.org/draft-04/schema#",
  "properties" : {&#10;</text>

    <value-of select="string-join(for $s in f:get-substitutions(xs:QName('nc:ItemCategory')) return f:to-clark-name($s), ', ')"/>
    <text>&#10;</text>
      
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
  }
}&#10;</text>
  </template>

</stylesheet>
