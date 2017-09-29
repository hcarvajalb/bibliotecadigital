<?xml version="1.0" encoding="UTF-8"?>
<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    TODO: Describe this XSL file
    Author: Alexey Maslov

-->

<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
	xmlns:dri="http://di.tamu.edu/DRI/1.0/"
	xmlns:mets="http://www.loc.gov/METS/"
	xmlns:xlink="http://www.w3.org/TR/xlink/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc">

    <!--<xsl:import href="../dri2xhtml-alt/dri2xhtml.xsl"/>-->
    <xsl:import href="aspect/artifactbrowser/artifactbrowser.xsl"/>
    <xsl:import href="core/global-variables.xsl"/>
    <xsl:import href="core/elements.xsl"/>
    <xsl:import href="core/forms.xsl"/>
    <xsl:import href="core/page-structure.xsl"/>
    <xsl:import href="core/navigation.xsl"/>
    <xsl:import href="core/attribute-handlers.xsl"/>
    <xsl:import href="core/utils.xsl"/>
    <xsl:import href="aspect/general/choice-authority-control.xsl"/>
    <xsl:import href="aspect/general/vocabulary-support.xsl"/>
    <!--<xsl:import href="xsl/aspect/administrative/administrative.xsl"/>-->
    <xsl:import href="aspect/artifactbrowser/common.xsl"/>
    <xsl:import href="aspect/artifactbrowser/item-list.xsl"/>
    <xsl:import href="aspect/artifactbrowser/item-view.xsl"/>
    <xsl:import href="aspect/artifactbrowser/community-list.xsl"/>
    <xsl:import href="aspect/artifactbrowser/collection-list.xsl"/>
    <xsl:import href="aspect/artifactbrowser/browse.xsl"/>
    <xsl:import href="aspect/discovery/discovery.xsl"/>
    <xsl:import href="aspect/artifactbrowser/one-offs.xsl"/>
    <xsl:import href="aspect/submission/submission.xsl"/>
    <xsl:output indent="yes"/>
	
	
	<xsl:template name="itemSummaryView-DIM">
   <xsl:apply-templates
      select="./mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file[@MIMETYPE='video/x-flv']" mode="flashplay" />
   <xsl:if test="mets:fileSec/mets:fileGrp[@USE='FILMSTRIPTHUMB']">
      <img alt="Filmstrip Thumbnail">
      <xsl:attribute name="src">
         <xsl:value-of
            select="mets:fileSec/mets:fileGrp[@USE='FILMSTRIPTHUMB']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
      </xsl:attribute>
      </img>
   </xsl:if>
   <xsl:apply-templates
      select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
      mode="itemSummaryView-DIM"/>
   <xsl:choose>
      <xsl:when test="not(./mets:fileSec/mets:fileGrp[@USE='CONTENT'])">
         <h2>
            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text>
         </h2>
         <table class="ds-table file-list">
            <tr class="ds-table-header-row">
               <th>
                  <i18n:text>Dato1</i18n:text>
               </th>
               <th>
                  <i18n:text>Dato2</i18n:text>
               </th>
               <th>
                  <i18n:text>Dato3</i18n:text>
               </th>
               <th>
                  <i18n:text>Dato4</i18n:text>
               </th>
            </tr>
            <tr>
               <td colspan="4">
                  <p>
                     <i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text>
                  </p>
               </td>
            </tr>
         </table>
      </xsl:when>
      <xsl:otherwise>
         <xsl:apply-templates
            select="./mets:fileSec/mets:fileGrp[@USE='CONTENT']">
            <xsl:with-param name="context" select="."/>
            <xsl:with-param name="primaryBitstream"
               select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpaceItem']/mets:fptr/@FILEID"/>
         </xsl:apply-templates>
      </xsl:otherwise>
   </xsl:choose>
   <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']"/>
</xsl:template>

<xsl:template
   match="mets:fileGrp[@USE='CONTENT']/mets:file[@MIMETYPE='video/x-flv']"
   mode="flashplay" >
   <div id="video" style="text-align:left;">
   

      <object type="application/x-shockwave-flash" data="http://mineduc.prodigioconsultores.com/themes/Mirage2/player.swf" width="500" height="300">
         <param name="movie" value="http://mineduc.prodigioconsultores.com/themes/Mirage2/player.swf" />
         <param name="allowFullScreen" value="true" />
         <param name="FlashVars"
            value="flv={mets:FLocat/@xlink:href}&amp;width=500&amp;height=300&amp;logo=http://localhost:8080/themes/Mirage2/images/logo_ciren.png&amp;showstop=1&amp;showvolume=1&amp;showtime=1&amp;showfullscreen=1&amp;bgcolor1=607890&amp;bgcolor2=607890&amp;playercolor=607890&amp;showplayer=always&amp;showiconplay=1&amp;iconplaycolor=ffffff" />
         <embed src="http://localhost:8080/themes/Mirage2/player.swf"
            PLUGINSPAGE="http://www.macromedia.com/go/getflashplayer"
            TYPE="application/x-shockwave-flash" WIDTH="500" HEIGHT="300"
            allowFullScreen="true"
            Flashvars="flv={mets:FLocat/@xlink:href}&amp;width=500&amp;height=300&amp;showstop=1&amp;showvolume=1&amp;showtime=1&amp;showfullscreen=1&amp;bgcolor1=607890&amp;bgcolor2=607890&amp;playercolor=607890&amp;showplayer=always&amp;showiconplay=1&amp;iconplaycolor=ffffff" />
      </object>
	  <br/><br/><br/>
   </div>
</xsl:template>


</xsl:stylesheet>
