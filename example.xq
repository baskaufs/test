let $books :=
<books>
<book class="fiction">Book of Strange New Things</book>
<book class="nonfiction">Programming Scala</book>
<book class="fiction">Absurdistan</book>
<book class="nonfiction">Art of R Programming</book>
<book class="fiction">I, Robot</book>
</books>
for $book in $books/book
let $title := $book/text()||"&#10;"
let $class := "&#10;"||$book/@class||"&#10;"
order by $title
group by $class
return ($class, $title) 