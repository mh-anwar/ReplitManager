# Replit Project Downloader
This repository contains scripts to download, sort, organize, clean and commit my Java projects from Replit. The downloading script is written in JavaScript and uses Selenium to download all the projects. The sorting script is written in bash and utilizes git to add and commit all my projects to github.

## Steps to Use

# 1. `npm run download`
This will execute a Node.js script that will download all of your projects from Replit. It uses Selenium to automate the process of downloading the projects. 
- Your team name comes from the URL of your Replit team. For example, if your team URL is `https://replit.com/team/your-team-name`, then your team name is `your-team-name`.

# 2. `bash projectSorter.sh`
This bash script will organize, extract and clean all the projects. It will then add and commit them to the repository.
- All `.class`, `.project` and error log files are removed. Any previous `.git` directories are also removed.
- At the end, some files may not have been able to sucessfully have been added to the repository. These files should be manually added.

# 3. Push to Remote
You must add a remote origin to the push the changes to and actually push the changes.