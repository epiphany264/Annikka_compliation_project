#!/bin/bash


POM_FILE="pom.xml"


if [ ! -f "$POM_FILE" ]; then
    echo "No pom.xml file found in current directory."
    exit 1
fi


# Backup original pom.xml
cp "$POM_FILE" "${POM_FILE}.bak"


# Replace all http:// with https:// in the context of dependencies and repositories
sed -i 's|<url>http://|<url>https://|g' "$POM_FILE"
sed -i 's|<repositoryUrl>http://|<repositoryUrl>https://|g' "$POM_FILE"
sed -i 's|<connection>http://|<connection>https://|g' "$POM_FILE"
sed -i 's|<developerConnection>http://|<developerConnection>https://|g' "$POM_FILE"
sed -i 's|<distributionManagement>.*http://|<distributionManagement>https://|g' "$POM_FILE"
sed -i 's|http://repo1.maven.org/maven2|https://repo1.maven.org/maven2|g' "$POM_FILE"
sed -i 's|http://|https://|g' "$POM_FILE"  # fallback, more aggressive (can be commented if too broad)


echo "All applicable http:// URLs in $POM_FILE have been replaced with https://"

exit 0
