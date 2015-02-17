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
declare namespace local="http://bioimages.vanderbilt.edu/rdf/local#";



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
xmlns:local="http://bioimages.vanderbilt.edu/rdf/local#"
>{

(: Uses http:send-request to fetch CSV files from GitHub :)
(: BaseX 8.0 requires 'map' keyword) before key/value maps :)
(: Older versions of BaseX may not have this requirement :)

let $textIndividuals := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/individuals.csv'/>)[2]
let $xmlIndividuals := csv:parse($textIndividuals, map { 'header' : true() })

let $textDeterminations := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/determinations.csv'/>)[2]
let $xmlDeterminations := csv:parse($textDeterminations, map { 'header' : true() })

let $textNames := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/names.csv'/>)[2]
let $xmlNames := csv:parse($textNames, map { 'header' : true() })

let $textSensu := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/sensu.csv'/>)[2]
let $xmlSensu := csv:parse($textSensu, map { 'header' : true() })

let $textImages := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/images.csv'/>)[2]
let $xmlImages := csv:parse($textImages, map { 'header' : true() })

let $textAgents := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/agents.csv'/>)[2]
let $xmlAgents := csv:parse($textAgents, map { 'header' : true() })

for $indRecord in $xmlIndividuals/csv/record

return (
      <rdf:Description rdf:about="{$indRecord/individualOrganismID/text()}">{
      <rdf:type rdf:resource="http://rs.tdwg.org/dwc/terms/Organism"/>,
      <rdf:type rdf:resource="http://purl.org/dc/terms/PhysicalResource"/>,
      <dcterms:type rdf:resource="http://purl.org/dc/terms/PhysicalResource"/>,
      <!--Basic information about the organism-->,
      <dcterms:identifier>{$indRecord/individualOrganismID/text()}</dcterms:identifier>,
      <dcterms:description xml:lang="en">{"Description of an organism having GUID: "||$indRecord/individualOrganismID/text()}</dcterms:description>,
      <dwc:establishmentMeans>{$indRecord/dwc_establishmentMeans/text()}</dwc:establishmentMeans>,
      <!--Relationships of the organism to other resources-->,
      <foaf:isPrimaryTopicOf rdf:resource="{$indRecord/individualOrganismID/text()||".rdf"}" />,
      <foaf:isPrimaryTopicOf rdf:resource="{$indRecord/individualOrganismID/text()||".htm"}" />,
        for $depiction in $xmlImages/csv/record
        where $depiction/foaf_depicts=$indRecord/individualOrganismID
        return (
               <foaf:depiction rdf:resource="{$depiction/dcterms_identifier}" />,
               <dsw:hasDerivative rdf:resource="{$depiction/dcterms_identifier}" />
               ),
      <!--Identifications applied to the organism-->,
        for $detRecord in $xmlDeterminations/csv/record,
            $nameRecord in $xmlNames/csv/record,
            $sensuRecord in $xmlSensu/csv/record
        where $detRecord/dwc_identificationID=$indRecord/individualOrganismID and $nameRecord/tsnID=$detRecord/TSNID and $sensuRecord/identifier=$detRecord/dwc_nameAccordingToID
        return <dsw:hasIdentification><rdf:Description rdf:about="{$indRecord/individualOrganismID/text()||"#"||$detRecord/dwc_dateIdentified/text()||$detRecord/dwc_identifiedBy/text()}">{
                  <dcterms:description xml:lang="en">Determination of {$nameRecord/genus/text()||" "||$nameRecord/specificEpithet/text()||" sec. "||$sensuRecord/citation_following_TCS_signature_fields/text()}</dcterms:description>,
                  <rdf:type rdf:resource ="http://rs.tdwg.org/dwc/terms/Identification" />,
                  <dsw:identifies rdf:resource ="{$indRecord/individualOrganismID/text()}" />,
                  <local:itisTsn>{$detRecord/TSNID/text()}</local:itisTsn>,
                  <dwc:class>{$nameRecord/class/text()}</dwc:class>,
                  <dwc:order>{$nameRecord/order/text()}</dwc:order>,
                  <dwc:genus>{$nameRecord/genus/text()}</dwc:genus>,
                  <dwc:specificEpithet>{$nameRecord/specificEpithet/text()}</dwc:specificEpithet>,
                  <dwc:taxonRank>{$nameRecord/taxonRank/text()}</dwc:taxonRank>,
                  <dwc:vernacularName xml:lang="en">{$nameRecord/vernacularName/text()}</dwc:vernacularName>,
                  <dwc:scientificNameAuthorship>{$nameRecord/scientificNameAuthorship/text()}</dwc:scientificNameAuthorship>,
                  (: TODO: needs to handle genera only and also ssp. and var. :)
                  <dwc:scientificName>{$nameRecord/genus/text()||" "||$nameRecord/specificEpithet/text()}</dwc:scientificName>,
                  <dwc:nameAccordingTo>{$sensuRecord/author/text()||", "||$sensuRecord/Date/text()||". "||$sensuRecord/publisher/text()||"."}</dwc:nameAccordingTo>,
                  <local:secundumSignature>{$sensuRecord/citation_following_TCS_signature_fields/text()}</local:secundumSignature>,
                  <dwciri:toTaxon><dwc:Taxon>
                       <tc:accordingTo rdf:resource="{$sensuRecord/iri/text()}" />
                       <tc:hasName rdf:resource="urn:lsid:ubio.org:namebank:{$nameRecord/ubioID/text()}"/>
                  </dwc:Taxon></dwciri:toTaxon>,
                  (: TODO: date needs to have xsd:date datatype, but what about year only? :)
                  <dwc:dateIdentified>{$detRecord/dwc_dateIdentified/text()}</dwc:dateIdentified>,
                  for $agentRecord in $xmlAgents/csv/record
                  where $agentRecord/agent_code=$detRecord/dwc_identifiedBy
                  return (
                         <dwc:identifiedBy>{$agentRecord/Name/text()}</dwc:identifiedBy>,
                         <dwciri:identifiedBy rdf:resource ="{$agentRecord/URI/text()}"/>
                         )
              }</rdf:Description></dsw:hasIdentification>
      }</rdf:Description>,
       <rdf:Description rdf:about="{$indRecord/individualOrganismID/text()||".rdf"}">{
            <rdf:type rdf:resource ="http://xmlns.com/foaf/0.1/Document" />,
            <dc:format>application/rdf+xml</dc:format>,
            <dcterms:identifier>{$indRecord/individualOrganismID/text()||".rdf"}</dcterms:identifier>,
            <dcterms:description xml:lang="en">RDF formatted description of the organism {$indRecord/individualOrganismID/text()}</dcterms:description>,
            <dc:creator>bioimages.vanderbilt.edu</dc:creator>,
            <dcterms:creator rdf:resource="http://biocol.org/urn:lsid:biocol.org:col:35115"/>,
            <dc:language>en</dc:language>,
            <dcterms:language rdf:resource="http://id.loc.gov/vocabulary/iso639-2/eng"/>,
            <dcterms:modified rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">2014-07-15T14:39:03</dcterms:modified>,
            <dcterms:references rdf:resource="{$indRecord/individualOrganismID/text()}"/>,
            <foaf:primaryTopic rdf:resource="{$indRecord/individualOrganismID/text()}"/>
       }</rdf:Description>
       )
}</rdf:RDF>

(:
for $year in (2010 to 2011)
  let $fName := concat("C:\", $year, "B.xml")
  for $x in doc('docs')//Doc
    where $x/@year eq xs:string($year)
    return file:append($fName, $x)
:)
