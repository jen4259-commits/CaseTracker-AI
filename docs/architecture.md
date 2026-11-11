# Architecture Overview

## Goal

Create a macOS-native workflow for tracking and producing YouTube case episodes from a master PDF blueprint.

## Recommended stack

- SwiftUI for the desktop application shell
- SwiftData for local persistence
- Python bridge for parsing and extraction logic
- FFmpeg for media operations
- OpenAI API for research, narration, and summarization
- GitHub as the repository and workflow control center

## High-level application structure

```text
CaseTracker.app
├── Agent 1 - Blueprint Reader
├── Agent 2 - Research Agent
├── Agent 3 - Asset Manager
├── Agent 4 - Fact Check
├── Agent 5 - Narration/TTS
├── Agent 6 - Production Builder
├── Episode Dashboard
└── Settings
```

## Phase 1

Focus on the first application milestone:

- Import PDF
- Parse the episode deck
- Save episode metadata
- Browse episodes in a native UI

## Data model

Each episode should resolve to a structured record with fields like:

- episodeNumber
- caseName
- people
- agency
- courtDocket
- videoLinks
- sourceDocuments
- timeline
- evidenceCards
- foiaTemplate

## Repository layout

```text
CaseTracker-AI/
├── agents/
│   ├── agent1_blueprint_reader/
│   ├── agent2_research/
│   ├── agent3_assets/
│   ├── agent4_factcheck/
│   ├── agent5_narration/
│   └── agent6_production/
├── data/
│   ├── episodes/
│   ├── research/
│   ├── assets/
│   └── outputs/
├── desktop/
│   └── CaseTracker.xcodeproj
├── scripts/
├── docs/
├── README.md
└── requirements.txt
```

## Implementation guidance

The PDF is structured enough to support extraction of:

- episode numbers
- titles
- legal outcomes
- source links
- timelines
- FOIA templates
- evidence summaries

Once the first parser is working, the remaining research and production agents can be layered on top without rewriting the core system.
