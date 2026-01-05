#!/bin/bash

set -e

echo "Checking Go version consistency across files..."
echo ""

# Extract Go version from go.mod
GO_MOD_VERSION=$(grep '^go ' go.mod | awk '{print $2}')
echo "INFO: go.mod: $GO_MOD_VERSION"

# Extract Go version from Dockerfile (handle both golang:X.Y and golang:X.Y-alpine formats)
DOCKER_VERSION=$(grep 'FROM golang:' Dockerfile | head -n 1 | sed -E 's/.*golang:([0-9]+\.[0-9]+).*/\1/')
echo "INFO: Dockerfile: $DOCKER_VERSION"

# Compare versions
if [ "$GO_MOD_VERSION" != "$DOCKER_VERSION" ]; then
    echo ""
    echo "ERROR: Go version mismatch detected!"
    echo "  go.mod:     $GO_MOD_VERSION"
    echo "  Dockerfile: $DOCKER_VERSION"
    echo ""
    echo "Please ensure all Go versions are synchronized across files."
    exit 1
fi

echo ""
echo "SUCCESS: All Go versions are in sync ($GO_MOD_VERSION)"
