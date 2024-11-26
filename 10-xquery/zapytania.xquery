(:5:)
doc("db/bib/bib.xml")//last

(:6:)
for $book in doc("db/bib/bib.xml")//book,
    $title in $book/title,
    $author in $book/author
return 
    <ksiazka>
        <author>
            <last>{$author/last/text()}</last>
            <first>{$author/first/text()}</first>
        </author>
        <title>{$title/text()}</title>
    </ksiazka>

(:7:)
for $book in doc("db/bib/bib.xml")//book,
    $title in $book/title,
    $author in $book/author
return 
    <ksiazka>
        <autor>
            {$author/last/text()} {$author/first/text()}
        </autor>
        <tytul>{$title/text()}</tytul>
    </ksiazka>

(:8:)
for $book in doc("db/bib/bib.xml")//book,
    $title in $book/title,
    $author in $book/author
return 
    <ksiazka>
        <autor>
            {$author/last/text()||' '||$author/first/text()}
        </autor>
        <tytul>{$title/text()}</tytul>
    </ksiazka>

(:9:)
<wynik>
{
    for $book in doc("db/bib/bib.xml")//book,
        $title in $book/title,
        $author in $book/author
    return 
        <ksiazka>
            <autor>
                {$author/last/text() || ' ' || $author/first/text()}
            </autor>
            <tytul>{$title/text()}</tytul>
        </ksiazka>
}
</wynik>

(:10:)
<imiona>
{
    for $author in doc("db/bib/bib.xml")//book[title='Data on the Web']/author
    return 
        <imie>
          {$author/first/text()}
        </imie>
}
</imiona>

(:11 A:)
<DataOnTheWeb>
{
  doc("db/bib/bib.xml")//book[title = "Data on the Web"]
}
</DataOnTheWeb>

(:11 B:)
<DataOnTheWeb>
{
    for $book in doc("db/bib/bib.xml")//book
    where $book/title = "Data on the Web"
    return $book
}
</DataOnTheWeb>

(:12:)
<Data>
{
    for $book in doc("db/bib/bib.xml")//book,
        $title in $book/title,
        $author in $book/author
    where contains($title, 'Data')
    return <nazwisko>{$author/last/text()}</nazwisko>
}
</Data>

(:13:)
<Data>
{
    for $book in doc("db/bib/bib.xml")//book,
        $title in $book/title
    where contains($title, 'Data')
    return <title>{$title/text()}</title>
}
{
    for $book in doc("db/bib/bib.xml")//book,
        $title in $book/title,
        $author in $book/author
    where contains($title, 'Data')
    return <nazwisko>{$author/last/text()}</nazwisko>
}
</Data>

(:14:)
for $book in doc("db/bib/bib.xml")//book,
    $title in $book/title
where count($book/author) <= 2
return
<title>
  {$title/text()}
</title>

(:15:)
for $book in doc("db/bib/bib.xml")//book,
    $title in $book/title
return
<ksiazka>
  <title>
    {$title/text()}
  </title>
  <autorow>
    {count($book/author)}
  </autorow>
</ksiazka>

(:16:)
let $years := doc("db/bib/bib.xml")//book/@year
let $minYear := min($years)
let $maxYear := max($years)
return <przedział>{$minYear} - {$maxYear}</przedział>

(:17:)
let $prices := for $price in doc("db/bib/bib.xml")//book/price return number($price)
return <różnica>{max($prices) - min($prices)}</różnica>

(:18:)
<najtańsze>
{
  let $doc := doc("db/bib/bib.xml")
  let $prices := for $price in $doc//book/price return number($price)
  let $minPrice := min($prices)
  
  for $book in $doc//book
  where number($book/price) = $minPrice
  return <najtańsza>
    {$book/title}
    {$book/author}
  </najtańsza>
}
</najtańsze>

(:19:)
let $doc := doc("db/bib/bib.xml")
for $last in distinct-values($doc//author/last)
  let $titles := $doc//book[author/last = $last]/title
  return
    <autor>
      <last>{$last}</last>
      {$titles}
    </autor>

(:20:)
<wynik>
{
  for $play in collection("db/shakespeare")/PLAY
  return $play/TITLE 
}
</wynik>

(:21:)
for $play in collection("db/shakespeare")/PLAY,
    $line in $play//LINE
where contains($line, "or not to be")
return $play/TITLE

(:22:)
<wynik>
{
  for $play in collection("db/shakespeare")/PLAY
  let $num_personae := count($play/PERSONAE//PERSONA)
  let $num_acts := count($play/ACT)
  let $num_scenes := count($play//SCENE)
  order by $play/TITLE/text()
  return 
    <sztuka tytul="{$play/TITLE/text()}">
      <postaci>{ $num_personae }</postaci>
      <aktow>{ $num_acts }</aktow>
      <scen>{ $num_scenes }</scen>
    </sztuka>

}
</wynik>