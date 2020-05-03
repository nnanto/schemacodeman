# Schema-Code Manager

Performs schema specific code generation by maintaining a parallel branch for generated code (evolving with schema).

## Usage

```yaml
- uses: naveenanto22/schemacodeman@v1
  with:
  
    # Comma separated languages for code generation as required by code generator.
    #
    # [ ex: 'js,csharp,python' for proto generator ]
    #
    # required
    
    languages: ''         
    
    
    # Comma separated schema files to be processed. Glob syntax compatible.
    #
    # [ ex: 'schema.json' (or) '*.proto,contract/*.proto' ]
    # 
    # required
    
    schema_files: ''     
    
    
    # Directory to place the generated code. 
    #
    # [ ex: 'generated/' (or) 'com/contract/generated']
    #
    # optional (default :'code/')
    
    codepath: ''          
    
    
    # Shell script that generates the code. `code_generator.sh` can't be used as filename
    # The file can also be a path relative to the workspace
    # See [Code Generator Script](#code-generator-script) for more details
    #
    # [ ex: 'custom_generator.sh' ,  'scripts/my_generator.sh']
    #
    # optional (default : 'code_generator.sh')
    
    code_generator: ''
    
    # Branch prefix name to be used while creating a code_branch per language 
    # format: [ branch name will be {branch_prefix}-{ref_branch_name}/{language} ]
    #
    # [ ex: 'auto-generated' might result in auto-generated-dev/java ]
    #
    # optional (default : 'gencode')
    
    branch_prefix: ''
    
    # Commit message to be used for each code generation. 
    # '_' is used to specify default behaviour or you can choose to ignore this field
    #
    # [ ex: 'Auto-generated code' ]
    #
    # optional (default : 'Code generated for {commit_sha}')
    
    commit_msg: '_'
```

## Code Generator Script 

Shell script that will be called for each schema file per language to generate code. File name `code_generator.sh` is used as default and therefore can't be used for custom script. Custom scripts are sourced into the code.Dec

In addition to the above inputs the script will have access to `schema_file` and `lang` indicating the current schema file and language being processed respectively.

> Make sure to output the generated code to `$codepath`

*Note: All inputs mentioned above including schema_file and lang can also be used locally (`$commit_msg, $codepath, $lang`)*

## Container

Your scripts will run in latest `alpine` environment inside docker. The container is pre-installed with following:

    git
    bash
    curl
    protobuf
    nodejs
    nodejs-npm
    quicktype

## Hooks [ Partial Implementation ]

Create files `pre_process_hook.sh` and `post_process_hook.sh` in the main working directory. These files will be sourced before and after the process respectively.

*Note: Both scripts execute in the branch where push was invoked.*


