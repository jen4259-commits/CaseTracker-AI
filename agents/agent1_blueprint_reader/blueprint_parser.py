from pathlib import Path
import json

try:
    from pypdf import PdfReader
except ImportError:
    PdfReader = None


def extract_text_from_pdf(pdf_path: str) -> str:
    """Read a PDF and return the extracted text content."""
    if PdfReader is None:
        raise RuntimeError("pypdf is not installed. Run: pip install pypdf")

    reader = PdfReader(pdf_path)
    pages = []
    for page in reader.pages:
        text = page.extract_text() or ""
        pages.append(text)
    return "\n\n".join(pages)


def build_episode_record(raw_text: str, episode_number: int = 1) -> dict:
    """Create a starter JSON record from a PDF transcript/text extract."""
    lines = [line.strip() for line in raw_text.splitlines() if line.strip()]
    return {
        "episodeNumber": episode_number,
        "caseName": lines[0] if lines else "Untitled",
        "people": [],
        "agency": "",
        "courtDocket": "",
        "videoLinks": [],
        "timeline": [],
        "notes": "\n".join(lines[:10]) if lines else "",
    }


if __name__ == "__main__":
    pdf_path = Path("data/blueprints/source.pdf")
    if not pdf_path.exists():
        print(json.dumps({"status": "not_found", "message": "No PDF file found at data/blueprints/source.pdf"}, indent=2))
    else:
        text = extract_text_from_pdf(str(pdf_path))
        episode = build_episode_record(text)
        print(json.dumps(episode, indent=2))
