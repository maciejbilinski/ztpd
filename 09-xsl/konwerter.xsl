<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:template match='/'>
        <PRACOWNICY>
            <xsl:apply-templates select="//PRACOWNICY/ROW">
                <xsl:sort select="ID_PRAC" />
            </xsl:apply-templates>
        </PRACOWNICY>
    </xsl:template>

    <xsl:template match="PRACOWNICY/ROW">
        <PRACOWNIK>
            <xsl:attribute name="ID_PRAC">
                <xsl:value-of select="ID_PRAC" />
            </xsl:attribute>
            <xsl:attribute name="ID_ZESP">
                <xsl:value-of select="ID_ZESP" />
            </xsl:attribute>
            <xsl:attribute name="ID_SZEFA">
                <xsl:value-of select="ID_SZEFA" />
            </xsl:attribute>

            <xsl:copy-of select="NAZWISKO" />
            <xsl:copy-of select="ETAT" />
            <xsl:copy-of select="ZATRUDNIONY" />
            <xsl:copy-of select="PLACA_POD" />
            <xsl:copy-of select="PLACA_DOD" />
        </PRACOWNIK>
    </xsl:template>
</xsl:stylesheet>