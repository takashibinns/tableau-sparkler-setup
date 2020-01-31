# Setting up Tableau Sparkler for Salesforce
Tableau provides a solution for embedding content into Salesforce, called [Sparkler](https://www.tableau.com/about/blog/2015/2/salesforce-canvas-connector-tableau-server-online-live-36973).  Sparkler is a web app, which lives on its own server, that sits between Salesforce and your Tableau Server.  Sparkler allows for single sign on using [Trusted Tickets](https://help.tableau.com/current/server/en-us/trusted_auth.htm), so that users logged into Salesforce are automatically logged into your Tableau Server.  It also makes it easier to embed tableau dashboards into various pages within Salesforce.  Tableau provides some documentation on how to get Sparkler setup, but it's a manual process.  This project aims to automate as much as possible, and make it easier to get started using Tableau, Sparkler, and Salesforce.

# Setup

## Before you start
You'll need to have the following, in order to complete the setup
1. A __Salesforce System Administrator__ login, in order to add Sparkler as a connected app in Salesforce
2. Access to TSM on your Tableau Server, as well as being able to perform a server restart
3. Either an AWS account with permission to spin up new instances, or a linux server with a SSL certificate (not self-signed)

## Step 1: Create the Connected App in Salesforce
The first thing to do, is create a _connected app_ in Salesforce.  Login to Salesforce and goto the __Setup__ app, using the dropdown menu at the top right of the screen.
![Image of setup menu](/screenshots/sf-setup-1.png)

Using the left navigation search bar, navigate to the __App Manager__ page and click on the __New Connected App__ button.
![Image of app manager](/screenshots/sf-setup-2.png)

On the next page, you'll need to add a few details about this new connected app.  Fill in the Connected App name, API name, and contact email with whatever values you like.  Just know that whatever app name you choose, will be needed when embedding later on.  The other important sections are for API and Canvas App Settings.

For the API section, you need to add a __callback URL__ witch will follow this format: `https://<your-sparkler-server>/sparkler/keepAlive`.  You will also need to add __Access your basic information(id, profile, email, address, phone)__ to the list of __Selected OAuth Scopes__.
![Image of new app wizard 1](/screenshots/sf-connected-app-1.png)

For the Canvas App Settings, you should make sure the __Canvas__ option is checked, and the __Access Method__ is set to __Signed Request(POST)__.  The __Canvas App URL__ should match the following format: `https://<your-sparkler-server>/sparkler/sfdc/canvas`.  Lastly, make sure __Chatter Feed, Publisher, Visualforce Page__ are in the __Selected__ list of __Locations__.  Once these settings are entered, you can click save.
![Image of new app wizard 2](/screenshots/sf-connected-app-2.png)

Next, we need to add some permission profiles to our connected app.  Use the search navigation to goto the __Connected Apps__ page and click the edit button next to your sparkler app.  Change the __Permitted Users__ setting to __Admin approved users are pre-authorized__ and click save.  
![Image of edit app settings 1](/screenshots/sf-connected-app-3.png)

This should refresh the page, and you'll be back to the list of all apps.  Click on the name of your sparkler app (blue link), and you should now be able to click on __Manage Profiles__.  Add at least one profile, like __System Administrator__.
![Image of edit app settings 2](/screenshots/sf-connected-app-4.png)

At this point, everything is setup and you just need to get the consumer secret of your app.  Use the search navigation to get back to the __App Manager__ page and click on your Sparkler app to view the details.  Click on the button to show you the consumer secret and make sure to copy this string of text, as you will need this for setting up sparkler.
![Image of edit app settings 3](/screenshots/sf-connected-app-5.png)

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
