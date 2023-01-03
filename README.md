## mage-os-docker

### Start 

    docker run --rm -d --name mage-os osioaliu/mage-os
    docker exec -it mage-os start

### or start with script
    
    sudo wget https://raw.githubusercontent.com/aliuosio/mage-os-docker/main/bin/mage-os -P /usr/local/bin/; 
    sudo chmod +x /usr/local/bin/mage-os && mage-os

> next time just start the server with command: mage-os 

### or start with docker-compose to use with own project
    
    version: '3.8'
    services:
    mage_os:
      container_name: mage_os
      image: osioaliu/mage-os
      sysctls:
        net.core.somaxconn: 65536
      volumes:
        - <your project folder>:/var/www/html:delegated

> after running `docker-compose up -d`. run docker exec -it mage_os start to start the webserver inside

#### Backend
    http://<ip displayed on your console>/admin
    User: mage2_admin
    Password: mage2_admin123#T

#### Frontend
    http://<ip displayed on your console>

##### Extra Composer Packages installed:
* **magento2-gmailsmtpapp**
   
  configure Magento 2 / Adobe Commerce to send all transactional emails using Google App, Gmail, Amazon Simple Email Service (SES), Microsoft Office365 or any other SMTP servers.


* **yireo/magento2-webp2**

    This module adds WebP support to Magento 2.


* **dominicwatts/cachewarmer**

  Magento 2 Site based Cachewarmer / Link checker / Siege Tester

> Never use in Production, It's meant to demo or as dev enviroment

**Todos:**

V1
* ~~create db before magento install~~
* ~~set webp executable and make sure magento uses it~~
* ~~add redis~~
* ~~reduce docker image size~~
* ~~Use php alpine image as base image~~

V2
* make configurable app versions