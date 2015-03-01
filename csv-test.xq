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

(: Uses http:send-request to fetch CSV files from GitHub :)
(: BaseX 8.0 requires 'map' keyword) before key/value maps :)
(: Older versions of BaseX may not have this requirement :)

(:let $textOrganisms := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/organisms.csv'/>)[2]:)
let $textOrganisms := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/organisms-small.csv'/>)[2]
let $xmlOrganisms := csv:parse($textOrganisms, map { 'header' : true() })

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

for $orgRecord in $xmlOrganisms/csv/record
where $orgRecord/dcterms_identifier/text() !=""
let $fileName := local:substring-after-last($orgRecord/dcterms_identifier/text(),"/")
let $temp := substring-before($orgRecord/dcterms_identifier/text(),concat("/",$fileName))
let $namespace := local:substring-after-last($temp,"/")
let $filePath := concat("C:\test\", $namespace,"\", $fileName,".rdf")
(: "file:create-dir($dir as xs:string) as empty-sequence()" will create a directory or do nothing if it already exists :)
return file:write($filePath,
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
xmlns:dc="http://purl.org/dc/elements/1.1/"
xmlns:dcterms="http://purl.org/dc/terms/"
xmlns:dwc="http://rs.tdwg.org/dwc/terms/"
xmlns:dwciri="http://rs.tdwg.org/dwc/iri/"
xmlns:dsw="http://purl.org/dsw/"
xmlns:xmp="http://ns.adobe.com/xap/1.0/"
xmlns:foaf="http://xmlns.com/foaf/0.1/"
xmlns:tc="http://rs.tdwg.org/ontology/voc/TaxonConcept#"
xmlns:txn="http://lod.taxonconcept.org/ontology/txn.owl#"
xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
xmlns:blocal="http://bioimages.vanderbilt.edu/rdf/local#"
>
      <rdf:Description rdf:about="{$orgRecord/dcterms_identifier/text()}">{
      <rdf:type rdf:resource="http://rs.tdwg.org/dwc/terms/Organism"/>,
      <rdf:type rdf:resource="http://purl.org/dc/terms/PhysicalResource"/>,
      <dcterms:type rdf:resource="http://purl.org/dc/terms/PhysicalResource"/>,
      <!--Basic information about the organism-->,
      <dcterms:identifier>{$orgRecord/dcterms_identifier/text()}</dcterms:identifier>,
      <dcterms:description xml:lang="en">{"Description of an organism having GUID: "||$orgRecord/dcterms_identifier/text()}</dcterms:description>,
      <dwc:establishmentMeans>{$orgRecord/dwc_establishmentMeans/text()}</dwc:establishmentMeans>,
      (: TODO: need to conditionally include colletion data if a living specimen :)
      <!--Relationships of the organism to other resources-->,
      <foaf:isPrimaryTopicOf rdf:resource="{$orgRecord/dcterms_identifier/text()||".rdf"}" />,
      <foaf:isPrimaryTopicOf rdf:resource="{$orgRecord/dcterms_identifier/text()||".htm"}" />,
        for $depiction in $xmlImages/csv/record
        where $depiction/foaf_depicts=$orgRecord/dcterms_identifier
        return (
               <foaf:depiction rdf:resource="{$depiction/dcterms_identifier}" />,
               <dsw:hasDerivative rdf:resource="{$depiction/dcterms_identifier}" />
               ),
        <!--Occurrences documented for the organism-->,
        for $depiction in $xmlImages/csv/record
        where $depiction/foaf_depicts=$orgRecord/dcterms_identifier
        let $occurrenceDate := substring($depiction/dcterms_created/text(),1,10)
        group by $occurrenceDate
        return (<dsw:hasOccurrence>
              <rdf:Description rdf:about='{$orgRecord/dcterms_identifier/text()||"#"||$occurrenceDate}'>{
                <rdf:type rdf:resource="http://rs.tdwg.org/dwc/terms/Occurrence"/>,
                <dsw:atEvent>
                    <rdf:Description rdf:about='{$orgRecord/dcterms_identifier/text()||"#"||$occurrenceDate||"eve"}'>{
                      <rdf:type rdf:resource="http://rs.tdwg.org/dwc/terms/Event"/>,
                      <dwc:eventDate rdf:datatype="http://www.w3.org/2001/XMLSchema#date">{$occurrenceDate}</dwc:eventDate>,
                        <dsw:locatedAt>
                           <rdf:Description rdf:about='{$orgRecord/dcterms_identifier/text()||"#"||$occurrenceDate||"loc"}'>{
                             <rdf:type rdf:resource="http://purl.org/dc/terms/Location"/>,
                             <geo:lat>{$orgRecord/dwc_decimalLatitude/text()}</geo:lat>,
                             <dwc:decimalLatitude rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">{$orgRecord/dwc_decimalLatitude/text()}</dwc:decimalLatitude>,
                             <geo:long>{$orgRecord/dwc_decimalLongitude/text()}</geo:long>,
                             <dwc:decimalLongitude rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">{$orgRecord/dwc_decimalLongitude/text()}</dwc:decimalLongitude>,
                             <dwc:coordinateUncertaintyInMeters rdf:datatype="http://www.w3.org/2001/XMLSchema#int">{$depiction[1]/dwc_coordinateUncertaintyInMeters/text()}</dwc:coordinateUncertaintyInMeters>,
                             <dwc:geodeticDatum>{$depiction[1]/dwc_geodeticDatum/text()}</dwc:geodeticDatum>,
                             <dwc:locality>{$depiction[1]/dwc_locality/text()}</dwc:locality>,
                             <dwc:georeferenceRemarks>{$depiction[1]/dwc_georeferenceRemarks/text()}</dwc:georeferenceRemarks>,
                             <dwc:continent>{$depiction[1]/dwc_continent/text()}</dwc:continent>,
                             <dwc:countryCode>{$depiction[1]/dwc_countryCode/text()}</dwc:countryCode>,
                             <dwc:stateProvince>{$depiction[1]/dwc_stateProvince/text()}</dwc:stateProvince>,
                             <dwc:county>{$depiction[1]/dwc_county/text()}</dwc:county>,
                             <dwciri:inDescribedPlace rdf:resource="{'http://sws.geonames.org/'||$depiction[1]/geonamesAdmin/text()||'/'}"/>,   
                             if ($depiction[1]/geonamesOther/text() != "")
                             then <dwciri:inDescribedPlace rdf:resource="{'http://sws.geonames.org/'||$depiction[1]/geonamesOther/text()||'/'}"/>
                             else ()
                           }</rdf:Description>
                        </dsw:locatedAt>
                    }</rdf:Description>
                </dsw:atEvent>,
                ($depiction/dcterms_identifier ! <dsw:hasEvidence rdf:resource="{.}"/>)
              }</rdf:Description>              
               </dsw:hasOccurrence>),
      <!--Identifications applied to the organism-->,
        for $detRecord in $xmlDeterminations/csv/record,
            $nameRecord in $xmlNames/csv/record,
            $sensuRecord in $xmlSensu/csv/record
        where $detRecord/dsw_identified=$orgRecord/dcterms_identifier and $nameRecord/dcterms_identifier=$detRecord/tsnID and $sensuRecord/dcterms_identifier=$detRecord/nameAccordingToID
        return <dsw:hasIdentification><rdf:Description rdf:about="{$orgRecord/dcterms_identifier/text()||"#"||$detRecord/dwc_dateIdentified/text()||$detRecord/identifiedBy/text()}">{
                  if ($nameRecord/dwc_taxonRank/text() = "species")
                  then <dcterms:description xml:lang="en">Determination of {$nameRecord/dwc_genus/text()||" "||$nameRecord/dwc_specificEpithet/text()||" sec. "||$sensuRecord/tcsSignature/text()}</dcterms:description>
                  else 
                    if ($nameRecord/dwc_taxonRank/text() = "genus")
                    then <dcterms:description xml:lang="en">Determination of {$nameRecord/dwc_genus/text()||" sec. "||$sensuRecord/tcsSignature/text()}</dcterms:description>
                    else 
                      if ($nameRecord/dwc_taxonRank/text() = "subspecies")
                      then <dcterms:description xml:lang="en">Determination of {$nameRecord/dwc_genus/text()||" "||$nameRecord/dwc_specificEpithet/text()||" ssp. "||$nameRecord/dwc_infraspecificEpithet/text()||" sec. "||$sensuRecord/tcsSignature/text()}</dcterms:description>
                      else
                        if ($nameRecord/dwc_taxonRank/text() = "variety")
                        then <dcterms:description xml:lang="en">Determination of {$nameRecord/dwc_genus/text()||" "||$nameRecord/dwc_specificEpithet/text()||" var. "||$nameRecord/dwc_infraspecificEpithet/text()||" sec. "||$sensuRecord/tcsSignature/text()}</dcterms:description>
                        else ()
                  ,
                  <rdf:type rdf:resource ="http://rs.tdwg.org/dwc/terms/Identification" />,
                  <dsw:identifies rdf:resource ="{$orgRecord/dcterms_identifier/text()}" />,
                  <blocal:itisTsn>{$detRecord/tsnID/text()}</blocal:itisTsn>,
                  <dwc:class>{$nameRecord/dwc_class/text()}</dwc:class>,
                  
                  if ($nameRecord/dwc_order/text() != "")
                  then <dwc:order>{$nameRecord/dwc_order/text()}</dwc:order>
                  else (),
                  
                  if ($nameRecord/dwc_genus/text() != "")
                  then <dwc:genus>{$nameRecord/dwc_genus/text()}</dwc:genus>
                  else (),
                  
                  if ($nameRecord/dwc_specificEpithet/text() != "")
                  then <dwc:specificEpithet>{$nameRecord/dwc_specificEpithet/text()}</dwc:specificEpithet>
                  else (),
                  
                  if ($nameRecord/dwc_infraspecificEpithet/text() != "")
                  then <dwc:infraspecificEpithet>{$nameRecord/dwc_infraspecificEpithet/text()}</dwc:infraspecificEpithet>
                  else (),
                  
                  <dwc:taxonRank>{$nameRecord/dwc_taxonRank/text()}</dwc:taxonRank>,
                  <dwc:vernacularName xml:lang="en">{$nameRecord/dwc_vernacularName/text()}</dwc:vernacularName>,
                  <dwc:scientificNameAuthorship>{$nameRecord/dwc_scientificNameAuthorship/text()}</dwc:scientificNameAuthorship>,
                  (: TODO: needs to handle genera only and also ssp. and var. :)
                  <dwc:scientificName>{$nameRecord/dwc_genus/text()||" "||$nameRecord/dwc_specificEpithet/text()}</dwc:scientificName>,
                  <dwc:nameAccordingTo>{$sensuRecord/dc_creator/text()||", "||$sensuRecord/dcterms_created/text()||". "||$sensuRecord/dc_publisher/text()||"."}</dwc:nameAccordingTo>,
                  <blocal:secundumSignature>{$sensuRecord/tcsSignature/text()}</blocal:secundumSignature>,
                  <dwciri:toTaxon><dwc:Taxon>
                       <tc:accordingTo rdf:resource="{$sensuRecord/iri/text()}" />
                       <tc:hasName rdf:resource="urn:lsid:ubio.org:namebank:{$nameRecord/ubioID/text()}"/>
                  </dwc:Taxon></dwciri:toTaxon>,
                  (: TODO: date needs to have xsd:date datatype, but what about year only? :)
                  <dwc:dateIdentified>{$detRecord/dwc_dateIdentified/text()}</dwc:dateIdentified>,
                  for $agentRecord in $xmlAgents/csv/record
                  where $agentRecord/dcterms_identifier=$detRecord/identifiedBy
                  return (
                         <dwc:identifiedBy>{$agentRecord/dc_contributor/text()}</dwc:identifiedBy>,
                         <dwciri:identifiedBy rdf:resource ="{$agentRecord/iri/text()}"/>
                         )
              }</rdf:Description></dsw:hasIdentification>
      }</rdf:Description>
       <rdf:Description rdf:about="{$orgRecord/dcterms_identifier/text()||".rdf"}">{
            <rdf:type rdf:resource ="http://xmlns.com/foaf/0.1/Document" />,
            <dc:format>application/rdf+xml</dc:format>,
            <dcterms:identifier>{$orgRecord/dcterms_identifier/text()||".rdf"}</dcterms:identifier>,
            <dcterms:description xml:lang="en">RDF formatted description of the organism {$orgRecord/dcterms_identifier/text()}</dcterms:description>,
            <dc:creator>bioimages.vanderbilt.edu</dc:creator>,
            <dcterms:creator rdf:resource="http://biocol.org/urn:lsid:biocol.org:col:35115"/>,
            <dc:language>en</dc:language>,
            <dcterms:language rdf:resource="http://id.loc.gov/vocabulary/iso639-2/eng"/>,
            <dcterms:modified rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">{fn:format-dateTime(fn:current-dateTime(), "[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]")}</dcterms:modified>,
            <dcterms:references rdf:resource="{$orgRecord/dcterms_identifier/text()}"/>,
            <foaf:primaryTopic rdf:resource="{$orgRecord/dcterms_identifier/text()}"/>
       }</rdf:Description></rdf:RDF>
       )

