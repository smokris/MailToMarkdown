# MailToMarkdown

An OS X Service that reformats a forwarded Mail message with Markdown-style '>' quotes

## To install

   - Download `MailToMarkdown.service` and move it to `~/Library/Services`
   - In System Preferences > Keyboard > Shortcuts > Services > Text, ensure "Convert Selection to Markdown" is checked
   - Quit and re-launch Mail.app
   - In Mail > Preferences > Composing:
      - set "Message Format" to "Plain Text"
      - uncheck "Use the same message format as the original message"
      - (MailToMarkdown doesn't yet support parsing rich text headers)

## To use

   - Select the message you'd like to reformat.
   - Message > Forward
   - Click on the message body and Select All
   - Mail > Services > Convert Selection to Markdown
   - Switch to your Markdown editor and paste
