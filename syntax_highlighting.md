```JSON
{
"@type": "TableGroup",
"@context": "http://www.w3.org/ns/csvw",
"tables": [
  {
  "url": "bluffton_presidents.csv",
  "tableSchema": {
    "columns": [ 
      {
      "titles":"Q_ID",
      "name":"qid",
      "datatype":"string",
      "suppressOutput":true
      },
      {
      "titles":"instanceOf_uuid",
      "name":"instanceOf_uuid",
      "datatype":"string",
      "aboutUrl":"http://www.wikidata.org/entity/{qid}",
      "propertyUrl":"http://www.wikidata.org/prop/P31",
      "valueUrl":"http://www.wikidata.org/entity/statement/{qid}-{instanceOf_uuid}"
      },
      {
      "titles":"instanceOf",
      "name":"instanceOf",
      "datatype":"string",
      "aboutUrl":"http://www.wikidata.org/entity/statement/{qid}-{instanceOf_uuid}",
      "propertyUrl":"http://www.wikidata.org/prop/statement/P31",
      "valueUrl":"http://www.wikidata.org/entity/{instanceOf}"
      }
    ]}
  }
]}
```
