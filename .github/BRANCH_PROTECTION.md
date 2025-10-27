# Branch Protection Setup

This document describes the branch protection configuration for the `main` branch following GitHub best practices.

## Automated Configuration with Probot Settings

The repository includes a `.github/settings.yml` file that can automatically configure branch protection rules using the [Probot Settings app](https://probot.github.io/apps/settings/).

### To enable automated configuration:

1. Install the [Settings app](https://github.com/apps/settings) on your repository
2. The app will automatically apply the rules defined in `.github/settings.yml`
3. Any changes to `.github/settings.yml` will be automatically applied when merged to main

## Manual Configuration

If you prefer to configure branch protection manually or the Probot Settings app is not available, follow these steps:

### Steps to Configure Branch Protection:

1. Navigate to your repository on GitHub
2. Click on **Settings** tab
3. In the left sidebar, click on **Branches**
4. Under "Branch protection rules", click **Add rule** or edit the existing rule for `main`
5. Apply the following settings:

### Recommended Branch Protection Settings:

#### Branch name pattern
```
main
```

#### Protect matching branches

**Require a pull request before merging**
- ✅ Required approvals: **1**
- ✅ Dismiss stale pull request approvals when new commits are pushed
- ✅ Require review from Code Owners (CODEOWNERS file is configured)
- ❌ Restrict who can dismiss pull request reviews (optional, based on team structure)
- ❌ Allow specified actors to bypass required pull requests (not recommended for production)
- ✅ Require approval of the most recent reviewable push

**Require status checks to pass before merging**
- ✅ Require branches to be up to date before merging
- ✅ Status checks that are required:
  - `ShellCheck Analysis` - Shell script validation
  - `POSIX Shell Compliance` - POSIX compliance verification

**Require conversation resolution before merging**
- ✅ All conversations on code must be resolved

**Require signed commits** (optional but recommended)
- ⚪ Require commits to be signed (recommended for security)

**Require linear history**
- ✅ Prevent merge commits (requires rebase or squash merging)

**Require deployments to succeed before merging** (if applicable)
- ⚪ Not required for this repository

**Lock branch**
- ❌ Do not lock branch (prevents all pushes)

**Do not allow bypassing the above settings**
- ✅ Apply rules to administrators

**Restrict who can push to matching branches** (optional)
- ⚪ Can be configured based on team structure

**Allow force pushes**
- ❌ Do not allow force pushes

**Allow deletions**
- ❌ Do not allow deletion of the branch

## CI/CD Workflows

The repository includes the following GitHub Actions workflows that serve as required status checks:

### 1. ShellCheck Analysis (`.github/workflows/shellcheck.yml`)
- Runs ShellCheck static analysis on all shell scripts
- Validates code quality and identifies potential issues
- Ensures POSIX compatibility

### 2. POSIX Compliance Check (`.github/workflows/posix-compliance.yml`)
- Tests scripts with dash (POSIX-compliant shell)
- Validates syntax compatibility
- Checks for common POSIX violations

## Code Review Requirements

The repository uses a `CODEOWNERS` file (`.github/CODEOWNERS`) that defines:
- `@jfheinrich` as the default owner for all files
- Automatic review requests for all pull requests

## Best Practices Applied

This branch protection configuration follows GitHub's best practices:

1. **Prevent Direct Pushes**: All changes must go through pull requests
2. **Require Reviews**: At least one approval required from code owners
3. **Automated Testing**: CI checks must pass before merging
4. **Up-to-date Branches**: Branches must be current with main before merging
5. **Conversation Resolution**: All review comments must be addressed
6. **Linear History**: Cleaner git history through rebase/squash
7. **No Force Pushes**: Prevents accidental history rewriting
8. **Administrator Enforcement**: Even admins must follow the rules
9. **Branch Protection**: Cannot delete the protected branch

## Verification

After setting up branch protection, you can verify it's working by:

1. Attempting to push directly to main (should fail)
2. Creating a pull request without approval (should block merge)
3. Creating a pull request with failing CI checks (should block merge)
4. Creating a pull request from an outdated branch (should require update)

## Troubleshooting

### Status checks not appearing
- Ensure workflows have run at least once on the main branch
- Check that workflow names match exactly in `.github/settings.yml`
- Verify workflows are enabled in repository settings

### Unable to merge despite passing checks
- Ensure all conversations are resolved
- Verify branch is up to date with main
- Check that required approvals are obtained

### Settings app not applying changes
- Verify the Settings app is installed and has proper permissions
- Check the app's logs for any errors
- Ensure `.github/settings.yml` syntax is valid YAML

## References

- [GitHub Branch Protection Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [Probot Settings App](https://probot.github.io/apps/settings/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [CODEOWNERS Documentation](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
