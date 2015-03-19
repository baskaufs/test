xquery version "3.0";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";


let $contentType := "text/html"
let $namespace := "thomas"
let $domain := "http://bioimages.vanderbilt.edu"
let $image := "0140-01-01"
let $iri := concat($domain,"/",$namespace,"/",$image)
return 
  if ($contentType = "text/html")
  then <html>
        <head>
        </head>
        <body>
        </body>
       </html>
  else <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      >
        <description about="{$iri}">
        </description>
       </rdf:RDF>
