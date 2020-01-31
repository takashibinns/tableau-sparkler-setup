# Setting up Tableau Sparkler for Salesforce
Tableau provides a solution for embedding content into Salesforce, called [Sparkler](https://www.tableau.com/about/blog/2015/2/salesforce-canvas-connector-tableau-server-online-live-36973).  Sparkler is a web app, which lives on its own server, that sits between Salesforce and your Tableau Server.  Sparkler allows for single sign on using [Trusted Tickets](https://help.tableau.com/current/server/en-us/trusted_auth.htm), so that users logged into Salesforce are automatically logged into your Tableau Server.  It also makes it easier to embed tableau dashboards into various pages within Salesforce.  Tableau provides some documentation on how to get Sparkler setup, but it's a manual process.  This project aims to automate as much as possible, and make it easier to get started using Tableau, Sparkler, and Salesforce.

# Setup

## Step 1: Create the Connected App in Salesforce


## Step 2: Install the Sparkler web app on a server

### Option 1: Using your infrastructure for Sparkler
This option is applicable if your organization has its own servers (hyper-v, vmware, physical machines, etc) and you want to host the Sparkler web app.  In this case, you can use the setup.sh bash script to automate the installation and configuration of your sparkler server.

### Option 2: Using AWS to host Sparkler
This option is applicable if your organization leverages AWS as a hosting platform.  In this case, you can use the cloudformation template to spin up a new EC2 instance and automatically install/setup Sparkler.

## Step 3: Enable Trusted Ticket authentication on your Tableau Server.
Tableau provides instructions for how to setup trusted ticket authentication, which can be found [here](https://help.tableau.com/current/server/en-us/trusted_auth_trustIP.htm).  You'll just need the IP of your Sparkler server, in order to add it as a _trusted ip_ on your Tableau Server.  Once you've configured Tableau Server for Trusted Tickets from Sparkler, you should check Sparkler's status page at `https://<sparkler-server>/sparkler/status`
![Image of sparkler status page](/screenshots/sp-status.png)

# Notes
* This project is not meant to replace the official documentation on Sparkler
* For more details on the installation process and settings to tweak, please refer to the [sparkler documentation](https://www.tableau.com/sfdc-canvas-adapter)
