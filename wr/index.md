---
title: Webb's folder
---

# {{page.title}}

My approach: first focus on an open-content-model schema that is very readable
and extensible.

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
ajv -s empty.jsd -d $file.json
```

Where empty.xsd is:

```json
{
}
```

#### Test a file against a real schema

# JSON-LD issues

I can't figure out how to make an instance reference a context that's a local
file in the same directory.


