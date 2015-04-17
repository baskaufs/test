xquery version "3.0";

declare namespace vra="http://www.vraweb.org/vracore4.htm";

for $name in fn:collection("Metadata")//vra:agent
(:where substring($name/vra:name/text(),1,5)="Burri":)
where normalize-space($name/vra:name/@refid/data()) != $name/vra:name/@refid/data()

return $name/vra:name/text()||"&#10;"||base-uri($name/vra:name)||"&#10;"||"&#10;"
