#!/usr/bin/env python3
"""Generate Codex adapter assets from `.claude-plugin/marketplace.json`.

Outputs:
- AGENTS.md
- .codex/registry.json
- .codex/skills-index.md
- .codex/agents-index.md
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="Repository root path (defaults to script parent's parent).",
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
    return slug or "item"


def extract_first_paragraph(body: str) -> str:
    for chunk in re.split(r"\n\s*\n", body):
        line = chunk.strip()
        if not line:
            continue
        if line.startswith("#"):
            continue
        return re.sub(r"\s+", " ", line).strip()
    return ""


def shorten(text: str, limit: int = 180) -> str:
    clean = re.sub(r"\s+", " ", text).strip()
    if len(clean) <= limit:
        return clean
    return clean[: limit - 3].rstrip() + "..."


def resolve_and_check(path: Path) -> Path:
    if not path.exists():
        raise FileNotFoundError(f"Missing referenced file: {path}")
    return path


def resolve_content_file(path: Path) -> Path:
    """Resolve path to an actual readable file.

    Some marketplace entries point to a directory (for skills). In that case,
    prefer `<dir>/SKILL.md`.
    """
    checked = resolve_and_check(path)
    if checked.is_dir():
        candidate = checked / "SKILL.md"
        if candidate.exists():
            return candidate
        raise FileNotFoundError(
            f"Referenced directory has no SKILL.md: {checked}"
        )
    return checked


def rel(path: Path, repo_root: Path) -> str:
    return str(path.relative_to(repo_root)).replace("\\", "/")


def load_catalog(repo_root: Path) -> dict:
    marketplace_path = repo_root / ".claude-plugin" / "marketplace.json"
    return json.loads(marketplace_path.read_text(encoding="utf-8"))


def build_registry(repo_root: Path, catalog: dict) -> dict:
    plugins_out = []
    all_skills = []
    all_agents = []

    for plugin in catalog.get("plugins", []):
        plugin_name = plugin.get("name", "plugin")
        source_dir = repo_root / plugin.get("source", "").replace("./", "")
        plugin_description = plugin.get("description", "").strip()
        plugin_category = plugin.get("category", "").strip()

        agents = []
        skills = []
        commands = []

        for agent_rel in plugin.get("agents", []):
            agent_path = resolve_content_file(source_dir / agent_rel.replace("./", ""))
            meta, body = parse_frontmatter(agent_path.read_text(encoding="utf-8"))
            agent = {
                "slug": to_slug(meta.get("name", agent_path.stem)),
                "name": meta.get("name", agent_path.stem),
                "description": meta.get("description", "").strip()
                or extract_first_paragraph(body)
                or f"{plugin_name} agent",
                "model": meta.get("model", "").strip(),
                "path": rel(agent_path, repo_root),
            }
            agents.append(agent)
            all_agents.append({**agent, "plugin": plugin_name})

        for skill_rel in plugin.get("skills", []):
            skill_path = resolve_content_file(source_dir / skill_rel.replace("./", ""))
            meta, body = parse_frontmatter(skill_path.read_text(encoding="utf-8"))
            skill = {
                "slug": to_slug(meta.get("name", skill_path.parent.name)),
                "name": meta.get("name", skill_path.parent.name),
                "description": meta.get("description", "").strip()
                or extract_first_paragraph(body)
                or f"{plugin_name} skill",
                "path": rel(skill_path, repo_root),
            }
            skills.append(skill)
            all_skills.append({**skill, "plugin": plugin_name})

        for command_rel in plugin.get("commands", []):
            command_path = resolve_content_file(
                source_dir / command_rel.replace("./", "")
            )
            meta, body = parse_frontmatter(command_path.read_text(encoding="utf-8"))
            command_title = ""
            for line in body.splitlines():
                line = line.strip()
                if line.startswith("# "):
                    command_title = line[2:].strip()
                    break
            command = {
                "slug": to_slug(command_path.stem),
                "name": command_title or command_path.stem,
                "description": extract_first_paragraph(body) or f"{plugin_name} command",
                "path": rel(command_path, repo_root),
            }
            if meta:
                command["frontmatter"] = meta
            commands.append(command)

        plugins_out.append(
            {
                "name": plugin_name,
                "description": plugin_description,
                "category": plugin_category,
                "version": plugin.get("version", ""),
                "source": plugin.get("source", ""),
                "agents": agents,
                "skills": skills,
                "commands": commands,
            }
        )

    registry = {
        "generated_at_utc": dt.datetime.now(dt.timezone.utc)
        .replace(microsecond=0)
        .isoformat(),
        "source": ".claude-plugin/marketplace.json",
        "marketplace_name": catalog.get("name", ""),
        "marketplace_version": catalog.get("metadata", {}).get("version", ""),
        "counts": {
            "plugins": len(plugins_out),
            "agents": len(all_agents),
            "skills": len(all_skills),
            "commands": sum(len(p["commands"]) for p in plugins_out),
        },
        "plugins": plugins_out,
    }
    return registry


def write_registry(repo_root: Path, registry: dict) -> None:
    codex_dir = repo_root / ".codex"
    codex_dir.mkdir(parents=True, exist_ok=True)
    out_path = codex_dir / "registry.json"
    out_path.write_text(json.dumps(registry, indent=2) + "\n", encoding="utf-8")


def write_skills_index(repo_root: Path, registry: dict) -> None:
    lines = [
        "# Codex Skills Index",
        "",
        f"Generated from `{registry['source']}`.",
        "",
        "| Plugin | Skill | Description | Path |",
        "|---|---|---|---|",
    ]
    for plugin in registry["plugins"]:
        for skill in plugin["skills"]:
            desc = skill["description"].replace("|", "\\|")
            lines.append(
                f"| `{plugin['name']}` | `{skill['slug']}` | {desc} | `{skill['path']}` |"
            )
    (repo_root / ".codex" / "skills-index.md").write_text(
        "\n".join(lines) + "\n",
        encoding="utf-8",
    )


def write_agents_index(repo_root: Path, registry: dict) -> None:
    lines = [
        "# Codex Agents Index",
        "",
        f"Generated from `{registry['source']}`.",
        "",
        "| Plugin | Agent | Model | Description | Path |",
        "|---|---|---|---|---|",
    ]
    for plugin in registry["plugins"]:
        for agent in plugin["agents"]:
            desc = agent["description"].replace("|", "\\|")
            model = agent.get("model", "").replace("|", "\\|")
            lines.append(
                f"| `{plugin['name']}` | `{agent['slug']}` | `{model}` | {desc} | `{agent['path']}` |"
            )
    (repo_root / ".codex" / "agents-index.md").write_text(
        "\n".join(lines) + "\n",
        encoding="utf-8",
    )


def build_agents_md(registry: dict, repo_name: str) -> str:
    lines = [
        f"# AGENTS.md instructions for {repo_name}",
        "",
        "<INSTRUCTIONS>",
        "Codex Base Agent System",
        "",
        "Scope: Repository root and all subfolders.",
        "",
        "Source of truth",
        "- Canonical plugin catalog: `.claude-plugin/marketplace.json`",
        "- Kilo adapter output: `.kilocodemodes` (generated)",
        "- Codex adapter outputs: `AGENTS.md`, `.codex/registry.json`, `.codex/*-index.md` (generated)",
        "",
        "Generation commands",
        "- Regenerate Kilo modes: `python scripts/generate_kilocodemodes.py`",
        "- Regenerate Codex assets: `python scripts/generate_codex_assets.py`",
        "",
        "Codex working rules",
        "- Prefer plugin assets under `plugins/*` as canonical content.",
        "- Use `.codex/registry.json` for discovery and `.codex/*-index.md` for quick lookup.",
        "- Keep adapters generated; do not hand-edit generated files.",
        "- For new work, update plugin sources first, then regenerate adapters.",
        "",
        "## Skills",
        "A skill is a set of local instructions stored in a `SKILL.md` file.",
        "### Available skills",
    ]

    for plugin in registry["plugins"]:
        for skill in plugin["skills"]:
            short_desc = shorten(skill["description"], 140)
            lines.append(
                f"- {skill['slug']}: {short_desc} "
                f"(plugin: `{plugin['name']}`, file: `{skill['path']}`)"
            )

    lines.extend(
        [
            "### How to use skills",
            "- Trigger when the user names a skill or the task clearly matches a skill description.",
            "- Open only the specific `SKILL.md` file needed for the current task.",
            "- Resolve relative references in the skill file relative to its folder first.",
            "- Prefer scripts/assets in a skill directory over rewriting large blocks manually.",
            "- Keep context lean by loading only files required for the current request.",
            "</INSTRUCTIONS>",
            "",
        ]
    )
    return "\n".join(lines)


def write_agents_md(repo_root: Path, registry: dict) -> None:
    agents_md = build_agents_md(registry, repo_root.name)
    (repo_root / "AGENTS.md").write_text(agents_md, encoding="utf-8")


def main() -> int:
    args = parse_args()
    repo_root = args.repo_root.resolve()
    catalog = load_catalog(repo_root)
    registry = build_registry(repo_root, catalog)

    write_registry(repo_root, registry)
    write_skills_index(repo_root, registry)
    write_agents_index(repo_root, registry)
    write_agents_md(repo_root, registry)

    print(
        "Wrote Codex assets:",
        f"plugins={registry['counts']['plugins']}",
        f"agents={registry['counts']['agents']}",
        f"skills={registry['counts']['skills']}",
        f"commands={registry['counts']['commands']}",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
