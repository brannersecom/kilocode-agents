#!/usr/bin/env python3
"""Generate `.kilocodemodes` from `.claude-plugin/marketplace.json`.

This keeps Kilo Code modes in sync with the canonical plugin catalog.
"""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from pathlib import Path


GROUPS = ["read", "edit", "browser", "command", "mcp"]


@dataclass
class AgentSource:
    plugin_name: str
    plugin_description: str
    path: Path
    index: int


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="Repository root path (defaults to script parent's parent).",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=None,
        help="Output file path (defaults to <repo>/.kilocodemodes).",
    )
    return parser.parse_args()


def parse_frontmatter(content: str) -> tuple[dict[str, str], str]:
    if not content.startswith("---\n"):
        return {}, content.strip()

    end = content.find("\n---\n", 4)
    if end == -1:
        return {}, content.strip()

    frontmatter_block = content[4:end]
    body = content[end + 5 :].strip()

    metadata: dict[str, str] = {}
    for raw_line in frontmatter_block.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or ":" not in line:
            continue
        key, value = line.split(":", 1)
        metadata[key.strip()] = value.strip().strip("'\"")

    return metadata, body


def to_slug(value: str) -> str:
    slug = value.strip().lower()
    slug = slug.replace("_", "-")
    slug = re.sub(r"[^a-z0-9-]+", "-", slug)
    slug = re.sub(r"-{2,}", "-", slug).strip("-")
    return slug or "mode"


def to_title(value: str) -> str:
    words = re.split(r"[-_]+", value.strip())
    return " ".join(w.capitalize() for w in words if w)


def extract_when_to_use(description: str, fallback: str) -> str:
    if description:
        match = re.search(
            r"use\s+proactively\s+for\s+(.+?)(?:\.|$)", description, flags=re.IGNORECASE
        )
        if match:
            return f"Use when {match.group(1).strip()}."
    return fallback


def resolve_agent_sources(repo_root: Path) -> list[AgentSource]:
    marketplace_path = repo_root / ".claude-plugin" / "marketplace.json"
    marketplace = json.loads(marketplace_path.read_text(encoding="utf-8"))

    sources: list[AgentSource] = []
    seen_paths: set[Path] = set()
    index = 0

    for plugin in marketplace.get("plugins", []):
        plugin_name = plugin.get("name", "plugin")
        plugin_description = plugin.get("description", "").strip()
        source_dir = repo_root / plugin.get("source", "").replace("./", "")

        for agent_rel in plugin.get("agents", []):
            agent_path = source_dir / agent_rel.replace("./", "")
            normalized = agent_path.resolve()
            if normalized in seen_paths:
                continue
            seen_paths.add(normalized)
            sources.append(
                AgentSource(
                    plugin_name=plugin_name,
                    plugin_description=plugin_description,
                    path=agent_path,
                    index=index,
                )
            )
            index += 1

    return sources


def generate_modes(repo_root: Path) -> list[dict]:
    agent_sources = resolve_agent_sources(repo_root)
    slug_counts: dict[str, int] = {}
    used_slugs: set[str] = set()
    modes: list[dict] = []

    # First pass: count base slug collisions.
    base_slugs: list[str] = []
    for source in agent_sources:
        text = source.path.read_text(encoding="utf-8")
        metadata, _ = parse_frontmatter(text)
        base_slug = to_slug(metadata.get("name", source.path.stem))
        base_slugs.append(base_slug)
        slug_counts[base_slug] = slug_counts.get(base_slug, 0) + 1

    collision_seen: dict[str, int] = {}

    # Second pass: build mode definitions.
    for source, base_slug in zip(agent_sources, base_slugs):
        text = source.path.read_text(encoding="utf-8")
        metadata, role_definition = parse_frontmatter(text)
        description = metadata.get("description", "").strip()

        collision_seen[base_slug] = collision_seen.get(base_slug, 0) + 1
        collision_index = collision_seen[base_slug]

        # Keep the base slug for the first mode; suffix duplicates.
        if collision_index == 1:
            candidate_slug = base_slug
        else:
            candidate_slug = to_slug(f"{source.plugin_name}-{base_slug}")

        slug = candidate_slug
        suffix = 2
        while slug in used_slugs:
            slug = f"{candidate_slug}-{suffix}"
            suffix += 1
        used_slugs.add(slug)

        name = to_title(base_slug)
        if slug_counts[base_slug] > 1:
            if collision_index == 1:
                name = f"{name} ({source.plugin_name})"
            else:
                name = f"{name} ({source.plugin_name} #{collision_index})"

        fallback_when_to_use = (
            f"Use when working in the {source.plugin_name} plugin domain."
        )

        mode = {
            "slug": slug,
            "name": name,
            "roleDefinition": role_definition,
            "description": description,
            "whenToUse": extract_when_to_use(description, fallback_when_to_use),
            "groups": GROUPS,
            "source": "project",
        }
        modes.append(mode)

    return modes


def main() -> int:
    args = parse_args()
    repo_root = args.repo_root.resolve()
    output_path = (args.output or (repo_root / ".kilocodemodes")).resolve()

    modes = generate_modes(repo_root)
    payload = {"customModes": modes}
    output_path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print(f"Wrote {len(modes)} modes to {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
