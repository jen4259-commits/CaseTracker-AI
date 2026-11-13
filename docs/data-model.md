# Pilot 1 Data Model

This document defines the first-pass records for cases, sources, evidence, and episodes. The JSON Schema files under `data/schemas/` are the machine-readable contracts. IDs are stable UUIDs; timestamps are ISO 8601 UTC strings. Fields should be extended through versioned migrations rather than silently repurposed.

## Relationships

- A case has many sources, evidence items, claims, timeline events, and episodes.
- A source may support multiple evidence items and claims.
- Evidence records identify material and provenance; a claim is an editorial assertion that must cite evidence/sources.
- An episode belongs to one case and contains ordered segments. Segments may reference claims, evidence, and media assets.
- Media assets should have their own records as the next schema addition; until then, episode/evidence references use stable asset IDs or repository-relative paths.

## Case

The case is the research and production workspace. Important fields include title, category, case type, jurisdiction, summary, key people, story angle, lifecycle status, verification status, and episode status. Store factual descriptions neutrally and identify allegations as allegations.

## Source

A source records a document, webpage, recording, transcript, or other reference. Store its title, type, URL or citation, publisher/author, publication and retrieval dates, summary, verification state, confidence assessment, and reviewer notes. Keep the original URL and access details; do not overwrite source metadata when a copy or derivative is created.

## Evidence

An evidence item identifies a specific passage, page, timestamp, exhibit, or media segment associated with a source and case. Record a neutral label, evidence type, locator, file reference if applicable, verification state, context notes, and rights/usage status. Evidence is not automatically proof of a claim.

## Episode

An episode is a production record linked to a case. It tracks title, outline, script, target/runtime, format, lifecycle status, ordered segments, export location, and review state. Publication must be blocked until required factual, rights, editorial, and export approvals are complete.

## Verification states

Use explicit states rather than a boolean wherever possible:

- `unreviewed`: not yet assessed
- `in_review`: review underway
- `supported`: reviewed and supported by cited material
- `partially_supported`: some elements supported; gaps remain
- `conflicted`: material sources disagree
- `unsupported`: reviewed but lacks adequate support
- `rejected`: contradicted or otherwise unsuitable

These statuses describe the review record, not an absolute guarantee of truth. Include reviewer identity and review timestamp in production implementations.

## Data handling

Do not put secrets, private credentials, or unnecessary sensitive personal data in records. Keep large media files outside Git; store a controlled repository-relative asset reference, checksum, provenance, and access/rights notes. A URL alone is not a preservation strategy.
