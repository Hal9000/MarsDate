# Historical 1.x review

The original 1.x accuracy review (`ai-notes.txt`) and its
print-only probe (`test/probe_marsdate.rb`) were removed from the
2.0 working tree because most of their statements described code
that no longer exists.

They remain available in Git history:

- commit `b82515b` / pull request #1: review notes
- pull request #1 follow-up: diagnostic probe
- `conversation.md`: review and design discussion

Current behavior is specified by `README.md`, tested by the
asserting Minitest files in `test/`, and explained by
`design-issues.md`.
