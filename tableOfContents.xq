xquery version "3.0";

<html>{
  <head>{
    <title>{"Fleur du Mal index"}</title>
  }</head>,
  <body>{
    let $raw := fn:doc('https://raw.githubusercontent.com/EdWarga/corpus-baudelaire/master/Misc/PoemsList.xml')
    let $poem := $raw/poems/poem
    for $sectionTitle in distinct-values($poem/Section1857)
    where $sectionTitle != "nope"
    return (<h3>{$sectionTitle}</h3>,
    <ul style="list-style-type:none">{
        let $raw := fn:doc('https://raw.githubusercontent.com/EdWarga/corpus-baudelaire/master/Misc/PoemsList.xml')
        for $poem in $raw/poems/poem
        where $poem/Section1857/text() = $sectionTitle
        order by xs:integer($poem/Ed1857/text())
        return <li>{$poem/Ed1857/text()||"  "||$poem/PoemTitle/text()}</li>
    }</ul>,
    <br/>)
  }</body>
}</html>