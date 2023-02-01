# Deploy Spinnaker on TKE

## Step 1: Install Halyard

- Linux system requirements:

   Ubuntu 18.04 or higher

   Debian 10 or higher

1. Download latest Halyard:

   `curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh`

2. Install it:

   `sudo bash InstallHalyard.sh`

3. Enable command completion:

   `. ~/.bashrc`


[Other installation methods](https://spinnaker.io/docs/setup/install/halyard)

## Step 2: Set up Environment Virable

```
export SPINCONFIG=./Spinnaker_k8s_config_file
export WPCONFIG=./Wordpress_k8s_config_file
export CONTEXT=$(kubectl config current-context --kubeconfig=$SPINCONFIG) #Spinnaker k8s context

```



## Step 3: Configure Spinnaker Accounts and Storage
### Spinnaker TKE Cluster Account

1. Use Terraform to create `spinnaker` namespace, service account, and bind role to it on k8s:

   Change the yaml file configuration in ~/settings, then run `terraform apply`.

2. Generate Spinnaker kubernetes config file

   Extract the secret token of the created service account

   ```
   export TOKEN=$(kubectl get secret --context $CONTEXT --kubeconfig=$SPINCONFIG\
   $(kubectl get serviceaccount spinnaker-sa \
       --context $CONTEXT \
       --kubeconfig=$SPINCONFIG \
       -n spinnaker \
       -o jsonpath='{.secrets[0].name}') \
   -n spinnaker \
   -o jsonpath='{.data.token}' | base64 --decode)
   ```

   Set Set the user entry in original kubeconfig file:

   ```
   kubectl config set-credentials ${CONTEXT}-token-user --token $TOKEN

   kubectl config set-context $CONTEXT --user ${CONTEXT}-token-user
   ```

The above process is on Kubernetes v1.22. If you work on v1.24, you need to add one more step to generate secret and bind to service account because Kubernetes no longer generates sercets when a service account is created in v1.24. You can uncomment related blocks in `main.tf` to bind the secret automatically.

### Spinnaker Managed TKE Cluster Account
### TCR Account
### COS Storage
### COS Artifacts Account
