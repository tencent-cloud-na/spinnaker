# Automatically Deploy WordPress on Managed TKE Cluster

Here is a basic example of how to use Spinnaker to automatically deploy latest WordPress image that is pushed to TCR on a Managed TKE cluster.

## Step 1: Create an Application

1. Open the Spinnaker UI and go to `Application` section.

2. Click `Create Application`.

3. Enter Application's `Name`, `Owner Email`, and other information that is applicable to you, then click `Create`.

![spin_create_application](https://github.com/tencent-cloud-na/spinnaker/blob/main/screenshots/spin_create_application.png)

## Step 2: Create a Pipeline

1. Go to `PIPLINES` section under the application you created in the previous step.

2. Click `create`.

3. Enter Pipeline's information and then click `Create`.

![spin_create_pipe](https://github.com/tencent-cloud-na/spinnaker/blob/main/screenshots/spin_create_pipe.png)

## Step 3: Configure the Pipeline

Click the `configure` button on the Pipeline you just created.

![spin_pipe_config_1](https://github.com/tencent-cloud-na/spinnaker/blob/main/screenshots/spin_pipe_config_1.png)

### Set the TCR Trigger

You should now be in the `Configuration` stage page.

1. Now click on `Add Trigger` under `Automated Triggers`

2. Select Type as `Docker Registry`, and in the `Registry Name` dropdown select the TCR account you added, and do the same thing for `Organization` and `Image` dropdown list.

3. Click on `Save Changes`.

![spin_pipe_config_2](https://github.com/tencent-cloud-na/spinnaker/blob/main/screenshots/spin_pipe_config_2.png)

### Evaluate Variable Configuration

1. Click on `Add Stage` and select type as `Evaluate Variables` from the dropdown.

The [Evaluate Variables](https://spinnaker.io/docs/guides/user/pipeline/expressions/#create-variables-using-an-evaluate-variables-stage) stage can be used to create reuseable variables with custom keys paired with either static values or values as the result of a pipeline expression.

2. Click `Add Variable` and add the variable name as `tag`, `image_url` and value as `${trigger['tag']}` and your TCR repo URL.

3. Click on `Save Changes`.

![spin_pipe_config_3](https://github.com/tencent-cloud-na/spinnaker/blob/main/screenshots/spin_pipe_config_3.png)

### Set up Deploy Stage

1. 1. Click on `Add Stage` and select type as `Deploy (Manifest)` from the dropdown.

2. In the `Account` dropdown, select the account that you want to deploy the WordPress.

3. Enter the WordPress manifest content in the text box. Please make sure you have the access to pull the image from TCR.

4. Click on `Save Changes`.

![spin_pipe_config_4](https://github.com/tencent-cloud-na/spinnaker/blob/main/screenshots/spin_pipe_config_4.png)

## Step 4: Test the Pipeline

Push a new WordPress image to your TCR to test the trigger. If everything goes well, you should be able to see the Pipleline being triggerred and WordPress being deployed to the TKE cluster you specified.

![spin_pipe_test_1](https://github.com/tencent-cloud-na/spinnaker/blob/main/screenshots/spin_pipe_test_1.png)

![spin_pipe_test_2](https://github.com/tencent-cloud-na/spinnaker/blob/main/screenshots/spin_pipe_test_2.png)
