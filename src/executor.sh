#!/bin/bash

#*********************************** Helper Code block ***********************************#

# Initialize colors
RED='\033[0;31m';
DARK_GREY='\033[1;30m';
GREEN='\033[0;32m';
LIGHT_GREY='\033[0;37m';
YELLOW='\033[1;33m';
NC='\033[0m';

log () {
    echo "$1";
}

log_info () {
    echo "${LIGHT_GREY}$1${NC}";
}

log_debug () {
    echo "${DARK_GREY}$1${NC}";
}

log_success() {
    echo "${GREEN}$1${NC}";
}

log_warning () {
    echo "${YELLOW}$1${NC}";
}

log_error () {
    echo "${RED}$1${NC}";
}

#************************************ Processor block ************************************#

generate_code_for_language() {
    lang="$1";

     # Create a local directory to save the code
    if [[ "$codepath" != "./" && "$codepath" != "." && "$codepath" != "../" ]]; then
        mkdir -p "$codepath";
    fi

    # Run code code_generator for each schema file
    for schema_file in "${schema_files[@]}"; do
        if [[ -f $code_generator ]]; 
        then
            source $code_generator;
        else
            log "Code generator file not found"
            exit 1;
        fi
    done
    # stash the changes for the current language
    git stash -u;
}

create_code_branch_for_language() {
    lang="$1";

    # 1. Checkout existing branch or create a new orphan branch 
    code_branch="$branch_prefix/$lang";

    # Try creating a branch from remote
    if [[ ! $(git checkout -b "$code_branch" origin/"$code_branch") ]]; then 
        # if remote branch doesn't exist try creating a new local orphan branch
        if [[ ! $(git checkout --orphan "$code_branch") ]]; then 

            # Hopefully no-one would've created local branch before us but just in case

            git checkout "$code_branch"; # Check out the local branch if a local branch already exists
            
            # Might not be needed in our case as we'd have the latest one.
            # WARNING: multiple actions running simultaneously is not handled

        fi
    fi

    # 2. Remove all exisiting files
    git rm -rf .

    # 3. Write generated code
    git stash pop;

    # 4. Update the repository
    git add "$codepath";
    git commit -m "$commit_msg";

    # 5. Tag this commit if the main commit was tagged
    tag=$(git describe --exact-match $latest_commit_sha)
    if [[ "$tag" ]]; then
        git tag "$tag" 
    fi

    git push -f origin "$code_branch";

}


generate_code_for_languages() {
    # Iterate through languages in reverse inorder for git stash to be in given order
    for (( idx=${#languages[@]}-1 ; idx>=0 ; idx-- )) ; do
        generate_code_for_language "${languages[idx]}";
    done
}


create_code_branch_for_languages() {
    # Iterate over languages in natural order as items were stashed in reverse order
    for lang in "${languages[@]}"; do
        create_code_branch_for_language "$lang";
    done
}

#************************************ Main Function ************************************#

runner() {
    # move into the workspace
    pushd $GITHUB_WORKSPACE || return;

    if [[ -f "pre_process_hook.sh" ]]; then
        source ./pre_process_hook.sh
    fi

    # set author
    git config --local user.email "action@github.com"
    git config --local user.name "GitHub Action"

    log "Lang = $languages | code_generator = $code_generator | \
Schema Files = $schema_files_unseperated | Code Path = $codepath | Commit Msg = $commit_msg";

    # Get source branch info
    source_branch=$(git rev-parse --abbrev-ref HEAD);

    # Generate code for each language and stash the code
    generate_code_for_languages;

    # Fetches all remote branches
    git fetch;

    # Create a branch for each language and push corresponding stashed code
    create_code_branch_for_languages;

    # Move back to source branch (optional)
    git checkout "$source_branch";

    if [[ -f "post_process_hook.sh" ]]; then
        source ./post_process_hook.sh
    fi
}

#************************************ Program Start ************************************#


source ./input_parser.sh;

# TODO: Move code_generator.sh to workspace
cp code_generator.sh "$GITHUB_WORKSPACE";

runner;
