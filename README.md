# Welcome
 
This repo will hold scripts and tools for monitoring the status of equipment used by the FiberLab for data acquisition. It includes:

- **Daily Status Script**: A script that checks the status of the equipment and generates a daily status report saved as a `.txt` file with the date in the filename. Older reports are automatically archived in the `archive-daily-status` directory.
- **Status Reporting Script**: A script designed to send a summary of the equipment status every day. This script is intended to be run as a cron job from an always-on remote server, such as Sermeq. Future enhancements may include plots and more detailed information beyond terminal outputs.
- **Jupyter Notebooks for Project Tracking**: A section for Jupyter Notebook files to store notes, updates, and timelines for each project. This section can also include storage information and details from the status updates, as well as links to financial reporting from Workday BI tools.
- **Website Embedding**: A section for integrating the results from these scripts into the website.

The repository aims to provide a comprehensive solution for monitoring and reporting the status of FiberLab equipment as status correlates with the details of each project.

See the website for more information about the UW FiberLab: https://fiberlab.uw.edu

Check out our growing visualiztion suite for our publicly hosted data:https://dasway.ess.washington.edu/vizdas/map


## Script Usage

### Manually Running the Daily Status Script
To manually run the daily status script, execute the following command:
```bash
./equipment_status.sh
```

### Setting Up Auto Status Reporting Script
To set up the status reporting script to run daily, you can add a cron job on your remote server. For example:

```
0 0 * * * /path/to/your/repo/status_reporting.sh
```

This cron job will run the script every day at midnight.


## Journal
We maintain collaborative journals to document research and development questions, findings, project updates, and details leading to final reports. These journals serve as comprehensive records of ongoing FiberLab activities centered around a portfolio of current research projects. The documentation is evergrowing to act as a realtime, essential resource of documentation for team members and collaborators to use in the present and future analysis of projects.

### Overleaf
For formal reporting. You can access Overleaf [here](https://www.overleaf.com/).

### Jupyter
We use Jupyter Notebooks to store notes, updates, and timelines for each project. These notebooks can be accessed and edited via JupyterLab.

### How to Access JupyterLab
Install JupyterLab: If you don't have JupyterLab installed, you can install it using pip:
    pip install jupyterlab

Clone the Repository: Clone this repository to your local machine:
    git clone [this repository url]
    cd [this directory]

Launch JupyterLab: Start JupyterLab from the command line:
    jupyter lab

Open Notebooks: In the JupyterLab interface, navigate to the notebooks directory and open the desired Jupyter Notebook file.

### Direct Link to JupyterLab (if hosted)
If JupyterLab is hosted on a remote server, you can access it directly via the following link: 
    http://your-jupyterlab-url

Replace http://your-jupyterlab-url with the actual URL of your JupyterLab instance.


## Future Enhancements
Detailed Reports: Include plots and more detailed information in the status reports.
Website Integration: Embed the results from the scripts into the FiberLab website for real-time monitoring.
