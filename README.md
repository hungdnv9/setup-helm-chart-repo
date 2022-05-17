# Set up a Helm v3 chart repository in Amazon S3

https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/set-up-a-helm-v3-chart-repository-in-amazon-s3.html

This pattern helps you to manage Helm v3 charts efficiently by integrating the Helm v3 repository into Amazon Simple Storage Service (Amazon S3) on the Amazon Web Services (AWS) Cloud

This pattern uses AWS CodeCommit for Helm repository creation, and it uses an S3 bucket as a Helm chart repository, so that the charts can be centrally managed and accessed by developers across the organization.

Tools:
- helm

    ```sh
    cd /tmp
    wget https://get.helm.sh/helm-v3.0.2-linux-amd64.tar.gz
    tar zxvf helm-v3.0.2-linux-amd64.tar.gz
    chmod +x linux-amd64/helm
    sudo mv linux-amd64/helm /usr/bin/helm
    ```

- helm-s3 plugin

    ```sh
    helm plugin install https://github.com/hypnoglow/helm-s3.git
    ```

- aws s3


## Package the local Helm chart

This command packages a chart into a versioned chart archive file. If a path is given, this will look at that path for a chart (which must contain a Chart.yaml file) and then package that directory.

    ```sh
    cd charts
    helm package api-quickstart
    ```
    

## Initialize an S3 bucket as a Helm repository

### 1. Create an S3 bucket for Helm charts.
- Create a unique S3 bucket. In the bucket, create a folder called `charts`
- The example in this pattern uses s3://helm-repository-316516050658/charts/<chart_name> as the target chart repository.
- To initialize the target folder as a Helm repository, use the following command:

        ```sh
        cd charts
        helm s3 init s3://helm-repository-316516050658/charts
        ```

    This command generates an empty index.yaml and uploads it to the S3 bucket under /charts key
    To work with this repo by it's name, first you need to add it using native helm command:

        ```sh
        helm repo add helm-s3-repo-quickstart s3://helm-repository-316516050658/charts
        ```
### 2. Store the local package in the Amazon S3 Helm repository.

- To upload the local package to the Helm repository in Amazon S3, run the following command:

    ```sh
    cd charts
    helm s3 push --force ./api-quickstart-0.1.0.tgz helm-s3-repo-quickstart
    ```

- Add new charts to an existing repository.  

    ```sh
    cd charts
    helm package web-quickstart
    helm s3 push --force ./web-quickstart-0.1.0.tgz helm-s3-repo-quickstart
    ```
- Search for the Helm chart.

    ```sh
    helm search repo helm-s3-repo-quickstart
    NAME                                    CHART VERSION   APP VERSION     DESCRIPTION                
    helm-s3-repo-quickstart/api-quickstart  0.1.0           1.16.0          A Helm chart for Kubernetes
    helm-s3-repo-quickstart/web-quickstart  0.1.0           1.16.0          A Helm chart for Kubernetes    
    ```

## Upgrade your Helm repository

- To push the new package, version of 0.1.1

    ```sh
    cd charts
    helm package api-quickstart
    helm s3 push --force ./api-quickstart-0.1.1.tgz helm-s3-repo-quickstart
    ```

- To view all the available versions of a chart, run the following command with the --versions flag. Without the flag, Helm by default displays the latest uploaded version of a chart.

    ```sh
    helm search repo helm-s3-repo-quickstart --versions
    NAME                                    CHART VERSION   APP VERSION     DESCRIPTION                
    helm-s3-repo-quickstart/api-quickstart  0.1.1           1.16.0          A Helm chart for Kubernetes
    helm-s3-repo-quickstart/api-quickstart  0.1.0           1.16.0          A Helm chart for Kubernetes
    helm-s3-repo-quickstart/web-quickstart  0.1.0           1.16.0          A Helm chart for Kubernetes    
    ```

## Install chart

To install the new version (0.1.1) from the Amazon S3 Helm repository, use the following command: 

    ```sh
    helm upgrade --install my-app-release helm-s3-repo-quickstart/api-quickstart --version 0.1.1 --namespace dev
    ```

## Reindex

If your repository somehow became inconsistent or broken, you can use reindex to recreate the index in accordance with the charts in the repository.

    ```sh
    helm s3 reindex <your_repo>
    ```

When the bucket is replicated you should make the index's URLs relative so that the charts can be accessed from a replica bucket.
    
    ```sh
    helm s3 reindex --relative <your_repo>
    ```
