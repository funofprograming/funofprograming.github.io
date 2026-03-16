#!/bin/bash

sudo apt install yq

YAML_FILE=$GITHUB_WORKSPACE/api-docs-config.yaml
MAVEN_BASE_URL=https://repo1.maven.org/maven2
API_DOCS_PATH=$GITHUB_WORKSPACE/_site/apidocs

rm -rf $API_DOCS_PATH/*

len=$(yq '.docs | length' $YAML_FILE)

echo "Total docs config found:$len"

for ((i=0; i<len; i++)); do
    
    cd $GITHUB_WORKSPACE
    repo=$(yq -r ".docs[$i].repo" $YAML_FILE)
    groupId=$(yq -r ".docs[$i].groupId" $YAML_FILE)
    artifactId=$(yq -r ".docs[$i].artifactId" $YAML_FILE)
    version=$(yq -r ".docs[$i].version" $YAML_FILE)
    javadoc=$(yq -r ".docs[$i].javadoc" $YAML_FILE)
    dokka=$(yq -r ".docs[$i].dokka" $YAML_FILE)
    
    if [[ "$javadoc" == "true" ]]; then
        javadocloc=$API_DOCS_PATH/$repo/javadoc/$version/
        javadocfile=$artifactId-$version-javadoc.jar
        mavenUrl="$MAVEN_BASE_URL/$(echo "$groupId" | sed 's/\./\//g')/$artifactId/$version/$javadocfile"
        echo "Setting up Javadoc from URL: $mavenUrl in location: $javadocloc"
        mkdir -p $javadocloc
        cd $javadocloc
        wget -q $mavenUrl
        unzip -qq $javadocfile
        rm -rf $javadocfile
        rm -rf META-INF
    fi

    if [[ "$dokka" == "true" ]]; then
        dokkaloc=$API_DOCS_PATH/$repo/dokka/$version/
        dokkafile=$artifactId-$version-dokka.jar
        mavenUrl="$MAVEN_BASE_URL/$(echo "$groupId" | sed 's/\./\//g')/$artifactId/$version/$dokkafile"
        echo "Setting up Kotlindoc from URL: $mavenUrl in location: $dokkaloc"
        mkdir -p $dokkaloc
        cd $dokkaloc
        wget -q $mavenUrl
        unzip -qq $dokkafile
        rm -rf $dokkafile
        rm -rf META-INF
    fi
done