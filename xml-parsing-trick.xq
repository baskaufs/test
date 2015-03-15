xquery version "3.0";

let $textOrganisms := http:send-request(<http:request method='get' href='https://raw.githubusercontent.com/baskaufs/Bioimages/master/organisms-small.csv'/>)[2]
let $xmlOrganisms := csv:parse($textOrganisms, map { 'header' : true() })

for $orgRecord in $xmlOrganisms/csv/record
return if($orgRecord/notes/text())
        then (
          $orgRecord/notes/text(),
          fn:doc(replace($orgRecord/notes/text(),"&gt;",">" ))
             )
        else ()