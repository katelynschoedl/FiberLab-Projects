#!/usr/bin/env python3

import subprocess
from server_config import servers, passwords

# Path to write status reports
outdir = '/mnt/raid1/daily_status'


def gather_info(server, details):
    info = f"Server: {server}\n"
    password = passwords[server]  # Retrieve the password for the current server
    for command in details['commands']:
        result = subprocess.run(
            ['sshpass', '-p', password, 'ssh', '-p', str(details.get('port', 22)), f"{details['address']}", command],
            capture_output=True, text=True
        )
        info += f"Command: {command}\n{result.stdout}\n"
    return info

def generate_report(outdir, servers):
    report = ""
    for server, details in servers.items():
        report += gather_info(server, details)
        report += "\n" + "#" * 50 + "\n"
    
    report_path = f"{outdir}/status_report.txt"
    with open(report_path, 'w') as file:
        file.write(report)
    print(f"Report generated at {report_path}")

# Generate report
generate_report(outdir, servers)