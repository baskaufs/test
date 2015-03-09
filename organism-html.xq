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
return (file:create-dir(concat($rootPath,"\",$namespace)), file:write($filePath,
<html>
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
  </head>
  <body vocab="http://schema.org/" prefix="dcterms: http://purl.org/dc/terms/ foaf: http://xmlns.com/foaf/0.1/">
    <div resource="{$orgRecord/dcterms_identifier/text()||'.htm'}" typeof="foaf:Document WebPage" >
      <span property="about" resource="{$orgRecord/dcterms_identifier/text()}"></span>
      <span property="dateModified" content="{fn:current-dateTime()}"></span>
    </div>
    (: !!!!!!!!!!! TODO: need to implement buttons here !!!!!!!!!!!!!! :)
    <div id="paste" resource="{$orgRecord/dcterms_identifier/text()}" typeof="dcterms:PhysicalResource">
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
      </table><br/>
      An individual of {$taxonNameMarkup}
      <br/>
      <h5>Permanent identifier for the individual:</h5><br/>
      <h5><strong property="dcterms:identifier">{$orgRecord/dcterms_identifier/text()}</strong></h5><br/>
      <br/>


    
    </div>
      <rdf:Description rdf:about="{$orgRecord/dcterms_identifier/text()}">{
      <rdf:type rdf:resource="http://rs.tdwg.org/dwc/terms/Organism"/>,
      <rdf:type rdf:resource="http://purl.org/dc/terms/PhysicalResource"/>,
      if ($orgRecord/dwc_collectionCode/text() != "")
      then <dcterms:type rdf:resource="http://rs.tdwg.org/dwc/terms/LivingSpecimen"/>
      else (),
      <!--Basic information about the organism-->,
      <dcterms:identifier>{$orgRecord/dcterms_identifier/text()}</dcterms:identifier>,
      <dcterms:description xml:lang="en">{"Description of an organism having GUID: "||$orgRecord/dcterms_identifier/text()}</dcterms:description>,
      <dwc:organismScope>{$orgRecord/dwc_organismScope/text()}</dwc:organismScope>,
      if ($orgRecord/dwc_organismRemarks/text() != "")
      then <dwc:organismRemarks>{$orgRecord/dwc_organismRemarks/text()}</dwc:organismRemarks>
      else (),
      if ($orgRecord/dwc_organismName/text() != "")
      then <dwc:organismName>{$orgRecord/dwc_organismName/text()}</dwc:organismName>
      else (),
      <dwc:establishmentMeans>{$orgRecord/dwc_establishmentMeans/text()}</dwc:establishmentMeans>,
      <blocal:cameo rdf:resource="{$orgRecord/cameo/text()}"/>,
      if ($orgRecord/dwc_collectionCode/text() != "")
      then (
           for $agent in $xmlAgents/csv/record
           where $agent/dcterms_identifier=$orgRecord/dwc_collectionCode
           return <dwciri:inCollection rdf:resource="{$agent/iri/text()}"/>,
           <dwc:collectionCode>{$orgRecord/dwc_collectionCode/text()}</dwc:collectionCode>,
           <dwc:catalogNumber>{$orgRecord/dwc_catalogNumber/text()}</dwc:catalogNumber>
           )
      else (),
      <!--Relationships of the organism to other resources-->,
      <foaf:isPrimaryTopicOf rdf:resource="{$orgRecord/dcterms_identifier/text()||".rdf"}" />,
      <foaf:isPrimaryTopicOf rdf:resource="{$orgRecord/dcterms_identifier/text()||".htm"}" />,
        for $depiction in $xmlImages/csv/record
        where $depiction/foaf_depicts=$orgRecord/dcterms_identifier
        return (
               <foaf:depiction rdf:resource="{$depiction/dcterms_identifier/text()}" />,
               <dsw:hasDerivative rdf:resource="{$depiction/dcterms_identifier/text()}" />
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
                             if ($orgRecord/geo_alt/text() != "-9999")
                             then (
                               <geo:alt>{$orgRecord/geo_alt/text()}</geo:alt>,
                               <dwc:minimumElevationInMeters rdf:datatype="http://www.w3.org/2001/XMLSchema#int">{$orgRecord/geo_alt/text()}</dwc:minimumElevationInMeters>,
                               <dwc:maximumElevationInMeters rdf:datatype="http://www.w3.org/2001/XMLSchema#int">{$orgRecord/geo_alt/text()}</dwc:maximumElevationInMeters>
                                  )
                             else (),
                             <dwc:geodeticDatum>{$depiction[1]/dwc_geodeticDatum/text()}</dwc:geodeticDatum>,
                             <dwc:locality>{$depiction[1]/dwc_locality/text()}</dwc:locality>,
                             <dwc:georeferenceRemarks>{$orgRecord/dwc_georeferenceRemarks/text()}</dwc:georeferenceRemarks>,
                             <dwc:continent>{$depiction[1]/dwc_continent/text()}</dwc:continent>,
                             <dwc:countryCode>{$depiction[1]/dwc_countryCode/text()}</dwc:countryCode>,
                             <dwc:stateProvince>{$depiction[1]/dwc_stateProvince/text()}</dwc:stateProvince>,
                             <dwc:county>{$depiction[1]/dwc_county/text()}</dwc:county>,
                             if ($depiction[1]/dwc_informationWithheld/text() != "")
                             then <dwc:informationWithheld>{$depiction[1]/dwc_informationWithheld/text()}</dwc:informationWithheld>
                             else (),
                             if ($depiction[1]/dwc_dataGeneralizations/text() != "")
                             then <dwc:dataGeneralizations>{$depiction[1]/dwc_dataGeneralizations/text()}</dwc:dataGeneralizations>
                             else (),
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
      if ($orgRecord/dwc_collectionCode/text() != "")
      then (
           <!-- The LivingSpecimen serves as evidence for the Occurrence documenting itself as an Organism -->,
           <dcterms:type rdf:resource="http://rs.tdwg.org/dwc/terms/LivingSpecimen"/>,
           <dsw:hasOccurrence>
               <rdf:Description rdf:about='{$orgRecord/dcterms_identifier/text()||"#occ"}'>{
               <rdf:type rdf:resource="http://rs.tdwg.org/dwc/terms/Occurrence"/>,
               <dsw:hasEvidence rdf:resource='{$orgRecord/dcterms_identifier/text()}'/>,
               <!-- dwc:recordedBy and the Event establishing the collection record would go here -->
               }</rdf:Description>
           </dsw:hasOccurrence>
            )
      else (),
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
                  if ($detRecord/dwc_identificationRemarks/text() != "")
                  then <dwc:identificationRemarks>{$detRecord/dwc_identificationRemarks/text()}</dwc:identificationRemarks>
                  else (),
                  <blocal:itisTsn>{$detRecord/tsnID/text()}</blocal:itisTsn>,
                  <dwc:kingdom>{$nameRecord/dwc_kingdom/text()}</dwc:kingdom>,
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
                  <dwc:scientificName>{$nameRecord/dwc_genus/text()||" "||$nameRecord/dwc_specificEpithet/text()}</dwc:scientificName>,
                  <dwc:nameAccordingTo>{$sensuRecord/dc_creator/text()||", "||$sensuRecord/dcterms_created/text()||". "||$sensuRecord/dc_publisher/text()||"."}</dwc:nameAccordingTo>,
                  <blocal:secundumSignature>{$sensuRecord/tcsSignature/text()}</blocal:secundumSignature>,
                  <dwciri:toTaxon><dwc:Taxon>
                       <tc:accordingTo rdf:resource="{$sensuRecord/iri/text()}" />
                       <tc:hasName rdf:resource="urn:lsid:ubio.org:namebank:{$nameRecord/ubioID/text()}"/>
                  </dwc:Taxon></dwciri:toTaxon>,
                  if (string-length($detRecord/dwc_dateIdentified/text()) = 10)
                  then (<dwc:dateIdentified rdf:datatype="http://www.w3.org/2001/XMLSchema#date">{$detRecord/dwc_dateIdentified/text()}</dwc:dateIdentified>)
                  else (
                       if (string-length($detRecord/dwc_dateIdentified/text()) = 4)
                       then (<dwc:dateIdentified rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">{$detRecord/dwc_dateIdentified/text()}</dwc:dateIdentified>)
                       else (<dwc:dateIdentified>{$detRecord/dwc_dateIdentified/text()}</dwc:dateIdentified>)
                       ),
                  for $agentRecord in $xmlAgents/csv/record
                  where $agentRecord/dcterms_identifier=$detRecord/identifiedBy
                  return (
                         <dwc:identifiedBy>{$agentRecord/dc_contributor/text()}</dwc:identifiedBy>,
                         <dwciri:identifiedBy rdf:resource ="{$agentRecord/iri/text()}"/>
                         )
              }</rdf:Description></dsw:hasIdentification>,
              
              for $linkRecord in $xmlLinks/csv/record
              where $linkRecord/subjectIRI/text()=$orgRecord/dcterms_identifier/text()
              return (
                     element {$linkRecord/property/text()} 
                         {
                         <rdf:Description rdf:about="{$linkRecord/objectIRI/text()}">
                           <rdf:type rdf:resource="{$linkRecord/objectType/text()}"/>
                           <dcterms:description xml:lang="en">{$linkRecord/objectDescription/text()}</dcterms:description>
                         </rdf:Description>
                         }
                     )
              
              
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
            <dcterms:modified rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">{fn:current-dateTime()}</dcterms:modified>,
            <dcterms:references rdf:resource="{$orgRecord/dcterms_identifier/text()}"/>,
            <foaf:primaryTopic rdf:resource="{$orgRecord/dcterms_identifier/text()}"/>
       }</rdf:Description>
  </body>
</html>
       )),
let $localFilesFolderPC := "c:\test"
let $lastPublished := fn:current-dateTime()
return (file:write(concat($localFilesFolderPC,"\last-published.xml"),
<body>
<dcterms:modified>{$lastPublished}</dcterms:modified>
</body>
))
