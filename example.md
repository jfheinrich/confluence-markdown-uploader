# Example Markdown File for Confluence Upload

This is a complete example file demonstrating all features supported by the `confluence-uploader.sh` script.

## How to Upload This File

### Prerequisites

1. Install required dependencies:
   ```bash
   brew install pandoc python3
   ```

2. For interactive parent selection, install fzf:
   ```bash
   brew install fzf
   ```

3. Create the configuration file `~/.confluence-upload.env`:
   ```bash
   cp src/.confluence-upload.env.example ~/.confluence-upload.env
   # Edit the file with your Confluence credentials
   ```

4. Install the Lua filters:
   ```bash
   mkdir -p ~/.local/share/confluence-update
   cp src/share/*.lua ~/.local/share/confluence-update/
   ```

### Basic Upload

Upload this file to the root of your Confluence space:

```bash
./src/confluence-uploader.sh -f example.md -t "Example Page"
```

### Upload with Parent Page

Upload as a subpage of an existing page (using parent page ID):

```bash
./src/confluence-uploader.sh -f example.md -t "Example Page" -a 123456789
```

Upload as a subpage using parent page title:

```bash
./src/confluence-uploader.sh -f example.md -t "Example Page" -p "Parent Page Title"
```

### Interactive Parent Selection

Use fzf to select the parent page interactively:

```bash
./src/confluence-uploader.sh -f example.md -t "Example Page" --pick-parent
```

### Upload with Images

Upload local images referenced in this markdown file as attachments:

```bash
./src/confluence-uploader.sh -f example.md -t "Example Page" --upload-images
```

## Markdown Features

### Text Formatting

This is **bold text** and this is *italic text*. You can also combine them: ***bold and italic***.

You can use ~~strikethrough~~ text and `inline code`.

### Headings

The document structure uses headings from h1 to h6.

#### Level 4 Heading
##### Level 5 Heading
###### Level 6 Heading

### Lists

Unordered list:

* First item
* Second item
  * Nested item 1
  * Nested item 2
* Third item

Ordered list:

1. First step
2. Second step
   1. Substep 2.1
   2. Substep 2.2
3. Third step

Task list:

- [x] Completed task
- [ ] Pending task
- [ ] Another pending task

### Links

External link: [Confluence Documentation](https://confluence.atlassian.com/)

Link with title: [Atlassian](https://www.atlassian.com/ "Atlassian Homepage")

### Blockquotes

> This is a blockquote.
> It can span multiple lines.
>
> And can have multiple paragraphs.

### Horizontal Rules

Use horizontal rules to separate sections:

---

### Tables

| Feature | Supported | Notes |
|---------|-----------|-------|
| Headings | ✓ | All levels h1-h6 |
| Lists | ✓ | Ordered and unordered |
| Code blocks | ✓ | With syntax highlighting |
| Images | ✓ | Local and external |
| Tables | ✓ | Full support |
| Panels | ✓ | Confluence-specific |

### Code Blocks

Code block with Python syntax highlighting:

```python
def hello_world():
    """A simple greeting function."""
    print("Hello, Confluence!")
    return True

if __name__ == "__main__":
    hello_world()
```

Code block with JavaScript:

```javascript
function greet(name) {
    console.log(`Hello, ${name}!`);
    return true;
}

greet("Confluence");
```

Code block with shell script:

```bash
#!/bin/bash
set -eu

echo "Uploading to Confluence..."
./confluence-uploader.sh -f example.md -t "My Page"
```

Code block without language specification:

```
This is a generic code block
without syntax highlighting.
```

### Line Breaks

This line ends with two spaces to create a hard line break.  
The next line starts here.

You can also use HTML break tags:<br>
This line comes after a break.

### Images

External image (from URL):

![Atlassian Logo](https://www.atlassian.com/dam/jcr:e33efd9e-e0b8-4d61-a24d-68a48ef99ed5/Atlassian-horizontal-blue-rgb.svg)

Local image (will be uploaded as attachment when using `--upload-images`):

![Local Image](images/diagram.png)

## Confluence-Specific Features

### Panels

Confluence panels are created using fenced divs with specific classes.

::: {.info title="Information Panel"}
This is an information panel. Use it to highlight important information for readers.

You can include **formatted text**, `code`, and other markdown elements inside panels.
:::

::: {.warning title="Warning"}
This is a warning panel. Use it to alert readers about potential issues or important caveats.
:::

::: {.success title="Success"}
This is a success panel. Use it to highlight successful outcomes or best practices.
:::

::: {.tip title="Pro Tip"}
This is a tip panel. Use it to share helpful hints and recommendations.
:::

::: {.note title="Note"}
This is a note panel. Use it for additional context or related information.
:::

Alternative syntax using the panel class with type attribute:

::: {.panel type="info" title="Alternative Syntax"}
You can also use `.panel` class with a `type` attribute.
:::

## Advanced Examples

### Nested Lists with Code

1. First, install the dependencies:
   ```bash
   brew install pandoc python3
   ```

2. Create the configuration file:
   * Copy the example file
   * Edit the credentials
   * Save to `~/.confluence-upload.env`

3. Run the upload:
   ```bash
   ./src/confluence-uploader.sh -f example.md -t "My Page"
   ```

### Code in Tables

| Language | Example Code | Description |
|----------|--------------|-------------|
| Python | `print("Hello")` | Print statement |
| JavaScript | `console.log("Hello")` | Console output |
| Bash | `echo "Hello"` | Echo command |

### Combination of Features

::: {.info title="Complete Example"}
Here's how to upload this file with all options:

```bash
./src/confluence-uploader.sh \
  -f example.md \
  -t "Complete Example Page" \
  -p "Documentation" \
  --upload-images
```

This command will:
* Convert the markdown to Confluence storage format
* Create or update the page titled "Complete Example Page"
* Place it under the parent page "Documentation"
* Upload all local images as attachments

**Note:** Make sure your `~/.confluence-upload.env` file is properly configured!
:::

## Environment Configuration

The script uses environment variables from `~/.confluence-upload.env`:

```bash
# Required
CONF_LANG="${LANG:-}"
CONF_BASE_URL="https://<your workspace>.atlassian.net/wiki"
CONF_EMAIL="username@example.com"
CONF_API_TOKEN="<your api token>"
CONF_SPACE_KEY="~<your space id>"

# Optional
CONF_PARENT_PAGE_ID=""
CONF_RETRY=3
CONF_TIMEOUT=30
```

### Language Support

The script supports both English and German messages. Set the language using:

```bash
export CONF_LANG=en  # English (default)
# or
export CONF_LANG=de  # German
```

## Tips and Best Practices

1. **Test with a test space first** before uploading to production
2. **Use version control** to track changes to your markdown files
3. **Validate your markdown** before uploading using a markdown linter
4. **Use meaningful page titles** that are easy to find in Confluence
5. **Organize with parent pages** to create a clear documentation structure
6. **Upload images** using the `--upload-images` flag for local images
7. **Use panels** to highlight important information

## Troubleshooting

### Common Issues

::: {.warning title="Authentication Errors"}
If you get authentication errors:
* Verify your email address in `CONF_EMAIL`
* Ensure your API token is valid and not expired
* Check that `CONF_BASE_URL` points to the correct Confluence instance
:::

::: {.tip title="Missing Dependencies"}
If you see "command not found" errors:
* Install pandoc: `brew install pandoc`
* Install python3: `brew install python3`
* Install fzf (optional): `brew install fzf`
:::

::: {.note title="Page Already Exists"}
The script automatically updates existing pages. If a page with the same title exists, it will be updated with the new content while preserving the page ID.
:::

## Conclusion

This example demonstrates all features supported by the confluence-uploader.sh script. You can use this file as a template for your own Confluence documentation.

For more information, visit the project repository or consult the README.md file.
