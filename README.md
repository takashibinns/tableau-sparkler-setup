# Setting up Tableau Sparkler for Salesforce
Tableau provides a solution for embedding content into Salesforce, called [Sparkler](https://www.tableau.com/about/blog/2015/2/salesforce-canvas-connector-tableau-server-online-live-36973).  Sparkler is a web app, which lives on its own server, that sits between Salesforce and your Tableau Server.  Sparkler allows for single sign on using [Trusted Tickets](https://help.tableau.com/current/server/en-us/trusted_auth.htm), so that users logged into Salesforce are automatically logged into your Tableau Server.  It also makes it easier to embed tableau dashboards into various pages within Salesforce.  Tableau provides some documentation on how to get Sparkler setup, but it's a manual process.  This project aims to automate as much as possible, and make it easier to get started using Tableau, Sparkler, and Salesforce.

# Setup

## Before you start
You'll need to have the following, in order to complete the setup
1. A __Salesforce System Administrator__ login, in order to add Sparkler as a connected app in Salesforce
2. Access to TSM on your Tableau Server, as well as being able to perform a server restart
3. Either of the following: 
   1. AWS account with permission to spin up new instances, and an AWS SSL certificate
   2. Linux server with a SSL certificate (not self-signed)

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
This option is applicable if your organization has its own servers (hyper-v, vmware, physical machines, etc) and you want to host the Sparkler web app.  In this case, you can use the setup.sh bash script to automate the installation and configuration of your sparkler server.  The bash script should work on any linux OS, that leverages [YUM](http://yum.baseurl.org/) as a package manager and [systemd](https://www.linux.com/tutorials/understanding-and-using-systemd/) for service management.  The script was testing on Amazon Linux 2, which is similar to CentOS and RedHat.  

To run the setup, copy or download the __setup.sh__ to the server you want to run Sparkler on, which must be a linux box (CentOS/RedHat preferred).   Also, make sure the setup.sh file has execute permissions (chmod 550).  You will need these 2 additional files on your Sparkler server:
* __config__ - Simple file that gets sourced by setup.sh, so that we know where to download Tomcat and Sparkler from.  See the example file [here](/template-files/config)
* __sparkler.xml__ - This will need to be configured to match your Tableau and Salesforce environments.  See the template [here](/template-files/sparkler.xml) for more details on what options need to be set here.

Assuming you copied all three files (setup.sh, config, & sparkler.xml) to the Sparkler server's /tmp directory, you can run the setup like this:
`sudo ./setup.sh "/tmp/config" "/tmp/sparkler.xml"`

This should download/install Java and Tomcat, configure tomcat to run as a service (so it starts automatically if the server restarts), download/configure/deploy the sparkler web app.  Since this script was testing on Amazon Linux 2, your mileage may vary on other operating systems, but you should be able to tweak the script as needed for different distros.

The only thing not done by this script, is to configure Sparkler with SSL.  In AWS we use a Load Balancer with SSL termination to achieve this, but when deploying on your own server you will need to setup SSL before using Sparkler.  We discourage the use of self-signed SSL certificates, as they will show a warning prompt when used and will not work with the Salesforce mobile app.  For help setting up SSL with tomcat, see their [official documentation](https://tomcat.apache.org/tomcat-7.0-doc/ssl-howto.html#Installing_a_Certificate_from_a_Certificate_Authority) to import the certificate.  You will also need to adjust Tomcat's server.xml configuration file, found at `/opt/tomcat/conf/server.xml`.  There should be a section (commented out) for enabling SSL on port 8443, just remove the `<!--` and `-->` above/below the Connector, and restart tomcat.  Now you should be able to access the sparkler app via SSL on port 8443.

### Option 2: Using AWS to host Sparkler
This option is applicable if your organization leverages AWS as a hosting platform.  In this case, you can use the cloudformation template to spin up a new EC2 instance and automatically install/setup Sparkler.  Before using Cloudformation, you need to make sure you have an SSL Certificate available to use.  Since Salesforce.com uses HTTPS for their site, any communication to Sparkler (and Tableau Server) must also be over HTTPS.  If you've never created an SSL Certificate before, you can see [this link](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html) on how to create SSL certificates using __AWS Certificate Manager__.  You will need the ARN from your SSL Certificate, to pass as a parameter for the Cloudformation template.

![Image of AWS Certificate Manager UI](/screenshots/aws-cm-1.png)

To use the Cloudformation template, search the AWS Console for __Cloudformation__ and use the left navigation to get to the __Stacks__ page.  Click the button to __Create Stack - with new resources__.  Step 1 is just to select your template file and click next.
![Image of create-cloud-formation 1](/screenshots/aws-cf-1.png)

The next page is just for entering your parameters.  The table below, outlines what should be used for each parameter:

| Parameter          | Type         | Description |
| ---                | ---          | ---         |
| VPC                | AWS | Select the VPC you want to deploy to |
| Instance Type      | AWS | Instance type for the sparkler server, the default should be fine |
| Primary Subnet     | AWS | Choose a subnet, in which to deploy the Sparker server |
| Secondary Subnet   | AWS | Choose a subnet from a different availability zone.  The load balancer requires 1 subnet from each AZ |
| Security Groups    | AWS | Specify which security groups to apply to the EC2 instance.  Ports 80 and 443 should be allowed for inbound HTTP/HTTPS traffic. |
| SSL Certificate ARN | AWS | Copy/paste the ARN of your SSL Certificate, from AWS Certificate Manager |
| Key Pair            | AWS | Key pairs are required to creating any EC2 instance, so that you can actually connect to it via SSH |
| Consumer Secret       | Salesforce | Copy/Paste the consumer secret from your Salesforce Connected App |
| User Identifier Field | Salesforce | Select which method should be used to map Salesforce users to Tableau users |
| Allowed Email Domains | Salesforce | If selecting _signedIdentity_ as the User Identifier Field, you must specify the email domain(s) to allow (ex. _@company.com_ |
| Tableau Server Host         | Tableau | Name or IP address of your Tableau Server (do not include `https://`) |
| Tableau Server SSL          | Tableau | Does your end users access Tableau Server over SSL? |
| Tableau Server Port         | Tableau | Port of your Tableau Server (usually 443 for SSL) |
| Tableau User for Testing    | Tableau | Any Tableau User, that we can use to verify SSO is working |
| Use Trusted Tickets         | Tableau | Should we use Trusted Tickets to enable SSO? |
| Enable Sparkler Status Page | Tableau | Should we enable the status page for Sparker?  Mark yes for testing, but disable this in production. |

The next page can be left as is, just click the next button.  On the last page, check the blue box at the bottom and then click on the orange __Create Stack__ button.  
![Image of create-cloud-formation 2](/screenshots/aws-cf-2.png)

Once started, the events tab should show you the progress of your cloudformation stack.  You should see a green checkmark next to the stack name, once the process is complete. 
![Image of create-cloud-formation 3](/screenshots/aws-cf-3.png)

You can get the Sparkler server's public IP from the Outputs tab, which can be used for setting up Trusted Tickets on your Tableau Server.
![Image of create-cloud-formation 4](/screenshots/aws-cf-4.png)

## Step 3: Enable Trusted Ticket authentication on your Tableau Server.
Tableau provides instructions for how to setup trusted ticket authentication, which can be found [here](https://help.tableau.com/current/server/en-us/trusted_auth_trustIP.htm).  You'll just need the IP of your Sparkler server, in order to add it as a _trusted ip_ on your Tableau Server.  Once you've configured Tableau Server for Trusted Tickets from Sparkler, you should check Sparkler's status page at `https://<sparkler-server>/sparkler/status`
![Image of sparkler status page](/screenshots/sp-status.png)

# Notes
* This project is not meant to replace the official documentation on Sparkler
* For more details on the installation process and settings to tweak, please refer to the [sparkler documentation](https://www.tableau.com/sfdc-canvas-adapter)

## Cloudformation Template Details
The Cloudformation template creates the following resources:
* _EC2 Instance_ - Used to host the Sparkler web app
* _Application Load Balancer_ - Provides SSL termination, and directing requests to the tomcat port
  * Listener for HTTP/80 - Listens for HTTP traffic, and redirects to HTTPS
  * Listener for HTTPS/443 - Redirects HTTPS traffic to the tomcat web app
* _Load Balancer Target Group_ - Defines what instances are available
* _IAM Role_ - Used to define what the EC2 instance is permissioned to do.  The policy equates to the following named policies:
  * ElasticLoadBalancingReadOnly
  * ElasticLoadBalancingFullAccess
  * ResourceGroupsandTagEditorReadOnlyAccess
  * ResourceGroupsandTagEditorFullAccess
  * AmazonEC2SpotFleetTaggingRole
  * AmazonEC2FullAccess
