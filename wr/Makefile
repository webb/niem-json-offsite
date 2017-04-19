
json_schema_files = ${wildcard *.jsd}
json_files = ${wildcard *.json}
xml_files = ${wildcard *.xml}

validate_xml_targets = ${xml_files:%=tmp/valid/%}
validate_targets = ${validate_xml_targets} ${json_files:%=tmp/valid/%} 

.PHONY: validate
validate: ${validate_targets}

.PHONY: validate-xml
validate-xml: ${validate_xml_targets}

tmp/valid/%.json: %.json ${json_schema_files}
	ajv -s niem.jsd -d $< ${json_schema_files:%=-r %}
	mkdir -p ${dir $@} && touch $@

tmp/valid/%.xml: %.xml 
	xs-validate -c niem/xml-catalog.xml $<
	mkdir -p ${dir $@} && touch $@

.PHONY: subset
subset:
	rm -rf niem
	unzip ${shell ${HOME}/bin/get-newest ${wildcard ${HOME}/Downloads/Subset_*.zip}}

.PHONY: clean
clean:
	rm -rf tmp
