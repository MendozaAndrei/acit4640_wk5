# acit4640_wk5

## Create the AMI by running packer: 
### Run the following commands to initualize the packer
```bash
packer init . #initialized packer
packer verifiy . #A command that verifies the configuration for the packer file
packer build . #This will run the packer file and connect to your AWS account and create the AMI image.
```


## Go to AWS to check on the instances created. 

1. Go to your AMI to see if it has been created:
   <img width="1628" height="950" alt="image" src="https://github.com/user-attachments/assets/4fe00060-5991-43cc-a8e3-7c3978619b60" />

2. Now create an EC2 instance that uses the AMI image. After creating, it should be there:
   <img width="1628" height="950" alt="image" src="https://github.com/user-attachments/assets/a5210239-61ee-49de-af58-e046856701af" />

3. After doing that, you can now visit the website. We did this by changing the link to http:// right infront of the IP address and the DNS name:
- Visiting via Public IP Address:
<img width="1869" height="1127" alt="image" src="https://github.com/user-attachments/assets/585a8b30-9c85-4284-8c16-5ac146861801" />

- Visiting via DNS Name:
<img width="1864" height="1092" alt="image" src="https://github.com/user-attachments/assets/75339b64-82af-4cd9-99e7-0ceb1cb41c8d" />
