# Agent 1: Blueprint Reader

This folder is reserved for the blueprint parsing agent.

## Responsibilities

- load the master PDF source
- extract episode metadata
- convert the PDF content into structured JSON records
- package episode data for the local database and GitHub workflow

## Planned workflow

1. import the source PDF
2. parse the master episode deck
3. identify episode names, dockets, videos, and timelines
4. normalize data into a consistent episode schema
5. save output into `data/episodes/`

## Example output

```json
{
  "episodeNumber": 5,
  "caseName": "Example Case",
  "people": [],
  "agency": "",
  "courtDocket": "",
  "videoLinks": [],
  "timeline": [],
  "foiaTemplate": {}
}
```
