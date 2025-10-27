# Confluence Upload Script Example

## Introduction
This example markdown file demonstrates the capabilities of the `confluence-upload-posix.sh` script. The script is designed to upload Markdown files to Confluence, handling various options and features.

## Features Highlighted
- **Language Detection**: Supports both English and German.
- **Error Handling**: Provides detailed error messages.
- **Command-line Parsing**: Allows specifying file path, page title, parent page, etc.
- **Authentication**: Uses Confluence API tokens for authentication.
- **API Interactions**: Handles creating or updating pages and uploading attachments.

## Usage
To use the script, follow these steps:

1. **Prepare Your Markdown File**:
   - Ensure your Markdown file (`example.md`) is ready to be uploaded.

2. **Run the Script**:
   ```sh
   ./confluence-upload-posix.sh -f example.md -t "Example Page" -a 1234567890 -s SPACE_KEY --upload-images
   ```

   This command will upload `example.md` to a page titled "Example Page", with parent page ID `1234567890`, in the space `SPACE_KEY`, and upload any local images referenced in the Markdown file.

## Example Content
Here is a sample content you might include in your Markdown file:
