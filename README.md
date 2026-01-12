# Renovate Go Version Sync Demo

This repository demonstrates how to configure Renovate to keep Go versions synchronized across multiple files (`go.mod`, `Dockerfile`) using CI validation.

## Problem

When using Renovate to update Go versions, updates to `go.mod` (depName: "go") and `Dockerfile` (depName: "golang") are treated as separate dependencies. This can lead to version mismatches where:
- `go.mod` specifies Go 1.21
- `Dockerfile` uses `golang:1.22-alpine`

Renovate does not natively enforce that these versions must match.

## Solution

This demo implements a **CI-based validation approach**:

1. **Group Go updates** - Renovate groups both `go` and `golang` updates into a single PR
2. **Create PR immediately** - Renovate creates the PR as soon as updates are detected
3. **CI validation on PR** - GitHub Actions runs on the PR and validates that versions match
4. **Prevent merging** - If versions don't match, the CI check fails and prevents merging (via branch protection or manual review)

## Repository Structure

```
renovate-go-demo/
├── .github/
│   └── workflows/
│       └── check-go-versions.yml   # GitHub Actions workflow
├── scripts/
│   └── check_go_versions.sh        # Version validation script
├── Dockerfile                      # Uses golang:1.21-alpine
├── go.mod                         # Specifies go 1.21
├── main.go                        # Simple Go application
└── renovate.json                  # Renovate configuration
```

## Key Configuration

### renovate.json

```json
{
  "packageRules": [
    {
      "description": "Enable Go version updates in go.mod",
      "matchDatasources": ["golang-version"],
      "rangeStrategy": "bump"
    },
    {
      "description": "Group all Go-related updates together",
      "matchPackageNames": ["go", "golang"],
      "groupName": "Go"
    }
  ]
}
```

**Key settings:**
- `rangeStrategy: "bump"` - Enables automatic Go version updates in go.mod
- `matchPackageNames: ["go", "golang"]` - Groups both dependencies together
- `groupName: "Go"` - All Go-related updates are bundled into a single PR

### Version Check Script

The `scripts/check_go_versions.sh` script:
- Extracts Go version from `go.mod`
- Extracts Go version from `Dockerfile`
- Compares them and exits with error if they don't match

### GitHub Actions Workflow

The workflow runs on every push and pull request, executing the version check script.

## Testing

### Test the version check script locally

```bash
# Should succeed (versions are in sync)
./scripts/check_go_versions.sh

# Test mismatch detection
# Edit Dockerfile to use golang:1.22-alpine
sed -i 's/golang:1.21-alpine/golang:1.22-alpine/' Dockerfile

# Should fail with mismatch error
./scripts/check_go_versions.sh

# Restore
sed -i 's/golang:1.22-alpine/golang:1.21-alpine/' Dockerfile
```

## How It Works with Renovate

When a new Go version (e.g., 1.23) is released:

1. **Renovate detects updates** for both `go` in go.mod and `golang` Docker image
2. **Creates a single branch** (due to `groupName: "Go"`)
3. **Updates both files** in the branch
4. **Creates a PR immediately**
5. **CI runs automatically** on the PR
6. **If versions match:** ✅ CI passes - PR can be merged
7. **If versions don't match:** ❌ CI fails - PR cannot be merged (requires manual intervention or branch protection)

## References

- [How to update golang in multiple files - Discussion #28402](https://github.com/renovatebot/renovate/discussions/28402)
- [Renovate Configuration Options](https://docs.renovatebot.com/configuration-options/)
