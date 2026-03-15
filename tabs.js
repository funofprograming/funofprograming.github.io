export function tabber(content, tabId, tabHeaders) {
    
    let tabHeadersMap = new Map(Object.entries(tabHeaders))
    let out = `
    <div>
    <is-land on:visible on:idle>
        <script type='text/javascript'>
            $( function() {
                $( '#${tabId}' ).tabs();
            } );
        </script>
        <div id='${tabId}'>
            <ul>
    `
    for (let [key, value] of tabHeadersMap) {
        out = out + `
                <li><a href='#${key}'>${value}</a></li>
                `
    }

    out = out + `
            </ul>
            ${content}
        </div>
    </is-land>
    </div>
    `
    return out
}

export function tab(content, tabId) {

    let out = `
        <div id='${tabId}'>
            ${content}
        </div>
    `
    return out
}