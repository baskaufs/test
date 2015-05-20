xquery version "3.0";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace dwc="http://rs.tdwg.org/dwc/terms/";
declare namespace xmp="http://ns.adobe.com/xap/1.0/";
declare namespace xmpRights="http://ns.adobe.com/xap/1.0/rights/";
declare namespace dsw="http://purl.org/dsw/";
declare namespace ac="http://rs.tdwg.org/ac/terms/";
declare namespace photoshop="http://ns.adobe.com/photoshop/1.0/";
declare namespace cc="http://creativecommons.org/ns#";
declare namespace xhv="http://www.w3.org/1999/xhtml/vocab#";
declare namespace mbank="http://www.morphbank.net/schema/morphbank#";
declare namespace exif="http://ns.adobe.com/exif/1.0/";
declare namespace Iptc4xmpExt="http://iptc.org/std/Iptc4xmpExt/2008-02-29/";
declare namespace foaf="http://xmlns.com/foaf/0.1/";
declare namespace geo="http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace blocal="http://bioimages.vanderbilt.edu/rdf/local#";
(:
*********** Functions *********
:)
declare function local:substring-after-last
($string as xs:string?, $delim as xs:string) as xs:string?
{
  if (contains($string, $delim))
  then local:substring-after-last(substring-after($string, $delim),$delim)
  else $string
};

declare function local:rdf-basic-information
($id as xs:string, $ns as xs:string, $img as xs:string, $record, $xmlAge)
{
<rdf:type rdf:resource ="http://purl.org/dc/dcmitype/StillImage" />,
<dc:type>StillImage</dc:type>,
<dcterms:type rdf:resource ="http://purl.org/dc/dcmitype/StillImage" />,
<dcterms:identifier>{$id}</dcterms:identifier>,
<xmp:MetadataDate rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">{$record/dcterms_modified/text()}</xmp:MetadataDate>,

for $agent in $xmlAge//record
where $agent/dcterms_identifier=$record/photographerCode
return (
<dc:creator>{$agent/dc_contributor/text()}</dc:creator>,
<dcterms:creator rdf:resource="{$agent/iri/text()}"/>
    ),
    
<dcterms:created>{$record/dcterms_created/text()}</dcterms:created>,
<ac:providerLiteral>Bioimages http://bioimages.vanderbilt.edu/</ac:providerLiteral>,
<ac:provider rdf:resource="http://biocol.org/urn:lsid:biocol.org:col:35115"/>,
<dwc:collectionCode>{$ns}</dwc:collectionCode>,
<dwc:catalogNumber>{$img}</dwc:catalogNumber>
};



(:
*********** Set up local folders *********
:)

let $localFilesFolderUnix := "c:/test"

(: Create root folder if it doesn't already exist. :)
let $rootPath := "c:\test"
(: "file:create-dir($dir as xs:string) as empty-sequence()" will create a directory or do nothing if it already exists :)
let $nothing := file:create-dir($rootPath)


(:
*********** Get data from GitHub *********
:)
let $textOrganisms := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/organisms.csv'/>)[2]
let $xmlOrganisms := csv:parse($textOrganisms, map { 'header' : true(),'separator' : "|" })

let $textDeterminations := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/determinations.csv'/>)[2]
let $xmlDeterminations := csv:parse($textDeterminations, map { 'header' : true(),'separator' : "|" })

let $textNames := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/names.csv'/>)[2]
let $xmlNames := csv:parse($textNames, map { 'header' : true(),'separator' : "|" })
(:
let $textSensu := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/sensu.csv'/>)[2]
let $xmlSensu := csv:parse($textSensu, map { 'header' : true(),'separator' : "|" })

let $textImages := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/images.csv'/>)[2]
let $xmlImages := csv:parse($textImages, map { 'header' : true(),'separator' : "|" })

let $textAgents := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/agents.csv'/>)[2]
let $xmlAgents := csv:parse($textAgents, map { 'header' : true(),'separator' : "|" })

let $licenseDoc := fn:doc('https://raw.githubusercontent.com/baskaufs/Bioimages/master/license.xml')
let $licenseCategory := $licenseDoc/license/category

let $stdViewDoc := fn:doc('https://raw.githubusercontent.com/baskaufs/Bioimages/master/stdview.xml')
let $viewCategory := $stdViewDoc/view/viewGroup/viewCategory

let $imagesToWriteDoc := file:read-text(concat('file:///',$localFilesFolderUnix,'/images-to-write.txt'))
let $xmlImagesToWrite := csv:parse($imagesToWriteDoc, map { 'header' : false() })
:)
let $filePath := concat($rootPath,"\metadata-tax.xml")
return (file:write($filePath,
      <DarwinRecordSet>{

for $name in $xmlNames//record,
    $det in $xmlDeterminations//record,
    $org in $xmlOrganisms//record
where $det/dsw_identified/text()=$org/dcterms_identifier/text() and $name/dcterms_identifier/text()=$det/tsnID/text()
order by $name/dcterms_identifier
let $tsn := $name/dcterms_identifier/text()
group by $tsn
return (
        <taxon>
          <tsn>{$name/dcterms_identifier/text()}</tsn>
          <class>{$name/dwc_class/text()}</class>
          <order>{$name/dwc_order/text()}</order>
          <family>{$name/dwc_family/text()}</family>
          <genus>{$name/dwc_genus/text()}</genus>
          <species>{$name/dwc_specificEpithet/text()}</species>
          <rank>{$name/dwc_taxonRank/text()}</rank>
          <ife>{$name/dwc_infraspecificEpithet/text()}</ife>
          <author>{$name/dwc_scientificNameAuthorship/text()}</author>
          <vernac>{$name/dwc_vernacularName/text()}</vernac>
        </taxon>
       )
       
      }</DarwinRecordSet>
))
       
       