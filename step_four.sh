#!/bin/bash


find . -name "pom.xml" -type f | while read -r POM_FILE; do

    cp "$POM_FILE" "${POM_FILE}.bak"

    sed -i 's|<url>http://|<url>https://|g' "$POM_FILE"
    sed -i 's|<repositoryUrl>http://|<repositoryUrl>https://|g' "$POM_FILE"
    sed -i 's|<connection>http://|<connection>https://|g' "$POM_FILE"
    sed -i 's|<developerConnection>http://|<developerConnection>https://|g' "$POM_FILE"
    sed -i 's|http://repo1.maven.org/maven2|https://repo1.maven.org/maven2|g' "$POM_FILE"
    sed -i 's|http://|https://|g' "$POM_FILE" 
done


echo "All applicable http:// URLs in pom.xml files have been replaced with https://"


exit 0

