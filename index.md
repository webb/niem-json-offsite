---
title: NIEM JSON Offsite
---

# {{page.title}}

Notes and artifacts supporting the NIEM Technical Specifications Focus Group's
efforts to standardize use of JSON with NIEM.

[Webb's working folder](wr)

## JSON Schema keywords

### keyword "$schema"

Identifies what version of JSON Schema is in play. Use this:

```json
"$schema" : "http://json-schema.org/draft-04/schema#",
```

### keyword "definitions"

A section of a JSON schema that doesn't take part in validation. It's where you
hide data definitions. Put definitions of types and other reusable things there.

## JSON Schema patterns and conventions



