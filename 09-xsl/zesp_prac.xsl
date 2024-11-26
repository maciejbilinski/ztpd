<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:template match='/'>
        <html>
            <body>
                <h1>ZESPOŁY:</h1>
                <ol>
                    <!--<xsl:for-each select="ZESPOLY/ROW">
                        <li>
                            <xsl:value-of select="NAZWA" />
                        </li>
                    </xsl:for-each>-->
                    <xsl:apply-templates select="ZESPOLY/ROW" mode="LISTA"/>
                </ol>
                <xsl:apply-templates select="ZESPOLY/ROW" mode="SZCZEGOLY"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="ZESPOLY/ROW" mode="LISTA">
        <li>
            <a>
                <xsl:attribute name="href">
                    <xsl:text>#zespol</xsl:text>
                    <xsl:value-of select="ID_ZESP" />
                </xsl:attribute>
                <xsl:value-of select="NAZWA" />
            </a>
        </li>
    </xsl:template>

    <xsl:template match="ZESPOLY/ROW" mode="SZCZEGOLY">
        <p>
            <xsl:attribute name="id">
                <xsl:text>zespol</xsl:text>
                <xsl:value-of select="ID_ZESP" />
            </xsl:attribute>
            <strong>
                <span>
                    NAZWA: <xsl:value-of select="NAZWA" />
                </span>
                <br />
                <span>
                    ADRES: <xsl:value-of select="ADRES" />
                </span>
            </strong>
        </p>
        <xsl:choose>
            <xsl:when test="count(PRACOWNICY/ROW)">
                <table border="1">
                    <tr>
                        <th>Nazwisko</th>
                        <th>Etat</th>
                        <th>Zatrudniony</th>
                        <th>Placa pod.</th>
                        <th>Szef</th>
                    </tr>
                    <xsl:apply-templates select="PRACOWNICY/ROW">
                        <xsl:sort select="NAZWISKO" />
                    </xsl:apply-templates>
                </table>
            </xsl:when>
        </xsl:choose>
        <span>
            Liczba pracowników: <xsl:value-of select="count(PRACOWNICY/ROW)" />
        </span>
    </xsl:template>

    <xsl:template match="PRACOWNICY/ROW">
        <tr>
            <td>
                <xsl:value-of select="NAZWISKO" />
            </td>
            <td>
                <xsl:value-of select="ETAT" />
            </td>
            <td>
                <xsl:value-of select="ZATRUDNIONY" />
            </td>
            <td>
                <xsl:value-of select="PLACA_POD" />
            </td>
            <td>
                <xsl:choose>
                    <xsl:when test="ID_SZEFA">
                        <xsl:value-of select="//PRACOWNICY/ROW[ID_PRAC=current()/ID_SZEFA]/NAZWISKO" />
                    </xsl:when>
                    <xsl:otherwise>
                        brak
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>