#!/usr/bin/env bash

case "$1" in
"dev")
    echo "Run server for dev"
    docker-compose up -d
    ;;
"prod")
    NAMESPACE="prod1"
    AWS_REGION="eu-central-1"
    AWS_ECR="786743331197.dkr.ecr.eu-central-1.amazonaws.com/challenge/"

    #Building helper container with helm and kubectl
    docker build -t k8s_utils:local -f Dockerfile_EKS .

    #Generating image name: project birthday and name of a branch
    IMAGENAME="birthday:`git branch | grep \* | cut -d ' ' -f2`"

    #Building a main container
    docker build -t $IMAGENAME -f Dockerfile .

    #Login to Amazon ECR and pushing the main container to ECR
    `aws ecr get-login --region $AWS_REGION --no-include-email`
    docker tag $IMAGENAME "$AWS_ECR$IMAGENAME"
    docker push "$AWS_ECR$IMAGENAME"

    #Getting additional info for kubernetes labels
    echo "Getting commit time"
    CI_COMMIT_SHA=$( git rev-parse HEAD | cut -c 1-8)
    COMMIT_TIME=$(git show -s --pretty='%ct' $CI_COMMIT_SHA)
    COMMIT_TIME_FORMATTED=$(date +"%d.%m.%Y_%H-%M-%S" -d @$COMMIT_TIME)
    echo $COMMIT_TIME_FORMATTED

    #Constructing arguments to use with helm template
    HELM_ARGS="--set image=$IMAGENAME --set namespace=${NAMESPACE} --set environment=$1  --set commit=${CI_COMMIT_SHA} --set commit_time=${COMMIT_TIME_FORMATTED}"


    echo "deploying IMAGENAME to ${NAMESPACE} environment"
    echo "Getting current deployment revision"

    #Getting current deployment revision - in case of deployment will fail we can rollback to it
    REVISION=$(docker run -v /root/.kube/config:/root/.kube/config --rm -ti k8s_utils:local helm template . $HELM_ARGS -x templates/deployment.yaml | kubectl rollout history -f - | tail -n3 | grep . | awk '{print$1}')

    #Rendereng templates with values.yaml file and helm templates
    docker run -v /root/.kube/config:/root/.kube/config --rm -ti k8s_utils:local helm template . $HELM_ARGS  \
    | kubectl apply -f -

    #Checking rollout status of the new deployment for period of 4 minutes
    docker run -v /root/.kube/config:/root/.kube/config --rm -ti k8s_utils:local helm template . $HELM_ARGS  \
    | kubectl -n ${NAMESPACE} rollout status -w --timeout=240s -f  -

    #In case of failed deployment, rollback to previous revision
    if [ $? -ne 0 ]; then
        docker run -v /root/.kube/config:/root/.kube/config --rm -ti k8s_utils:local helm template . $HELM_ARGS  \
        | kubectl rollout undo -f - --to-revision=$REVISION
    fi
    ;;
esac
