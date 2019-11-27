#!/usr/bin/env bash

if [[ -n $(git diff --numstat) ]]; then
    userName=$1
    if [[ -z ${userName} ]]; then
        echo "user-name is required input."
        exit 1
    fi
    email=$2
    if [[ -z ${email} ]]; then
        echo "email is required input."
        exit 1
    fi
    baseBranch=${3:-"master"}
    dateString=$(date "+%Y%m%d%H%M%S")
    branchName=${5:-"made-by-gha-$dateString"}
    comment=${6:-"This commit has pushed by loilo-inc/actions-make-pr at $dateString"}
    prTitle=${7:-"pull request by loilo-inc/actions-make-pr $dateString"}
    prComment=${8:-$prTitle}

    git config user.email ${email}
    git config user.name ${userName}
    git checkout -b ${branchName}
    git add .
    git commit -m ${comment}
    git push origin ${branchName}
    data='{"title":"'${prTitle}'","head":"'${branchName}'","base":"'${baseBranch}'","body":"'${prComment}'"}'
    echo ${GITHUB_REPOSITORY}
    curl -X POST -H "Authorization: token ${GITHUB_TOKEN}" -H "Content-Type:application/json" --data "$data" https://api.github.com/repos/${GITHUB_REPOSITORY}/pulls
else
    echo "noop"
fi
