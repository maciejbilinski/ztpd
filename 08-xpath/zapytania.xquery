(:26:)
(:for $k in doc('file:///Users/maciejbilinski/College/ztpd/08-xpath/swiat.xml')/SWIAT/KONTYNENTY/KONTYNENT return <KRAJ>:)
(:  {$k/NAZWA, $k/STOLICA}:)
(:</KRAJ>:)

(:27:)
(:for $k in doc('file:///Users/maciejbilinski/College/ztpd/08-xpath/swiat.xml')/SWIAT/KRAJE/KRAJ return <KRAJ>:)
(:  {$k/NAZWA, $k/STOLICA}:)
(:</KRAJ>:)

(:28:)
(:for $k in doc('file:///Users/maciejbilinski/College/ztpd/08-xpath/swiat.xml')/SWIAT/KRAJE/KRAJ[starts-with(NAZWA, 'A')] return <KRAJ>:)
(:  {$k/NAZWA, $k/STOLICA}:)
(:</KRAJ>:)

(:29:)
(:for $k in doc('file:///Users/maciejbilinski/College/ztpd/08-xpath/swiat.xml')/SWIAT/KRAJE/KRAJ[starts-with(NAZWA, substring(STOLICA, 1, 1))] return <KRAJ>:)
(:  {$k/NAZWA, $k/STOLICA}:)
(:</KRAJ>:)

(:30:)
(:doc('file:///Users/maciejbilinski/College/ztpd/08-xpath/swiat.xml')//KRAJ:)

(:31:)
(:doc('file:///Users/maciejbilinski/College/ztpd/08-xpath/zesp_prac.xml'):)

(:32:)
(:doc('file:///Users/maciejbilinski/College/ztpd/08-xpath/zesp_prac.xml')//NAZWISKO:)

(:33:)
(:doc('file:///Users/maciejbilinski/College/ztpd/08-xpath/zesp_prac.xml')/ZESPOLY/ROW[NAZWA='SYSTEMY EKSPERCKIE']//NAZWISKO:)

(:34:)
(:doc('file:///Users/maciejbilinski/College/ztpd/08-xpath/zesp_prac.xml')/count(ZESPOLY/ROW[ID_ZESP='10']//ROW):)

(:35:)
(:doc('file:///Users/maciejbilinski/College/ztpd/08-xpath/zesp_prac.xml')//ROW[ID_SZEFA='100']/NAZWISKO:)

(:36:)
doc('file:///Users/maciejbilinski/College/ztpd/08-xpath/zesp_prac.xml')/sum(//ROW[ID_ZESP=//ROW[NAZWISKO='BRZEZINSKI']/ID_ZESP]/PLACA_POD)