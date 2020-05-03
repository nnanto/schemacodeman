# set -e
# Loop through each argument and assign
previous_arg="";

while [ $# -gt 0 ]; do

    if [[ $1 == *"--"* ]]; then
        previous_arg=${1%=*}
    fi

    case "$1" in
        # 1. Get language to generate code
        --languages=*)
            lang_unseparated="${1#*=}"
            ;;
        --languages)
            lang_unseparated="${2}"
            shift
            ;;

        # 2. Get code_generator (proto, avro, json etc...)
        --code_generator=*)
            code_generator="${1#*=}"
            ;;
        --code_generator)
            code_generator="${2}"
            shift
            ;;

        # 3. Get schema files separated by comma
        --schema_files=*)
            schema_files_unseperated="${1#*=}";
            ;;
        --schema_files)
            schema_files_unseperated="${2}"
            shift
            ;;

        # 4. Get directories to place the generated code
        --codepath=*)
            codepath="${1#*=}"
            ;;
        --codepath)
            codepath="${2}"
            shift
            ;;

        # 5. Get Commit Msg for Code Generation
        --commit_msg=*)
            commit_msg="${1#*=}"
            ;;
        --commit_msg)
            commit_msg="${2}"
            shift
            ;;

        # 7. Get branch prefix. The generated code will be placed in branch: {branch_prefix}/{lang}
        --branch_prefix=*)
            branch_prefix="${1#*=}"
            ;;
        --branch_prefix)
            branch_prefix="${2}"
            shift
            ;;

        --base_commit=*)
            base_commit="${1#*=}"
            ;;
        --base_commit)
            base_commit="${2}"
            shift
            ;;
        
        *)
            if [[ $previous_arg == "--schema_files" ]]; then
                schema_files_unseperated="$schema_files_unseperated,$1"
            elif [[ $previous_arg == "--languages" ]]; then
                lang_unseparated="$lang,$1"
            else
                log_error "Unknown input: $1. $previous_arg doesn't accept multiple params!"
                exit 1
            fi
            ;;
    esac
    shift
done

# Default language to `java`
lang_unseparated=${lang_unseparated:-"java"}
languages=(${lang_unseparated//,/ })

# Default code_generator to `proto`
code_generator=${code_generator:-"code_generator.sh"}

# Default schema file to `schema.{code_generator}`
schema_files_unseperated=${schema_files_unseperated:-"schema.$code_generator"}
schema_files=(${schema_files_unseperated//,/ })

# Default code path to `schema/`
codepath=${codepath:-"schema"}

# Get the latest commit message from current workspace
latest_commit=$(git log --oneline | head -n 1);
latest_commit_sha=${latest_commit:0:6};

if [[ $commit_msg == "_" ]]; then 
    $commit_msg = "";
fi

# Defaults to "Code generated for the {latest_commit_sha}"
commit_msg=${commit_msg:-"Code generated for $latest_commit_sha"};

# Default version to `latest`
version=${version:-"latest"}

current_branch_name="${GITHUB_REF##*/}";

# Default branch_prefix to `code`
branch_prefix=${branch_prefix:-"gencode"}
branch_prefix="$branch_prefix-$current_branch_name"