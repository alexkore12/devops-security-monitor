# DevOps Security Monitor - Architecture

## Overview

This project provides automated security monitoring for DevOps tools and workflows.

## Components

### 1. monitor.sh (Main Script)

Orchestrates all monitoring tasks:
- Dependency checking
- Advisory API queries
- Reddit trend analysis
- JSON report generation
- Notifications dispatch

### 2. scripts/check_advisories.sh

Standalone script to query GitHub Advisory Database.

**Usage:**
```bash
./scripts/check_advisories.sh trivy
./scripts/check_advisories.sh docker
```

### 3. k8s/cronjob.yaml

Kubernetes CronJob for automated daily execution.

## Data Flow

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│ GitHub Advisory │────▶│   monitor.sh     │────▶│  JSON Report    │
│    API          │     │                  │     │                 │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                                │
                                ▼
                        ┌──────────────────┐
                        │  Notifications   │
                        │ (Slack/Telegram) │
                        └──────────────────┘
```

## Storage

- **JSON Reports**: `/tmp/devops_security_report.json`
- **Logs**: `/tmp/devops_security.log`

## Security Considerations

1. **API Rate Limits**: GitHub API has rate limits. Use personal access token for higher limits.
2. **Secrets**: Never commit secrets. Use environment variables or Kubernetes secrets.
3. **Network**: All external calls use HTTPS.

## Extending

To add new tools:
1. Edit `TOOLS` array in `monitor.sh`
2. Add monitoring logic in `check_advisories()` function
