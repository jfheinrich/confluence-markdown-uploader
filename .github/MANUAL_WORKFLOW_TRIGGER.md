# Manual Workflow Trigger Instructions

This document explains how to manually trigger GitHub Actions workflows for any branch, including pull request branches.

## Background

The Shell Script Validation and POSIX Compliance Check workflows are configured to run automatically when:
- Shell script files (`.sh`) are modified
- Workflow configuration files are changed

However, they can also be triggered manually using the `workflow_dispatch` event, which is useful for:
- Running tests on documentation-only changes
- Re-running tests without making code changes
- Testing specific branches

## How to Manually Trigger Workflows

### Via GitHub Web Interface

1. Navigate to the repository on GitHub: `https://github.com/jfheinrich/confluence-markdown-uploader`
2. Click on the "Actions" tab
3. Select the workflow you want to run from the left sidebar:
   - "Shell Script Validation"
   - "POSIX Compliance Check"
4. Click the "Run workflow" button (appears on the right side)
5. Select the branch you want to run the workflow on (e.g., `feature/example-markdown` for PR #2)
6. Click the green "Run workflow" button to start the workflow

### Via GitHub CLI

If you have the GitHub CLI (`gh`) installed, you can trigger workflows from the command line:

```bash
# Trigger Shell Script Validation on a specific branch
gh workflow run "Shell Script Validation" --ref feature/example-markdown

# Trigger POSIX Compliance Check on a specific branch
gh workflow run "POSIX Compliance Check" --ref feature/example-markdown
```

## Running Tests for Pull Request #2

To run all tests on Pull Request #2 (Feature/example-markdown):

1. Go to Actions tab
2. Select "Shell Script Validation"
3. Click "Run workflow"
4. Select branch: `feature/example-markdown`
5. Click "Run workflow"
6. Repeat steps 2-5 for "POSIX Compliance Check"

## Viewing Workflow Results

After triggering the workflows:
1. Return to the "Actions" tab
2. You will see the workflow runs in progress
3. Click on a workflow run to see detailed logs
4. The status will appear on the pull request page once complete

## Notes

- Manual workflow triggers respect the same permissions and security settings as automatic triggers
- Workflow runs triggered manually will appear in the Actions history
- The workflow results will be associated with the selected branch/commit
