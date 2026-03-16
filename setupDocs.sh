#!/bin/bash

sudo apt install yq -y

YAML_FILE=api-docs-config.yaml
MAVEN_BASE_URL=https://repo1.maven.org/maven2

len=$(yq '.docs | length' $YAML_FILE)

echo "Total docs config found:$len"

for ((i=0; i<len; i++)); do
    
    repo=$(yq ".docs[$i].repo" $YAML_FILE)
    groupId=$(yq ".docs[$i].group-id" $YAML_FILE)
    artifactId=$(yq ".docs[$i].artifact-id" $YAML_FILE)
    version=$(yq ".docs[$i].version" $YAML_FILE)
    javadoc=$(yq ".docs[$i].version" $YAML_FILE)
    dokka=$(yq ".docs[$i].version" $YAML_FILE)
    
    cd $GITHUB_WORKSPACE

    if [[ "$javadoc" == "true" ]]; then
        javadocloc=$GITHUB_WORKSPACE/_site/apidocs/$repo/javadoc/$version/
        javadocfile=$artifactId-$version-javadoc.jar
        mavenUrl="$MAVEN_BASE_URL/$(echo "$groupId" | sed 's/\./\//g')/$artifactId/$version/$javadocfile"
        echo "Setting up Javadoc from URL:$mavenUrl in location $javadocloc"
        mkdir -p $javadocloc
        cd $javadocloc
        wget $mavenUrl
        unzip $javadocfile
        rm -rf $javadocfile
        rm -rf META-INF
    fi

    if [[ "$dokka" == "true" ]]; then
        dokkaloc=$GITHUB_WORKSPACE/_site/apidocs/$repo/dokka/$version/
        dokkafile=$artifactId-$version-dokka.jar
        mavenUrl="$MAVEN_BASE_URL/$(echo "$groupId" | sed 's/\./\//g')/$artifactId/$version/$dokkafile"
        echo "Setting up Kotlindoc from URL:$mavenUrl in location $dokkaloc"
        mkdir -p $dokkaloc
        cd $dokkaloc
        wget $mavenUrl
        unzip $dokkafile
        rm -rf $dokkafile
        rm -rf META-INF
    fi


done