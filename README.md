# Welcome
 
This repo will hold scripts and tools for monitoring the status of equipment used by the FiberLab for data acquisition. It includes:

- **Daily Status Script**: A script that checks the status of the equipment and generates a daily status report saved as a `.txt` file with the date in the filename. Older reports are automatically archived in the `archive-daily-status` directory.
- **Status Reporting Script**: A script designed to send a summary of the equipment status every day. This script is intended to be run as a cron job from an always-on remote server, such as Sermeq. Future enhancements may include plots and more detailed information beyond terminal outputs.
- **Jupyter Notebooks for Project Tracking**: A section for Jupyter Notebook files to store notes, updates, and timelines for each project. This section can also include storage information and details from the status updates, as well as links to financial reporting from Workday BI tools.
- **Website Embedding**: A section for integrating the results from these scripts into the website.

The repository aims to provide a comprehensive solution for monitoring and reporting the status of FiberLab equipment as status correlates with the details of each projects.