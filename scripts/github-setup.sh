#!/bin/bash
# Run this to push the repo and create kanban issues on GitHub
# Make sure you have `gh` authenticated: gh auth login

set -e

REPO="jerrygooch/trash-panda-tycoon"
DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Creating GitHub repository..."
gh repo create "$REPO" --public --description "Trash Panda Tycoon - a raccoon trash sorting idle game" --source "$DIR" --push || {
  echo "Create the repo manually at: https://github.com/new"
  echo "Name: trash-panda-tycoon"
  echo "Then run: git remote add origin https://github.com/$REPO && git push -u origin main"
  exit 1
}

echo "==> Setting default remote..."
gh repo set-default "$REPO"

echo "==> Creating kanban board..."
# Create GitHub project (modern Projects V2)
PROJECT_ID=$(gh api graphql -f query='
  mutation {
    createProjectV2(input: { ownerId: "U_kgDOBf0BxA", title: "Trash Panda Tycoon" }) {
      projectV2 { id }
    }
  }
' --jq '.data.createProjectV2.projectV2.id')

echo "Project created. Now create issues manually from docs/GITHUB_KANBAN.md"
echo "Done!"
