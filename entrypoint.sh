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
    branchName=${4:-"made-by-gha-$dateString"}
    comment=${5:-"This commit has pushed by loilo-inc/actions-make-pr at $dateString"}
    prTitle=${6:-"pull request by loilo-inc/actions-make-pr $dateString"}
    prComment=${7:-$prTitle}
    token=${8:-$GITHUB_TOKEN}
    label=$9
    autoMerge=${10:-0}

    git config user.email "${email}"
    git config user.name "${userName}"
    git checkout -b ${branchName}
    git add .
    git commit -m "${comment}"
    git remote set-url origin https://${userName}:${token}@github.com/${GITHUB_REPOSITORY}.git
    git push origin ${branchName}
    data='{"title":"'${prTitle}'","head":"'${branchName}'","base":"'${baseBranch}'","body":"'${prComment}'"}'
    response=$(curl -X POST -H "Authorization: token ${token}" -H "Content-Type:application/json" --data "$data" https://api.github.com/repos/${GITHUB_REPOSITORY}/pulls)
    prUrl=$(echo "${response}" | jq -r ".url")
    issueNumber=$(echo "${response}" | jq -r ".number")
    head=$(echo "${response}" | jq -r ".head | .sha")
    echo "${issueNumber}"
    echo "${head}"
    if [[ -n ${label} ]]; then
      data='{"labels":["'${label}'"]}'
      curl -X POST -H "Authorization: token ${token}" -H "Content-Type:application/json" --data "$data" https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${issueNumber}/labels
    fi
    if [[ ${autoMerge} = 1 ]]; then
      data='{"commit_title":"'${prTitle}'","commit_message":"'${prComment}'","sha":"'${head}'"}'
      curl -X PUT -H "Authorization: token ${token}" -H "Content-Type:application/json" --data "$data" ${prUrl}/merge
    fi
else
    echo "noop"
fi
