---
title: Just "nc:Person"
---

# {{page.title}}

Imagine that you went into the Movement tool and picked ONLY nc:Person. What would you get as a resulting JSON Schema?

## How

to-jsd.xsl is an XSLT that takes in the root XML catalog for the NIEM 3.2
release. It outputs a JSD that represents what you'd get if you only picked
nc:Person. It's not meant to be very smart.

It outputs hjson, just to make the process easier to deal with. 
