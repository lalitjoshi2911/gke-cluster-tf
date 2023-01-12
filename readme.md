Let's assume that we have created following resources on GCP already:
* Project
* VPC (custom mode)
* One subnet in "asia-southeast1"
* Two secondary ip ranges configured in the above subnet:
        * POD range
        * Service range
* One service account for terraform with required roles 
* Downloaded service account json key file
* A Linux virtual machine 
        * acts as a jump host on google cloud (configured in same subnet).
        * must have terraform installed
        * can be accessed by external ip address