#!/bin/bash

wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq && chmod +x /usr/local/bin/yq

YAML_FILE=api-docs-config.yaml
MAVEN_BASE_URL=https://repo1.maven.org/maven2

len=$(yq '.docs | length' $YAML_FILE)
for ((i=0; i<len; i++)); do
    
    repo=$(yq ".docs[$i].repo" $YAML_FILE)
    groupId=$(yq ".docs[$i].group-id" $YAML_FILE)
    artifactId=$(yq ".docs[$i].artifact-id" $YAML_FILE)
    version=$(yq ".docs[$i].version" $YAML_FILE)
    javadoc=$(yq ".docs[$i].version" $YAML_FILE)
    dokka=$(yq ".docs[$i].version" $YAML_FILE)
    
    if [[ "$javadoc" == "true" ]]; then
        javadocloc=./_site/apidocs/$repo/javadoc/$version/
        javadocfile=$artifactId-$version-javadoc.jar
        mavenUrl="$MAVEN_BASE_URL/$(echo "$groupId" | sed 's/\./\//g')/$artifactId/$version/$javadocfile"
        mkdir -p $javadocloc
        cd $javadocloc
        wget $mavenUrl
        unzip $javadocfile
        rm -rf $javadocfile
        rm -rf META-INF
    fi

    if [[ "$dokka" == "true" ]]; then
        dokkaloc=./_site/apidocs/$repo/dokka/$version/
        dokkafile=$artifactId-$version-dokka.jar
        mavenUrl="$MAVEN_BASE_URL/$(echo "$groupId" | sed 's/\./\//g')/$artifactId/$version/$dokkafile"
        mkdir -p $dokkaloc
        cd $dokkaloc
        wget $mavenUrl
        unzip $dokkafile
        rm -rf $dokkafile
        rm -rf META-INF
    fi


done