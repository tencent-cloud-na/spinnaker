# Deploy Spinnaker on TKE

Follow the process below, you should be able to install Spinnaker on Tencent Cloud TKE service. After installation, you can find a basic example of using Spinnaker to deploy WordPress on specified TKE cluster [here](https://github.com/tencent-cloud-na/spinnaker/blob/main/wordpress_deployment_example.md).

You can also find all the command lines that are used below [here](https://github.com/tencent-cloud-na/spinnaker/blob/main/cli_collection.txt).

## Step 1: Install Halyard

- Linux system requirements:

   Ubuntu 18.04 or higher

   Debian 10 or higher

1. Download latest Halyard:

   ```
   curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
   ```

2. Install it:

   ```
   sudo bash InstallHalyard.sh
   ```

3. Enable command completion:

   ```
   . ~/.bashrc
   ```


[Other installation methods](https://spinnaker.io/docs/setup/install/halyard)

## Step 2: Set up Environment Variables

Set up part of the environment variables that will be used later.

```
export SPINCONFIG=./Spinnaker_k8s_config_file
export WPCONFIG=./Wordpress_k8s_config_file
export CONTEXT=$(kubectl config current-context --kubeconfig=$SPINCONFIG) #Spinnaker k8s context
export NAMESPACE=spinnaker
export SPINTKE=Spinnaker_TKE_Account_Name
export COSART=Spinnaker_COS_Artifacts_Account_Name
export DRTCR=Spinnaker_TCR_Account_Name
export SPIN_VERSION=1.29.2
```



## Step 3: Configure Spinnaker Accounts and Storage
### Spinnaker TKE Cluster Account

1. Use Terraform to create `spinnaker` namespace, service account, and bind role to it:

   Change the yaml file configuration in ~/settings, then run `terraform apply`.

2. Generate Spinnaker kubernetes config file

   Extract the secret token of the created service account

   ```
   export TOKEN=$(kubectl get secret --context $CONTEXT --kubeconfig=$SPINCONFIG\
   $(kubectl get serviceaccount spinnaker-sa \
       --context $CONTEXT \
       --kubeconfig=$SPINCONFIG \
       -n $NAMESPACE \
       -o jsonpath='{.secrets[0].name}') \
   -n spinnaker \
   -o jsonpath='{.data.token}' | base64 --decode)
   ```

   Set Set the user entry in original kubeconfig file:

   ```
   kubectl config set-credentials ${CONTEXT}-token-user --kubeconfig=$SPINCONFIG --token $TOKEN

   kubectl config set-context $CONTEXT --kubeconfig=$SPINCONFIG --user ${CONTEXT}-token-user
   ```

   Add Spinnaker k8s account

   ```
   hal config provider kubernetes enable

   hal config provider kubernetes account add $SPINTKE --kubeconfig-file=$SPINCONFIG --context $CONTEXT
   ```

The above process is on Kubernetes v1.22. If you work on v1.24+, you need to add one more step to generate secret and bind to service account because Kubernetes no longer generates sercets when a service account is created in v1.24. You can uncomment related blocks in `main.tf` to bind the secret automatically.

### Spinnaker Managed TKE Cluster Account

Modify the arguments and follow the process in the previous section to add the k8s clusters that Spinnaker are going to manage.

### TCR Account

Enable Docker Registry Provider:

```
hal config provider docker-registry enable
```

Add Spinnaker TCR account (if you don't supply the value of --secret-access-key on the command line, you will be prompted to enter the value on STDIN once the command has started running):

```
hal config provider docker-registry account add $DRTCR \
  --address https://TCR_address \
  --repositories TCR_repo \
  --username TCR_username \
  --password
```

### COS Storage

Run the following to configure COS storage (if you don't supply the value of --secret-access-key on the command line, you will be prompted to enter the value on STDIN once the command has started running):

```
hal config storage s3 edit \
  --access-key-id IKIDToxsh***aIqCOM6bstgGfqm \
  --secret-access-key \
  --endpoint cos.na-siliconvalley.myqcloud.com \
  --bucket your-cos-bucket \
  --root-folder spinnaker
```

Set the storage source to it:

```
hal config storage edit --type s3
```

### COS Artifacts Account

Enable the artifact provider:

```
hal config artifact s3 enable
```

Add an artifact account:

```
hal config artifact s3 account add $COSART \
  --api-endpoint cos.na-siliconvalley.myqcloud.com
```

**_Please make sure `cos` add-on has been installed into the TKE cluster where Spinnaker is going to install._**

## Step 4: Deploy Spinnaker

First, you need to set a distributed Spinnaker installation onto one of the Kubernetes cluster accounts:

```
hal config deploy edit --type distributed --account-name $SPINTKE
```

Choose Spinnaker Verison you are going to install:

```
hal config version edit --version $SPIN_VERSION
```

Modify `liveness-probe-initial-delay-seconds` value to to the upper bound of your longest service startup time:

```
hal config deploy edit --liveness-probe-enabled true --liveness-probe-initial-delay-seconds 180
```

Deploy Spinnaker:

```
hal deploy apply
```

## Step 5: Expose Spinnaker Services to a private Load Balancer

Uncomment the Step 5 block in `main.tf` and modify related yaml file in `./settings` and then run `terraform apply` to add private Load Balancer service to Spinnaker.

Configure the URL for Gate and Deck:

```
#get deck ip
export UI_URL=$(kubectl -n $NAMESPACE get svc spin-deck-private -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

#get gate ip
export API_URL=$(kubectl -n $NAMESPACE get svc spin-gate-private -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

#configure it to Spinnaker
hal config security api edit --override-base-url http://${API_URL}
hal config security ui edit --override-base-url http://${UI_URL}
```

Deploy the settings:

```
hal deploy apply
```

After all these steps, you should be able to access the Spinnaker UI and see all the accounts you set previously.

![Spin_UI](https://github.com/tencent-cloud-na/spinnaker/blob/main/screenshots/spin_1.png)

To see a basic example of how to deploy a WordPress application to one of your TKE clusters, you can visit [this page](https://github.com/tencent-cloud-na/spinnaker/blob/main/Wordpress_Deployment_Example.md).

## Upgrade Spinnaker Version

If you want to change Spinnaker versions using Halyard, you can read about supported versions like so:

```
hal version list
```

And pick a new version like so:

```
hal config version edit --version $VERSION
hal deploy apply
```

## Delete Deployed Spinnaker Service
To delete deployed Spinnaker, run `hal deploy clean`.
