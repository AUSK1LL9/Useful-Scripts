# **Useful Pythhon Scripts**

## **Learning Python Scripting**

Repetitive tasks that drain time and energy. That’s where Python shines — it’s versatile, easy to learn, and perfect for automating almost anything.

Over time, I’ve created and refined automation scripts to optimize my daily workflow, handle repetitive chores, and boost productivity.


## **Introduction**

In this MD file, I’ll share Python automation scripts I use every day. Whether you’re a developer or student these scripts can simplify your life in surprising ways. From managing files to scraping data, these scripts cover a broad range of use cases.


## **Installation**

To install Python, follow these steps:

1. Install your OS and Programming IDE
2. Install Python
3. Run Python

## **Lets get started - Pyton Scripts**

## *1. Email Organiser*
This script automatically sorts incoming emails into folders based on predefined rules. Using the imaplib and email libraries, it’s perfect for clearing cluttered inboxes.

**Features:**
- Organizes newsletters, work emails, and personal messages.
- Deletes spam or low-priority emails instantly.

		import imaplib
		import email

		mail = imaplib.IMAP4_SSL("imap.gmail.com")
		mail.login("your_email@gmail.com", "your_password")
		mail.select("inbox")
		status, messages = mail.search(None, 'FROM "newsletter@example.com"')

		for num in messages[0].split():
			mail.store(num, '+X-GM-LABELS', 'Newsletters')  # Labels email
			mail.store(num, '+FLAGS', '\\Deleted')  # Marks as deleted
		mail.expunge()
		mail.logout()

**why use it?**
This script declutters my inbox and ensures I never miss important work emails.

## *2. File Renamer*
A lifesaver when dealing with messy file names! This script renames files in bulk based on patterns or extensions using the os module.

**Features:**
- Adds prefixes, suffixes, or numbers to file names.
- Works on specific file types, like .jpg or .txt.

		import os

		directory = "C:/example_folder"
		for count, filename in enumerate(os.listdir(directory)):
			if filename.endswith(".jpg"):
				new_name = f"image_{count + 1}.jpg"
				os.rename(os.path.join(directory, filename), os.path.join(directory, new_name))

**why use it?**
Perfect for renaming photos, downloaded files, or reports in seconds.

## *3. Web Scraper*
Using libraries like BeautifulSoup and requests, this script extracts useful data from websites, such as product prices, articles, or news updates.

**Features:**
- Extracts product prices, headlines, or article content.
- Saves data into structured formats like CSV or JSON.

		import requests
		from bs4 import BeautifulSoup

		url = "https://example.com"
		response = requests.get(url)
		soup = BeautifulSoup(response.text, 'html.parser')

		headlines = [h2.text for h2 in soup.find_all('h2')]
		print(headlines)

**why use it?**
I use this script to track competitor pricing, gather market trends, or compile news summaries.

## **Contributing**

If you'd like to contribute to Project Title, here are some guidelines:

1. Fork the repository.
2. Create a new branch for your changes.
3. Make your changes.
4. Write tests to cover your changes.
5. Run the tests to ensure they pass.
6. Commit your changes.
7. Push your changes to your forked repository.
8. Submit a pull request.

## **License**

Project Title is released under the MIT License. See the **[LICENSE](https://www.blackbox.ai/share/LICENSE)** file for details.

## **Authors and Acknowledgment**

Project Title was created by **[Your Name](https://github.com/username)**.

Additional contributors include:

- **[Contributor Name](https://github.com/contributor-name)**
- **[Another Contributor](https://github.com/another-contributor)**

Thank you to all the contributors for their hard work and dedication to the project.

## **Code of Conduct**

Please note that this project is released with a Contributor Code of Conduct. By participating in this project, you agree to abide by its terms. See the **[CODE_OF_CONDUCT.md](https://www.blackbox.ai/share/CODE_OF_CONDUCT.md)** file for more information.

## **FAQ**

**Q:** What is Project Title?

**A:** Project Title is a project that does something useful.

**Q:** How do I install Project Title?

**A:** Follow the installation steps in the README file.

**Q:** How do I use Project Title?

**A:** Follow the usage steps in the README file.

**Q:** How do I contribute to Project Title?

**A:** Follow the contributing guidelines in the README file.

**Q:** What license is Project Title released under?

**A:** Project Title is released under the MIT License. See the **[LICENSE](https://www.blackbox.ai/share/LICENSE)** file for details.

## **Changelog**

- **0.1.0:** Initial release
- **0.1.1:** Fixed a bug in the build process
- **0.2.0:** Added a new feature
- **0.2.1:** Fixed a bug in the new feature

## **Contact**

If you have any questions or comments about Project Title, please contact **[Your Name](you@example.com)**.

## **Conclusion**

That's it! This is a basic template for a proper README file for a general project. You can customize it to fit your needs, but make sure to include all the necessary information. A good README file can help users understand and use your project, and it can also help attract contributors.
