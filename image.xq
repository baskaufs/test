xquery version "3.0";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace dcterms="http://purl.org/dc/terms/";

let $contentType := "text/html"
let $namespace := "thomas"
let $domain := "http://bioimages.vanderbilt.edu"
let $image := "0140-01-01"
let $iri := concat($domain,"/",$namespace,"/",$image)
return 
  if ($contentType = "text/html")
  then <html>
        <head>
          <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
<meta name="viewport" content="width=320, initial-scale=1">
<link rel="icon" type="image/vnd.microsoft.icon" href="../favicon.ico" />
<link rel="apple-touch-icon" href="../logo.png" />
<style type="text/css">
@import "../composite-adj.css";
</style>

        </head>
        <body>
        </body>
       </html>
       
  else <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      >
        <rdf:Description about="{$iri}">
          <rdf:type rdf:resource ="http://purl.org/dc/dcmitype/StillImage" />
          <dc:type>StillImage</dc:type>
          <dcterms:type rdf:resource ="http://purl.org/dc/dcmitype/StillImage" />
          <dcterms:identifier>{$iri}</dcterms:identifier>

        </rdf:Description>
        <rdf:Description about="{$iri}.rdf">
          <rdf:type rdf:resource ="http://xmlns.com/foaf/0.1/Document" />
          <dc:format>application/rdf+xml</dc:format>
          <dcterms:identifier>{$iri}.rdf</dcterms:identifier>

        </rdf:Description>
       </rdf:RDF>
