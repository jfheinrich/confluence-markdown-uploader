# Confluence Markdown Uploader

<img src="src/docs/image.png" alt="Confluence Markdown Uploader" width="200" height="200" />

A POSIX-compliant shell script to upload Markdown files as Confluence pages with support for image attachments, interactive parent page selection, and internationalization (English/German).

## Features

- 🚀 Convert and upload Markdown files directly to Confluence
- 🖼️ Automatic image attachment upload
- 🌍 Internationalization support (English/German)
- 🎯 Interactive parent page selection with fzf
- 🔄 Smart page updates (creates or updates existing pages)
- 🛡️ Robust error handling with retry logic
- 📦 Minimal dependencies (curl, pandoc, python3)

## Prerequisites

The following tools are required:

- **curl** - For API calls to Confluence
- **pandoc** - For Markdown to Confluence conversion
- **python3** - For HTML/Storage format processing

Optional:

- **fzf** - For interactive parent page selection

### Installation

#### macOS

```bash
brew install pandoc python3
brew install fzf  # Optional, for interactive parent selection
```

#### Linux (Debian/Ubuntu)

```bash
sudo apt-get update
sudo apt-get install curl pandoc python3
sudo apt-get install fzf  # Optional
```

## Setup

1. **Clone the repository**:

   ```bash
   git clone https://github.com/jfheinrich-eu/confluence-markdown-uploader.git
   cd confluence-markdown-uploader
   ```

2. **Install Lua filters** (required for proper Markdown conversion):

   ```bash
   mkdir -p ~/.local/share/confluence-uploader
   cp src/share/*.lua ~/.local/share/confluence-uploader/
   ```

3. **Create configuration file**:

   ```bash
   cp src/.confluence-upload.env.example ~/.confluence-upload.env
   ```

4. **Edit the configuration file** with your Confluence credentials:

   ```bash
   # Required settings
   CONF_BASE_URL="https://<your-workspace>.atlassian.net/wiki"
   CONF_EMAIL="your-email@example.com"
   CONF_API_TOKEN="<your-api-token>"
   CONF_SPACE_KEY="<your-space-key>"
   
   # Optional settings
   CONF_PARENT_PAGE_ID=""
   CONF_RETRY=3
   CONF_TIMEOUT=30
   CONF_LANG="${LANG:-}"  # Auto-detect from system, or set to 'en' or 'de'
   ```

   To generate an API token, visit: https://id.atlassian.com/manage-profile/security/api-tokens

## Usage

### Basic Usage

Upload a Markdown file to the root of your Confluence space:

```bash
./src/confluence-uploader.sh -f path/to/file.md -t "Page Title"
```

### Upload as Subpage

Upload as a subpage using parent page ID:

```bash
./src/confluence-uploader.sh -f path/to/file.md -t "Page Title" -a 123456789
```

Upload as a subpage using parent page title:

```bash
./src/confluence-uploader.sh -f path/to/file.md -t "Page Title" -p "Parent Page Title"
```

### Interactive Parent Selection

Use fzf to interactively select a parent page:

```bash
./src/confluence-uploader.sh -f path/to/file.md -t "Page Title" --pick-parent
```

### Upload with Images

Automatically upload local images referenced in the Markdown file:

```bash
./src/confluence-uploader.sh -f path/to/file.md -t "Page Title" --upload-images
```

### Custom Space

Upload to a specific Confluence space:

```bash
./src/confluence-uploader.sh -f path/to/file.md -t "Page Title" -s SPACEKEY
```

### Command Options

```
Options:
  -f  Path to Markdown file (required)
  -t  Confluence page title (required)
  -a  Parent page ID (ancestor). Omit for space root
  -p  Parent page title (resolved within space)
  --pick-parent    Pick parent interactively (requires fzf)
  -s  Space key (default from ENV)
  --upload-images  Upload local images referenced in Markdown as attachments
```

## Examples

### Example 1: Simple Upload

```bash
./src/confluence-uploader.sh -f README.md -t "Project Documentation"
```

### Example 2: Documentation Hierarchy

Upload multiple pages in a hierarchy:

```bash
# Upload parent page
./src/confluence-uploader.sh -f docs/overview.md -t "API Documentation"

# Upload child pages (assuming parent page ID is 123456789)
./src/confluence-uploader.sh -f docs/authentication.md -t "Authentication" -a 123456789
./src/confluence-uploader.sh -f docs/endpoints.md -t "API Endpoints" -a 123456789
```

### Example 3: Complete Example with Images

```bash
./src/confluence-uploader.sh \
  -f src/docs/example.md \
  -t "Complete Example" \
  -p "Documentation" \
  --upload-images
```

See [src/docs/example.md](src/docs/example.md) for a comprehensive example file demonstrating all supported Markdown features.

## Supported Markdown Features

The uploader supports standard Markdown syntax and converts it appropriately for Confluence:

- **Headings** (H1-H6)
- **Bold**, *Italic*, and ~~Strikethrough~~ text
- **Lists** (ordered and unordered)
- **Code blocks** with syntax highlighting
- **Tables**
- **Links** and **Images**
- **Blockquotes**
- **Horizontal rules**
- **Info/Warning/Error panels** (using custom Lua filters)

## Development

### Project Structure

```
confluence-markdown-uploader/
├── src/
│   ├── confluence-uploader.sh      # Main uploader script
│   ├── .confluence-upload.env.example  # Configuration template
│   ├── docs/
│   │   ├── example.md              # Example Markdown file
│   │   └── image.png               # Project logo
│   └── share/
│       ├── br2jira.lua             # Lua filter for line breaks
│       ├── code_language.lua       # Lua filter for code blocks
│       └── panel.lua               # Lua filter for panels
├── .github/
│   └── workflows/
│       ├── shellcheck.yml          # ShellCheck linting
│       └── posix-compliance.yml    # POSIX compliance checks
└── README.md
```

### Running Tests

The project uses GitHub Actions for automated testing:

- **ShellCheck**: Validates shell script quality and best practices
- **POSIX Compliance**: Ensures script compatibility across different shells

To run ShellCheck locally:

```bash
shellcheck src/confluence-uploader.sh
```

### Code Style

The project follows these guidelines:

- POSIX-compliant shell scripting (no bashisms)
- `set -eu` for strict error handling
- Internationalization (i18n) support for English and German
- Clear function names and documentation
- Proper error messages and logging

### Language Support

The script supports multiple languages for user-facing messages:

- English (en): Default
- German (de): Activated when `CONF_LANG=de` or system `LANG` contains `de`

To add a new language, extend the `msg()` function in the script with new translation keys.

## Contributing

This repository uses branch protection for the `main` branch to ensure code quality and security. All contributions must:

- Be submitted via pull requests
- Pass automated CI checks (ShellCheck and POSIX compliance)
- Receive approval from code owners
- Have all conversations resolved

For more details, see [Branch Protection Setup](.github/BRANCH_PROTECTION.md).

### Contribution Guidelines

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following the code style guidelines
4. Test your changes thoroughly
5. Commit your changes (`git commit -m 'feat: add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

## Troubleshooting

### Common Issues

**Problem**: `pandoc not found`
```bash
brew install pandoc  # macOS
sudo apt-get install pandoc  # Linux
```

**Problem**: `python3 not found`
```bash
brew install python3  # macOS
sudo apt-get install python3  # Linux
```

**Problem**: `fzf not found` (when using --pick-parent)
```bash
brew install fzf  # macOS
sudo apt-get install fzf  # Linux
```

**Problem**: Page update fails with authentication error
- Verify your API token is correct
- Ensure your email matches your Confluence account
- Check that the base URL is correct (should end with `/wiki`)

**Problem**: Images not uploading
- Use the `--upload-images` flag
- Ensure image paths in Markdown are relative to the Markdown file
- Check that images exist and are readable

## Support

For issues, questions, or contributions, please:
- Open an issue on [GitHub Issues](https://github.com/jfheinrich-eu/confluence-markdown-uploader/issues)
- Submit a pull request for improvements

### Code Owners Setup

This repository uses GitHub's CODEOWNERS feature to automatically request reviews from maintainers. For organization-owned repositories, we use a team-based approach to ensure reviews are properly recognized.

If you're setting up this repository or managing code owners, see the [CODEOWNERS Setup Guide](.github/CODEOWNERS_SETUP.md) for detailed instructions.

For more details on branch protection, see [Branch Protection Setup](.github/BRANCH_PROTECTION.md).
