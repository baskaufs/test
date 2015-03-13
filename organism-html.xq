xquery version "3.0";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace dwc="http://rs.tdwg.org/dwc/terms/";
declare namespace dwciri="http://rs.tdwg.org/dwc/iri/";
declare namespace dsw="http://purl.org/dsw/";
declare namespace xmp="http://ns.adobe.com/xap/1.0/";
declare namespace foaf="http://xmlns.com/foaf/0.1/";
declare namespace tc="http://rs.tdwg.org/ontology/voc/TaxonConcept#";
declare namespace txn="http://lod.taxonconcept.org/ontology/txn.owl#";
declare namespace geo="http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace blocal="http://bioimages.vanderbilt.edu/rdf/local#";

declare function local:substring-after-last
($string as xs:string?, $delim as xs:string) as xs:string?
{
  if (contains($string, $delim))
  then local:substring-after-last(substring-after($string, $delim),$delim)
  else $string
};

declare function local:get-taxon-name-markup
($det as element()+,$name as element()+,$sensu as element()+,$orgID as xs:string)
{
   for $detRecord in $det,
    $nameRecord in $name,
    $sensuRecord in $sensu
  where $detRecord/dsw_identified=$orgID and $nameRecord/dcterms_identifier=$detRecord/tsnID and $sensuRecord/dcterms_identifier=$detRecord/nameAccordingToID
  let $organismScreen := $detRecord/dsw_identified/text()
  group by $organismScreen
  return if ($nameRecord[1]/dwc_taxonRank/text() = "species")
         then (<em>{$nameRecord[1]/dwc_genus/text()||" "||$nameRecord[1]/dwc_specificEpithet/text()}</em>," ("||$nameRecord[1]/dwc_vernacularName/text()||")")
         else 
           if ($nameRecord[1]/dwc_taxonRank/text() = "genus")
           then (<em>{$nameRecord[1]/dwc_genus/text()}</em>," ("||$nameRecord[1]/dwc_vernacularName/text(),")")
           else 
             if ($nameRecord[1]/dwc_taxonRank/text() = "subspecies")
             then (<em>{$nameRecord[1]/dwc_genus/text()||" "||$nameRecord[1]/dwc_specificEpithet/text()}</em>," ssp. ",<em>{$nameRecord/dwc_infraspecificEpithet/text()}</em>, " (", $nameRecord[1]/dwc_vernacularName/text(),")")
             else
               if ($nameRecord[1]/dwc_taxonRank/text() = "variety")
               then (<em>{$nameRecord[1]/dwc_genus/text()||" "||$nameRecord[1]/dwc_specificEpithet/text()}</em>," var. ",<em>{$nameRecord[1]/dwc_infraspecificEpithet/text()}</em>, " (", $nameRecord[1]/dwc_vernacularName/text(),")")
               else ()
};

declare function local:get-taxon-name-clean
($det as element()+,$name as element()+,$sensu as element()+,$orgID as xs:string)
{
   for $detRecord in $det,
    $nameRecord in $name,
    $sensuRecord in $sensu
  where $detRecord/dsw_identified=$orgID and $nameRecord/dcterms_identifier=$detRecord/tsnID and $sensuRecord/dcterms_identifier=$detRecord/nameAccordingToID
  let $organismScreen := $detRecord/dsw_identified/text()
  group by $organismScreen
  return if ($nameRecord[1]/dwc_taxonRank/text() = "species")
         then ($nameRecord[1]/dwc_genus/text()||" "||$nameRecord[1]/dwc_specificEpithet/text()||" ("||$nameRecord[1]/dwc_vernacularName/text()||")")
         else 
           if ($nameRecord[1]/dwc_taxonRank/text() = "genus")
           then ($nameRecord[1]/dwc_genus/text()||" ("||$nameRecord[1]/dwc_vernacularName/text(),")")
           else 
             if ($nameRecord[1]/dwc_taxonRank/text() = "subspecies")
             then ($nameRecord[1]/dwc_genus/text()||" "||$nameRecord[1]/dwc_specificEpithet/text()||" ssp. "||$nameRecord/dwc_infraspecificEpithet/text()||" (", $nameRecord[1]/dwc_vernacularName/text(),")")
             else
               if ($nameRecord[1]/dwc_taxonRank/text() = "variety")
               then ($nameRecord[1]/dwc_genus/text()||" "||$nameRecord[1]/dwc_specificEpithet/text()||" var. "||$nameRecord[1]/dwc_infraspecificEpithet/text()||" (", $nameRecord[1]/dwc_vernacularName/text(),")")
               else ()
};

let $localFilesFolderUnix := "c:/test"

(: Create root folder if it doesn't already exist. :)
let $rootPath := "c:\test"
(: "file:create-dir($dir as xs:string) as empty-sequence()" will create a directory or do nothing if it already exists :)
let $nothing := file:create-dir($rootPath)

(: Uses http:send-request to fetch CSV files from GitHub :)
(: BaseX 8.0 requires 'map' keyword) before key/value maps :)
(: Older versions of BaseX may not have this requirement :)

(:let $textOrganisms := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/organisms.csv'/>)[2]:)
let $textOrganisms := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/organisms-small.csv'/>)[2]
let $xmlOrganisms := csv:parse($textOrganisms, map { 'header' : true() })
(: When we implement Ken's output with pipe ("|") separators, the parse function will have to change to this:
let $xmlOrganisms := csv:parse($textOrganisms, map { 'header' : true(),'separator' : "|" })
:)

(:let $textDeterminations := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/determinations.csv'/>)[2]:)
let $textDeterminations := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/determinations-small.csv'/>)[2]
let $xmlDeterminations := csv:parse($textDeterminations, map { 'header' : true() })

(:let $textNames := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/names.csv'/>)[2]:)
let $textNames := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/names-small.csv'/>)[2]
let $xmlNames := csv:parse($textNames, map { 'header' : true() })

(:let $textSensu := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/sensu.csv'/>)[2]:)
let $textSensu := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/sensu-small.csv'/>)[2]
let $xmlSensu := csv:parse($textSensu, map { 'header' : true() })

(:let $textImages := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/images.csv'/>)[2]:)
let $textImages := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/images-small.csv'/>)[2]
let $xmlImages := csv:parse($textImages, map { 'header' : true() })

(:let $textAgents := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/agents.csv'/>)[2]:)
let $textAgents := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/agents-small.csv'/>)[2]
let $xmlAgents := csv:parse($textAgents, map { 'header' : true() })

let $textLinks := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/links.csv'/>)[2]
let $xmlLinks := csv:parse($textLinks, map { 'header' : true() })

let $lastPublishedDoc := fn:doc(concat('file:///',$localFilesFolderUnix,'/last-published.xml'))
let $lastPublished := $lastPublishedDoc/body/dcterms:modified/text()

let $organismsToWriteDoc := file:read-text(concat('file:///',$localFilesFolderUnix,'/organisms-to-write.txt'))
let $xmlOrganismsToWrite := csv:parse($organismsToWriteDoc, map { 'header' : false() })

for $orgRecord in $xmlOrganisms/csv/record, $organismsToWrite in distinct-values($xmlOrganismsToWrite/csv/record/entry)
where $orgRecord/dcterms_identifier/text() = $organismsToWrite
let $taxonNameClean := local:get-taxon-name-clean($xmlDeterminations/csv/record,$xmlNames/csv/record,$xmlSensu/csv/record,$orgRecord/dcterms_identifier/text() )
let $taxonNameMarkup := local:get-taxon-name-markup($xmlDeterminations/csv/record,$xmlNames/csv/record,$xmlSensu/csv/record,$orgRecord/dcterms_identifier/text() )
let $fileName := local:substring-after-last($orgRecord/dcterms_identifier/text(),"/")
let $temp := substring-before($orgRecord/dcterms_identifier/text(),concat("/",$fileName))
let $namespace := local:substring-after-last($temp,"/")
let $filePath := concat($rootPath,"\", $namespace,"\", $fileName,".htm")
let $tempQuoted1 := '"Image of organism" title="Image of organism" src="'
let $tempQuoted2 := '" height="'
let $tempQuoted3 := '"/>'
let $googleMapString := "http://maps.google.com/maps?output=classic&amp;q=loc:"||$orgRecord/dwc_decimalLatitude/text()||","||$orgRecord/dwc_decimalLongitude/text()||"&amp;t=h&amp;z=16"
let $qrCodeString := "http://chart.apis.google.com/chart?chs=100x100&amp;cht=qr&amp;chld=|1&amp;chl=http%3A%2F%2Fbioimages.vanderbilt.edu%2F"||$namespace||"%2F"||$fileName||".htm"
let $loadDatabaseString := 'window.location.replace("../metadata.htm?'||$namespace||'/'||$fileName||'/metadata/ind");'
return (file:create-dir(concat($rootPath,"\",$namespace)), file:write($filePath,
<html>{
  <head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <meta name="viewport" content="width=320, initial-scale=1" />
    <link rel="icon" type="image/vnd.microsoft.icon" href="../favicon.ico" />
    <link rel="apple-touch-icon" href="../logo.png" />
    <style type="text/css">
    {'@import "../composite-adj.css";'}
    </style>
    <title>An individual of {$taxonNameClean}</title>
    <link rel="meta" type="application/rdf+xml" title="RDF" href="http://bioimages.vanderbilt.edu/kaufmannm/ke129.rdf" />
    <script type="text/javascript">{"
      // Determine if the device is an iPhone, iPad, or a regular browser
      if (navigator.userAgent.indexOf('iPad')!=-1)
       {browser='iPad';}
      else
       {
       if (navigator.userAgent.indexOf('iPhone')!=-1)
         {browser='iPhone';}
       else
         {browser='computer';}
       }
    "}
    </script>
  </head>,
  <body vocab="http://schema.org/" prefix="dcterms: http://purl.org/dc/terms/ foaf: http://xmlns.com/foaf/0.1/">{
    <div resource="{$orgRecord/dcterms_identifier/text()||'.htm'}" typeof="foaf:Document WebPage" >
      <span property="about" resource="{$orgRecord/dcterms_identifier/text()}"></span>
      <span property="dateModified" content="{fn:current-dateTime()}"></span>
    </div>,
    (: !!!!!!!!!!! TODO: need to implement buttons here !!!!!!!!!!!!!! :)
    <div id="paste" resource="{$orgRecord/dcterms_identifier/text()}" typeof="dcterms:PhysicalResource">{
      <table>
        <tr>
          <td>
            <a href="../vanderbilt/12-126.htm">
              <img alt="previous button" src="../buttons/peabody-last.png" height="58" />
            </a>
          </td>
          <td>
            <a href="http://vanderbilt.edu/trees/">
              <img alt="tour home button" src="../contact/vanderbilt-logo.png" height="58" />
            </a>
          </td>
          <td>
            <a href="http://vanderbilt.edu/trees/tours/main-campus">
              <img alt="tour page button" src="../buttons/main-tour.png" height="58" />
            </a>
          </td>
          <td>
            <a href="../vanderbilt/11-23.htm"><img alt="next button" src="../buttons/main-next.png" height="58" /></a>
          </td>
        </tr>
      </table>,
      <br/>,
      <span>An individual of {$taxonNameMarkup}</span>,
      <br/>,
      
      <a href="../baskauf/90694.htm"><span id="orgimage"><img alt="Image of organism" title="Image of organism" src="../lq/baskauf/w90694.jpg" /></span></a>,
      <br/>,
(: TODO: This is escaping the lt and gt in the javascript :)      
      <script type="text/javascript">{"
if (document.documentElement.clientWidth<400)
     {
imgHeight=document.documentElement.clientHeight-100;
if (imgHeight>480)
          {
          imgHeight=480;
          }
document.getElementById('orgimage').innerHTML='<img alt="||$tempQuoted1||"../lq/baskauf/w90694.jpg"||$tempQuoted2||"'+imgHeight+'"||$tempQuoted3||"';
     }
"}
      </script>,

      <h5>Permanent identifier for the individual:</h5>,
      <br/>,
      <h5><strong property="dcterms:identifier">{$orgRecord/dcterms_identifier/text()}</strong></h5>,
      <br/>,
      <br/>,
      <table>
        <tr>
          <td><a href="../index.htm"><img alt="home button" src="../logo.jpg" height="88" /></a></td>
          <td><a target="top" href="{$googleMapString}"><img alt="FindMe button" src="../findme-button.jpg" height="88" /></a></td>
          <td><img src="{$qrCodeString}" alt="QR Code" /></td>
        </tr>
      </table>,
      <br/>,
(: TODO: it's also escaping the quotes here :)
      <h5><a href="#" onclick='{$loadDatabaseString}'>&#8239;Load database and switch to thumbnail view</a>
      </h5>,
      <br/>,
      <br/>,
      <h5>
        <em>Use this URL as a stable link to this page:</em>
        <br/>
        <a href="{$fileName||'.htm'}">http://bioimages.vanderbilt.edu/{$namespace}/{$fileName}.htm</a>
      </h5>,
      <br/>,
      <br/>,
      if ($orgRecord/dwc_collectionCode/text() != "")
      then (
           for $agent in $xmlAgents/csv/record
           where $agent/dcterms_identifier=$orgRecord/dwc_collectionCode
           return (<h5>This individual is a living specimen that is part of the&#8239;
           <a href="{$agent/contactURL/text()}">{$agent/dc_contributor/text()}</a>
           &#8239;with the local identifier {$orgRecord/dwc_catalogNumber/text()}.</h5>,<br/>,
              <br/>)
           )
      else (),

      <h5><em>This particular individual is believed to be </em><strong>{$orgRecord/dwc_establishmentMeans/text()}</strong>.</h5>,
      <br/>,
      <br/>,
      <h3><strong>Identifications:</strong></h3>,
      <br/>,
      for $detRecord in $xmlDeterminations/csv/record,
          $nameRecord in $xmlNames/csv/record,
          $sensuRecord in $xmlSensu/csv/record
      where $detRecord/dsw_identified=$orgRecord/dcterms_identifier and $nameRecord/dcterms_identifier=$detRecord/tsnID and $sensuRecord/dcterms_identifier=$detRecord/nameAccordingToID
      return (
      <h2>{
      if ($nameRecord/dwc_taxonRank/text() = "species")
             then (<em>{$nameRecord/dwc_genus/text()||" "||$nameRecord/dwc_specificEpithet/text()}</em>," ("||$nameRecord/dwc_vernacularName/text()||")")
             else 
               if ($nameRecord[1]/dwc_taxonRank/text() = "genus")
               then (<em>{$nameRecord/dwc_genus/text()}</em>," ("||$nameRecord/dwc_vernacularName/text(),")")
               else 
                 if ($nameRecord/dwc_taxonRank/text() = "subspecies")
                 then (<em>{$nameRecord/dwc_genus/text()||" "||$nameRecord/dwc_specificEpithet/text()}</em>," ssp. ",<em>{$nameRecord/dwc_infraspecificEpithet/text()}</em>, " (", $nameRecord/dwc_vernacularName/text(),")")
                 else
                   if ($nameRecord/dwc_taxonRank/text() = "variety")
                   then (<em>{$nameRecord/dwc_genus/text()||" "||$nameRecord/dwc_specificEpithet/text()}</em>," var. ",<em>{$nameRecord/dwc_infraspecificEpithet/text()}</em>, " (", $nameRecord/dwc_vernacularName/text(),")")
                   else ()
        }</h2>,
        <span> </span>,
        <h3>{$nameRecord/dwc_scientificNameAuthorship/text()}</h3>,
        <h6>sec. {$sensuRecord/tcsSignature/text()}</h6>,
        <br/>,
        <span>common name: {$nameRecord/dwc_vernacularName/text()}</span>,
        <br/>,
        <span>family: {$nameRecord/dwc_family/text()}</span>,
        <br/>,
        <h6>{
          <em>Identified </em>,
          <span>{$detRecord/dwc_dateIdentified/text()}</span>,
          <em> by </em>,
          <a href="{$agentRecord/contactURL/text()}">{$agentRecord/dc_contributor/text()}</a>
        }</h6>,
        <br/>,
        <br/>
      )
    }</div>
  }</body>
}</html>
       )),
let $localFilesFolderPC := "c:\test"
let $lastPublished := fn:current-dateTime()
return (file:write(concat($localFilesFolderPC,"\last-published.xml"),
<body>
<dcterms:modified>{$lastPublished}</dcterms:modified>
</body>
))
