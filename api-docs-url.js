import yaml from "js-yaml"
import fs from "fs"
import isUndefined from "is-undefined"

const apiDocsConfigFile="api-docs-config.yaml"

export function apidocurl(docId, docType, docLabel) {

    const fileContents = fs.readFileSync(apiDocsConfigFile, 'utf8');
    const config = yaml.load(fileContents);
    const doc = config.docs.find(doc => doc.id.toLowerCase() === docId.toLowerCase());
    const docuType = docType.toLowerCase() === 'kotlin' ? "dokka" : (docType.toLowerCase() === 'java' ? "javadoc" : null)
    const url = "/apidocs/"+doc.repo+"/"+docuType+"/"+doc.version+"/index.html"
    const docLabelToUse = !isUndefined(docLabel) ? docLabel : (docType.toLowerCase() === 'kotlin' ? "Kotlin Docs" : (docType.toLowerCase() === 'java' ? "Java Docs" : null))
    return '<a href="'+url+'" target="_blank">'+docLabelToUse+'</a>'
}