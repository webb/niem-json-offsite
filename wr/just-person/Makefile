
niem_catalog = ${HOME}/r/niem/release/distro/xml-catalog.xml
jsd = niem.jsd
hjson = ${jsd}.hjson
catalogs = ${HOME}/r/by-topic/schemas/xml-catalog/xml-catalog.xml

default: ${jsd}

${jsd}: ${hjson}
	hjson -j $< > $@

${hjson}: ${niem_catalog} to-jsd.xsl
	java -classpath ${HOME}/share/saxon-cli/Saxon-HE-9.7.0-7.jar:${HOME}/share/xml-schema-validator/xml-resolver-1.2.jar net.sf.saxon.Transform -s:$< -o:$@ -xsl:to-jsd.xsl ${catalogs:%=-catalog:%}

.PHONY: clean
clean:
	rm -f ${jsd} ${hjson}

