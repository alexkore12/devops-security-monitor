#!/bin/bash
# Check GitHub Advisories - Standalone script

TOOL="${1:-trivy}"
OUTPUT="${2:-/tmp/advisories.json}"

echo "Checking advisories for: $TOOL"

curl -s "https://api.github.com/advisories?affects=$TOOL&per_page=10" | \
    jq -r '.[] | "\(.ghsa_id)\t\(.severity)\t\(.summary)"' | \
    while IFS=$'\t' read -r ghsa severity summary; do
        echo "$ghsa | $severity | ${summary:0:80}..."
    done

echo ""
echo "Full response saved to: $OUTPUT"
curl -s "https://api.github.com/advisories?affects=$TOOL&per_page=10" > "$OUTPUT"
