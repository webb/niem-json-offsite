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

### Top-level JSON Schema object

The top-level JSON Schema object is the default against which an instance will
be validated against a JSON Schema document. 

A developer that extends a JSON Schema will do so in their own separate, local
JSON Schema document, and reference the NIEM JSON Schema document, so the
top-level JSON Schema object wouldn't be what the instance is validated against.

#### "properties" of the top-level JSON Schema object

The "properties" in the top-level JSON Schema object contains zero-to-unbounded
definitions of all the elements in the subset. This means that they use an idiom
that defines a property as a single value **or** an array of values. 

Any other cardinality would be done locally, within a type, and might express
cardinality of an element within that type.

#### "definitions" of the top-level JSON Schema object

The "definitions" in the top-level JSON Schema object contains type definitions
for all the types in the subset.

### Documented enumerations

Enumerations may be documented in JSON Schema by combining "oneOf" and single-item "enum" keywords.

```json
    "ncic:HAICodeType": {
      "type": "string",
      "oneOf" : [
        { "enum": [ "BLD" ], "description": "Bald" },
        { "enum": [ "BLK" ], "description": "Black" },
        ...
    }
```

From [ncic.jsd](sar/JSchema/ncic.jsd) in [Scott's JSchema folder](sar/JSchema).

### Element declarations

Element declarations are done by setting values for "properties" in a JSON schema object. 

## XML Schema things and how they turn into JSON Schema

### Abstract elements

Omit abstract elements. Just include any available substitutions for the
abstract elements.

### Substitution groups

Include any substitutable elements in addition to the base element (the
"substitution group head").

## Element occurrences

### Elements with substitutions and abstracts

Include the full cardinality for every element that can appear in the element
occurrence. Omit any elements that are abstract.

### Cardinality (0,n)

Reference the declaration in the top-level JSON object's "properties" entry.

### Cardinality (0,1)

TBD if we have to cover this case.

### Cardinality (1,1)

TBD if we have to cover this case.

### Cardinality (1,n)

TBD if we have to cover this case.
