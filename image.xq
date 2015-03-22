xquery version "3.0";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace dcterms="http://purl.org/dc/terms/";
(: 
TODO: fix county/parish/borough unit 
:)
(:
*********** Functions *********
:)
declare function local:head-content
($title as xs:string)
{
<meta content="text/html; charset=utf-8" http-equiv="Content-Type" />,
<meta name="viewport" content="width=320, initial-scale=1"/>,
<link rel="icon" type="image/vnd.microsoft.icon" href="../favicon.ico" />,
<link rel="apple-touch-icon" href="../logo.png" />,
<style type="text/css">@import "../composite-adj.css";</style>,
<title>{$title}</title>,
<link rel="meta" type="application/rdf+xml" title="RDF" href="http://bioimages.vanderbilt.edu/baskauf/91164.rdf" />,
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
"}</script>
};

declare function local:rdfa-page-metadata
($id as xs:string)
{
<div resource="{$id}.htm" typeof="foaf:Document WebPage" >
<span property="primaryImageOfPage about" resource="{$id}"/>
<span property="dateModified" content="{fn:current-dateTime()}"/>
</div>
};

declare function local:show-cameo
($dom as xs:string, $ns as xs:string, $img as xs:string)
{
<table border="0" cellspacing="0"><tr><td><a href="../index.htm"><img alt="home button" src="../logo.jpg" width="58" /></a></td><td valign="top"><a href="#" onclick='window.location.replace("../metadata.htm?{$ns}/{$img}/metadata/img");'>&#8239;Enable image database and site navigation</a></td></tr></table>,
<div id="replaceImage"><a property="contentUrl" href="{$dom}/gq/{$ns}/g{$img}.jpg"><img alt="Image {$dom}/gq/{$ns}/g{$img}.jpg" src="{$dom}/lq/{$ns}/w{$img}.jpg" /></a></div>,
<br />
};

declare function local:determination-info
($orgId as xs:string, $xmlDet, $xmlNam, $xmlSen, $xmlAge)
{
for $det in $xmlDet/csv/record,
    $name in $xmlNam/csv/record,
    $sensu in $xmlSen/csv/record,
    $agent in $xmlAge/csv/record
where $det/dsw_identified/text()=$orgId and $name/dcterms_identifier=$det/tsnID and $sensu/dcterms_identifier=$det/nameAccordingToID and $agent/dcterms_identifier=$det/identifiedBy
order by $det/dwc_dateIdentified/text() descending
return (
        <div>
<h2>{
      if ($name/dwc_taxonRank/text() = "species")
             then (<em>{$name/dwc_genus/text()||" "||$name/dwc_specificEpithet/text()}</em>," ("||$name/dwc_vernacularName/text()||")")
             else 
               if ($name/dwc_taxonRank/text() = "genus")
               then (<em>{$name/dwc_genus/text()}</em>," ("||$name/dwc_vernacularName/text(),")")
               else 
                 if ($name/dwc_taxonRank/text() = "subspecies")
                 then (<em>{$name/dwc_genus/text()||" "||$name/dwc_specificEpithet/text()}</em>," ssp. ",<em>{$name/dwc_infraspecificEpithet/text()}</em>, " (", $name/dwc_vernacularName/text(),")")
                 else
                   if ($name/dwc_taxonRank/text() = "variety")
                   then (<em>{$name/dwc_genus/text()||" "||$name/dwc_specificEpithet/text()}</em>," var. ",<em>{$name/dwc_infraspecificEpithet/text()}</em>, " (", $name/dwc_vernacularName/text(),")")
                   else ()
          }</h2>&#32;<h3>{$name/dwc_scientificNameAuthorship/text()}</h3>&#32;<h6>sec. {$sensu/tcsSignature/text()}</h6>
<br/>
common name: {$name/dwc_vernacularName/text()}<br/>
family: {$name/dwc_family/text()}<br/>
<h6><em>Identified </em>{$det/dwc_dateIdentified/text()}<em> by </em> <a href="{$agent/contactURL/text()}">{$agent/dc_contributor/text()}</a></h6><br/><br/>
        </div>
        )
};

declare function local:identifier-info
($dom as xs:string, $ns as xs:string, $img as xs:string)
{
<h5><em>Refer to this permanent identifier for the image:</em><br/>
<strong property="dcterms:identifier">{$dom}/{$ns}/{$img}</strong><br/><br/>
<em>Use this URL as a stable link to this image page:</em><br/><a href="{$img}.htm">{$dom}/{$ns}/{$img}.htm</a></h5>,
<br/>,
<br/>
};

declare function local:location-info
($record)
{
<h5><em>Location information for the occurrence documented by this image:</em></h5>,
<br/>,
<span property="contentLocation" resource="{$record/dcterms_identifier/text()}#loc" typeof="dcterms:Location Place">
{$record/dwc_locality/text()}, {$record/dwc_county/text()} County, 
{$record/dwc_state/text()}, {$record/dwc_countryCode/text()}<br/>
<a property="geo" typeof="GeoCoordinates" target="top" href="http://maps.google.com/maps?output=classic&amp;q=loc:{$record/dwc_decimalLatitude/text()},{$record/dwc_decimalLongitude/text()}&amp;t=h&amp;z=16">
<span property="latitude">{$record/dwc_decimalLatitude/text()}</span>&#176; latitude,<span property="longitude">{$record/dwc_decimalLongitude/text()}</span>&#176; longitude</a>
</span>,
<h5>Coordinate uncertainty: about {$record/dwc_coordinateUncertaintyInMeters/text()} m</h5>,
<br/>,
<h6>{$record/dwc_georeferenceRemarks/text()}</h6>,
<br/>,
<br/>
};

declare function local:related-resources-info
($orgId as xs:string)
{
<h5><em>This image documents the organism which has the permanent identifier:</em></h5>,
<br/>,
<h6><strong property="about" typeof="dcterms:PhysicalResource" resource="{$orgId}">{$orgId}</strong></h6>,
<br/>,
<br/>,
<h5><em>Follow this link for additional images of the organism:</em><br/>
<a target="top" href="{$orgId}.htm">{$orgId}.htm</a></h5>,
<br/>,
<br/>
};

declare function local:intellectual-property-info
($dom as xs:string, $ns as xs:string,$img as xs:string,$record, $xmlAge,$license)
{
for $agent in $xmlAge/csv/record
where $agent/dcterms_identifier=$record/photographerCode
return (
<h5><em>Intellectual property information about this image:</em></h5>,
<br/>,
<h6><em>Image creator: </em><a property="dcterms:creator creator" href="{$agent/contactURL/text()}" typeof="foaf:{$agent/type/text()} {$agent/type/text()}">
<span property="foaf:name">{$agent/dc_contributor/text()}</span></a>; <em>created on </em>
  <span property="dcterms:created dateCreated">{$record/dcterms_created/text()}</span><br/><br/></h6>
      ),

<h6><em>Rights statement: </em><span property="http://purl.org/dc/elements/1.1/rights">{$record/dc_rights/text()}</span><br/>
<a target="top" property="cc:license" href="{$license[@id=$record/usageTermsIndex/text()]/IRI/text()}" >{$license[@id=$record/usageTermsIndex/text()]/string/text()}<br/><img alt="license logo" src="{$license[@id=$record/usageTermsIndex/text()]/thumb/text()}"/></a><br/></h6>,

for $agent in $xmlAge/csv/record
where $agent/dcterms_identifier=$record/owner
return (
<h6>
<div property="provider" resource="http://biocol.org/urn:lsid:biocol.org:col:35115" typeof="Organization"><span property="name" content="Bioimages"></span><span property="URL" content="http://bioimages.vanderbilt.edu/"></span></div>
<div property="thumbnail" resource="{$dom}/{$ns}/{$img}#tn" typeof="ImageObject"><span property="contentUrl" content="{$dom}/tn/{$ns}/t{$img}.jpg"></span></div>
<em>To cite this image, using the following credit line:</em><br/>
"{$record/photoshop_Credit/text()}" <em>If possible, link to the stable URL for this page.</em><br/><a target="top" href="{$agent/contactURL/text()}">Click this link for contact information about using this image</a><br/><br/>
</h6>
    )
};

declare function local:reference-info
($record, $xmlDet, $xmlSen)
{
<h5><em>Metadata last modified: </em>{$record/dcterms_modified/text()}<br/>
<a target="top" href="{$record/dcterms_identifier/text()}.rdf">RDF formatted metadata for this image</a><br/><br/></h5>,

for $det in $xmlDet/csv/record,
    $sensu in $xmlSen/csv/record
where $det/dsw_identified/text()=$record/foaf_depicts/text() and $sensu/dcterms_identifier=$det/nameAccordingToID
order by lower-case($sensu/tcsSignature/text())
return (
<h6>{$sensu/tcsSignature/text()} =<br/>{$sensu/dc_creator/text()}, {$sensu/dcterms_created/text()}. {$sensu/dcterms_title/text()}. {$sensu/dc_publisher/text()}. <br/></h6>
      ),
<br/>
};

declare function local:browser-optimize-script
($dom as xs:string, $ns as xs:string,$img as xs:string)
{
<script type="text/javascript">{"
document.getElementById('paste').setAttribute('class', browser); // set css for browser type
notPortableDevice=((screen.availWidth > 500) || (screen.availHeight > 500));  //enable highres image for big screen
if (notPortableDevice)
 {
 document.getElementById('replaceImage').innerHTML='<img alt=&quot;"||$dom||"/"||$ns||"/"||$img||"&quot; src=&quot;"||$dom||"/gq/"||$ns||"/g"||$img||".jpg&quot; />'; }
"}</script>
};

declare function local:google-analytics-ping
()
{
<script type="text/javascript">{"
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-45642729-1', 'vanderbilt.edu');
  ga('send', 'pageview');
"}</script>
};


(:
*********** Get data from GitHub *********
:)
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

let $licenseDoc := fn:doc('https://raw.githubusercontent.com/baskaufs/Bioimages/master/license.xml')
let $licenseCategory := $licenseDoc/license/category

(:
*********** Main Query *********
:)
let $contentType := "text/html"
let $namespace := "thomas"
let $domain := "http://bioimages.vanderbilt.edu"
let $image := "0140-01-01"
let $iri := concat($domain,"/",$namespace,"/",$image)

for $imageRecord in $xmlImages/csv/record
where $imageRecord/dcterms_identifier=$iri

return 
  if ($contentType = "text/html")
  then ('<?xml version="1.0" encoding="UTF-8"?>',
      '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.1//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-2.dtd">',
      <html>
        <head>
          {local:head-content($imageRecord/dcterms_title/text())}
        </head>
        <body vocab="http://schema.org/" prefix="dcterms: http://purl.org/dc/terms/ foaf: http://xmlns.com/foaf/0.1/ dcmitype: http://purl.org/dc/dcmitype/ cc: http://creativecommons.org/ns#">
          {local:rdfa-page-metadata($imageRecord/dcterms_identifier/text())}
          <div id="paste" resource="{$imageRecord/dcterms_identifier/text()}" typeof="dcmitype:StillImage ImageObject">
            {local:show-cameo($domain, $namespace, $image)}
            {
            for $orgRecord in $xmlOrganisms/csv/record
            where $orgRecord/dcterms_identifier/text() = $imageRecord/foaf_depicts/text()
            return local:determination-info($imageRecord/foaf_depicts/text(), $xmlDeterminations, $xmlNames, $xmlSensu, $xmlAgents)
            }
            {local:identifier-info($domain, $namespace, $image)}
            {local:location-info($imageRecord)}
            {local:related-resources-info($imageRecord/foaf_depicts/text())}
            {local:intellectual-property-info($domain, $namespace, $image, $imageRecord, $xmlAgents, $licenseCategory)}
            {local:reference-info($imageRecord, $xmlDeterminations, $xmlSensu)}
          </div>
          {local:browser-optimize-script($domain, $namespace, $image)}
          {local:google-analytics-ping()}
        </body>
       </html>)
       
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
