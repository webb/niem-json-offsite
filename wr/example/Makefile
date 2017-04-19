
jsd_hjson = ${wildcard *.jsd.hjson}
jsd = ${jsd_hjson:%.jsd.hjson=%.jsd}

instance_hjson = ${wildcard i*.json.hjson}
instance = ${instance_hjson:%.json.hjson=%.json}

default: ${jsd} ${instance} valid

valid: ${instance:%.json=tmp/valid/%.json}

tmp/valid/%.json: %.json niem.jsd
	ajv -s niem.jsd -d $<
	mkdir -p ${dir $@} && touch $@

%.jsd: %.jsd.hjson
	rm -f $@
	hjson -j $< > $@
	chmod 444 $@

%.json: %.json.hjson
	rm -f $@
	hjson -j $< > $@
	chmod 444 $@

.PHONY: clean
clean:
	rm -f ${instance} ${jsd}
	rm -rf tmp


