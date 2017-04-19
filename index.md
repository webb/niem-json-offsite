---
title: NIEM JSON Offsite
---

# {{page.title}}

Notes and artifacts supporting the NIEM Technical Specifications Focus Group's
efforts to standardize use of JSON with NIEM.

# JSON Schema Validators

## Webb: ajv

### Installation

```bash
$ sudo npm install -g ajv ajv-cli
```
  
### Usage 

See [AJV usage docs](https://github.com/jessedc/ajv-cli). 

#### Test if a file is valid JSON:

```bash
ajv -s schema.jsd -d $file.json
```

Where empty.xsd is:

```json
{
}
```

#### Test a file against a real schema

