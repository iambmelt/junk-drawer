Use the script by following these steps:

1. Open a text editor such as Notepad or Sublime Text.
2. Copy the script I provided into the text editor.
3. Replace the URL in the script with the URL you want to fetch content from. For example, `url="https://www.example.com"`.
4. Save the script with a `.sh` file extension, for example `fetch-html-images.sh`.
5. Open a terminal or command prompt, navigate to the directory where you saved the script, and run the following command to make the script executable:

   ```
   chmod +x fetch-html-images.sh
   ```

6. Run the script by typing its name and pressing Enter:

   ```
   ./fetch-html-images.sh
   ```

   The script will fetch the content from the specified URL, check if it contains HTML, and download any images it finds. You should see output in the terminal indicating whether the content contains HTML, and if any images were downloaded.

Note that you need to have the `curl` and `sed` commands installed on your system for the script to work.