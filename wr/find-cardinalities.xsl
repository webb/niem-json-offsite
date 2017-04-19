<?xml version="1.0" encoding="UTF-8"?>
<stylesheet 
  xmlns="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  version="2.0">

  <output method="text"/>

  <template match="text()"/>

  <template match="xs:element[@ref]">
    <choose>
      <when test="@minOccurs">
        <value-of select="@minOccurs"/>
      </when>
      <otherwise>1</otherwise>
    </choose>
    <text>-</text>
    <choose>
      <when test="@maxOccurs">
        <value-of select="@maxOccurs"/>
      </when>
      <otherwise>1</otherwise>
    </choose>
    <text>&#10;</text>
  </template>

</stylesheet>
<!--
Local Variables:
mode: sgml
indent-tabs-mode: nil
fill-column: 9999
End:
-->
