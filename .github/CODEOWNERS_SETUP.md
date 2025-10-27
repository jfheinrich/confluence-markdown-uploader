# CODEOWNERS Setup Guide

This guide explains how to set up the code owners for this repository to ensure that code owner reviews are properly recognized by GitHub's branch protection rules.

## Why Use a Team for Code Owners?

For organization-owned repositories like `jfheinrich-eu/confluence-markdown-uploader`, GitHub recommends using **team references** in the CODEOWNERS file rather than individual users. This approach:

- Ensures code owner reviews are properly recognized by branch protection rules
- Makes it easier to manage multiple maintainers
- Provides better integration with GitHub's permissions system
- Allows for more flexible team management without updating the CODEOWNERS file

## Current Configuration

The CODEOWNERS file currently references: `@jfheinrich-eu/maintainers`

## Setup Steps

### 1. Create the Maintainers Team

1. Navigate to your organization teams page:
   ```
   https://github.com/orgs/jfheinrich-eu/teams
   ```

2. Click the **New team** button

3. Configure the team:
   - **Team name**: `maintainers`
   - **Description**: `Repository maintainers with code owner responsibilities`
   - **Team visibility**: **Visible** (recommended) or **Secret**
     - *Visible*: Anyone in the organization can see this team and its members
     - *Secret*: Only team members and organization owners can see this team

4. Click **Create team**

### 2. Add Team Members

1. On the team page, click the **Members** tab

2. Click **Add a member**

3. Search for and add the following users:
   - `@jfheinrich` (primary maintainer)
   - Add any other users who should have code owner permissions

4. Assign appropriate team roles:
   - **Maintainer**: Can add/remove team members and manage team settings
   - **Member**: Regular team member with team permissions

### 3. Grant Repository Access

1. On the team page, click the **Repositories** tab

2. Click **Add repository**

3. Search for `confluence-markdown-uploader`

4. Select the repository and choose the access level:
   - **Write**: Recommended minimum for code owners
   - **Maintain**: For users who need additional repository management permissions
   - **Admin**: For users who need full repository administration

5. Click **Add repository to team**

### 4. Verify the Setup

1. Create a test pull request or use an existing one

2. Check that:
   - The team `@jfheinrich-eu/maintainers` is automatically requested as a reviewer
   - When a team member approves the PR, it counts as a code owner review
   - The branch protection rules recognize the approval

## Alternative: Using Individual Users

If you prefer not to use a team, you can configure individual users as code owners. However, ensure:

1. The user has **direct collaborator access** (not just organization membership)
2. The user has **Write** or higher permissions on the repository
3. Update the CODEOWNERS file to reference individual users:
   ```
   * @jfheinrich
   ```

To add a user as a direct collaborator:

1. Go to repository Settings → Collaborators and teams
2. Click **Add people**
3. Search for the user (e.g., `@jfheinrich`)
4. Select the appropriate role (Write, Maintain, or Admin)
5. Send the invitation

## Troubleshooting

### Code owner reviews not being recognized

**Problem**: A team member approves a PR, but it doesn't count as a code owner review.

**Solutions**:
- Verify the team has Write or higher access to the repository
- Ensure the CODEOWNERS file is in the correct location (`.github/CODEOWNERS`)
- Check that the team name matches exactly (case-sensitive)
- Confirm branch protection rules are properly configured with "Require review from Code Owners" enabled
- Make sure the reviewing user is actually a member of the team

### Team not appearing in reviewer requests

**Problem**: The team is not automatically requested as a reviewer on new PRs.

**Solutions**:
- Verify the CODEOWNERS file syntax is correct
- Ensure the CODEOWNERS file is committed to the default branch (usually `main`)
- Check that the file patterns match the changed files in the PR
- Confirm the team name is spelled correctly: `@jfheinrich-eu/maintainers`

### Cannot create team

**Problem**: You don't see the option to create a team.

**Solutions**:
- Verify you have owner or admin permissions in the `jfheinrich-eu` organization
- If you're not an organization owner, ask an owner to create the team or grant you appropriate permissions

## Additional Resources

- [GitHub Documentation: About code owners](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
- [GitHub Documentation: Managing teams](https://docs.github.com/en/organizations/organizing-members-into-teams/about-teams)
- [GitHub Documentation: Branch protection rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)

## Questions?

If you encounter any issues with the CODEOWNERS setup, please:
1. Check this guide's troubleshooting section
2. Review the GitHub documentation linked above
3. Open an issue in this repository with details about the problem
