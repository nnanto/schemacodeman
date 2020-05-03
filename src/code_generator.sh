#!/bin/bash


log_warning "Loading from custom code_generator";

filename_with_extension="${schema_file##*/}";
filename="${filename_with_extension%.*}";
extension="${filename_with_extension##*.}";

if [[ "$extension" == "proto" ]]; then
    protoc "$schema_file" --"${lang}_out"="$codepath";
elif [[ "$extension" == "json" ]]; then
    quicktype "$schema_file" -o "$codepath/$filename.$lang"
else
    log "Unknown extension!";
    exit -1;
fi