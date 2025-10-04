#!/bin/bash

versions=$(grep -rohP '<version>\K[0-9A-Za-z\.\-]+(?=-SNAPSHOT</version>)' --include=pom.xml . | sort -u)

for version in $versions; do
    stable_ver="$version"

    escaped_version=$(printf '%s\n' "$version" | sed -e 's/[]\/$*.^[]/\\&/g')
    escaped_stable=$(printf '%s\n' "$stable_ver" | sed -e 's/[&/]/\\&/g')

    for pom in $(git ls-files | grep pom.xml); do
    	sed -i.bak "s/${escaped_version}-SNAPSHOT/${escaped_stable}/g" "$pom"
    done

    echo "${version}-SNAPSHOT has been replaced with ${stable_ver}"
done

