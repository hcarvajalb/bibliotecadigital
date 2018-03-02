<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Rendering specific to the item display page.

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:jstring="java.lang.String"
    xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights confman">

    <xsl:output indent="yes"/>

    <xsl:template name="itemSummaryView-DIM">
        <!-- Generate the info about the item from the metadata section -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
        mode="itemSummaryView-DIM"/>

        <xsl:copy-of select="$SFXLink" />

        <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
        <xsl:if test="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']">
            <div class="license-info table">
                <p>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.license-text</i18n:text>
                </p>
                <ul class="list-unstyled">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']" mode="simple"/>
                </ul>
            </div>
        </xsl:if>


    </xsl:template>

    <!-- An item rendered in the detailView pattern, the "full item record" view of a DSpace item in Manakin. -->
    <xsl:template name="itemDetailView-DIM">
        <!-- Output all of the metadata about the item from the metadata section -->
        <xsl:apply-templates select="mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                             mode="itemDetailView-DIM"/>

        <!-- Generate the bitstream information from the file section -->
        <xsl:choose>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <h3><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h3>
                <div class="file-list">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE' or @USE='CC-LICENSE']">
                        <xsl:with-param name="context" select="."/>
                        <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                    </xsl:apply-templates>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemDetailView-DIM" />
            </xsl:when>
            <xsl:otherwise>
                <h2><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h2>
                <table class="ds-table file-list">
                    <tr class="ds-table-header-row">
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text></th>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <p><i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text></p>
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
        <div class="item-details">
            <div class="share-file-box btn-toolbar">
                        <p class="text-muted share"></p>
                        
                        <a target="_blank" href="https://www.facebook.com/sharer/sharer.php?u={$url-completa}" class="btn btn-default social-share" data-toggle="tooltip" data-placement="top" title="Compartir en Facebook"><i class="fa fa-facebook" aria-hidden="true"></i>  </a>
                        <a target="_blank" href="http://twitter.com/home?status={$url-completa}" class="btn btn-default social-share" data-toggle="tooltip" data-placement="top" title="Compartir en Twitter"><i class="fa fa-twitter" aria-hidden="true"></i> </a>
                        <a target="_blank" href="http://www.linkedin.com/shareArticle?url={$url-completa}" class="btn btn-default social-share" data-toggle="tooltip" data-placement="top" title="Compartir en Linkedin"><i class="fa fa-linkedin" aria-hidden="true"></i> </a>
                        
                    </div>
            <xsl:call-template name="itemSummaryView-DIM-title"/>
            <div class="media">
                <div class="media-left">
                            <xsl:call-template name="itemSummaryView-DIM-thumbnail"/>
                            <xsl:call-template name="itemSummaryView-DIM-file-section"/>
                    
                </div>
                <div class="media-body">
                    
                    <xsl:call-template name="itemSummaryView-DIM-ministerio"/>
                    <xsl:call-template name="itemSummaryView-DIM-URI"/>
                    <xsl:call-template name="itemSummaryView-DIM-date"/>
                    <xsl:call-template name="itemSummaryView-DIM-authors"/>
                    <xsl:call-template name="itemSummaryView-DIM-abstract"/>
                    <xsl:call-template name="itemSummaryView-collections"/>
                    <xsl:if test="$ds_item_view_toggle_url != ''">
                        <xsl:call-template name="itemSummaryView-show-full"/>
                    </xsl:if>
                    <xsl:call-template name="segpres-reproducir"/>
                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-title">
        <xsl:choose>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
                <h2>
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                </h2>
                <div class="simple-item-view-other">
                    <p class="lead">
                        <xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
                            <xsl:if test="not(position() = 1)">
                                <xsl:value-of select="./node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:if>

                        </xsl:for-each>
                    </p>
                </div>
            </xsl:when>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
                <h2>
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h2>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                </h2>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-thumbnail">
        
            <xsl:choose>
                <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='ORE']">
                    <xsl:variable name="ore" select="concat($url-principal,//mets:fileSec/mets:fileGrp[@USE='ORE']/mets:file/mets:FLocat/@xlink:href)"/>
                    <xsl:variable name="miniatura" select="document($ore)"/>
                    
                    <xsl:variable name="thumbnail" select="$miniatura//oreatom:triples/rdf:Description[dcterms:description='THUMBNAIL']/@rdf:about"/>
                    <xsl:variable name="original" select="$miniatura//oreatom:triples/rdf:Description[dcterms:description='ORIGINAL']/@rdf:about"/>
                    <!--<xsl:value-of select="$original"/>-->
                    <a href="{$original}">
                    <img class="media-object" alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of select="$thumbnail"/>
                                </xsl:attribute>
                    </img>
                    </a>
                    </xsl:when>
                <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']">
                    <xsl:variable name="src">
                        <xsl:choose>
                            <xsl:when test="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]">
                                <xsl:value-of
                                        select="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                        select="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <!-- Checking if Thumbnail is restricted and if so, show a restricted image --> 
                    <xsl:choose>
                        <xsl:when test="contains($src,'isAllowed=n')"/>
                        <xsl:otherwise>
                            <a>
                                <xsl:attribute name="href">
                            <xsl:value-of select="//mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat/@xlink:href"/>
                        </xsl:attribute>
                            <img class="media-object" alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of select="$src"/>
                                </xsl:attribute>
                            </img>
                            </a>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='CONTENT']">
                            
                            
                            <xsl:variable name="mimetype" select="//mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/@MIMETYPE"/>
                            
                            <xsl:choose>
                                    <xsl:when test="$mimetype = 'application/pdf'">
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="//mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat/@xlink:href"/>
                                            </xsl:attribute>
                                                <img class="media-object" src="{$theme-path}images/icons/png/pdf.png"/>
                                        </a>
                                    </xsl:when>
                                    <xsl:when test="$mimetype='application/msword' or $mimetype='application/vnd.openxmlformats-officedocument.wordprocessingml.document' or $mimetype='text/richtext'">
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="//mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat/@xlink:href"/>
                                            </xsl:attribute>
                                                <img class="media-object" src="{$theme-path}images/icons/png/doc.png"/>
                                        </a>
                                    </xsl:when>
                                    <xsl:when test="$mimetype='application/vnd.ms-excel' or $mimetype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'">
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="//mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat/@xlink:href"/>
                                            </xsl:attribute>
                                        <img class="media-object" src="{$theme-path}images/icons/png/xls.png"/>
                                        </a>
                                    </xsl:when>
                                    <xsl:when test="$mimetype='image/png' or $mimetype='image/tiff' or $mimetype='image/x-ms-bmp' or $mimetype='image/gif' or $mimetype='image/jpeg'">
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="//mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat/@xlink:href"/>
                                            </xsl:attribute>
                                                <img class="media-object" src="{$theme-path}images/icons/png/image.png"/>
                                        </a>
                                    </xsl:when>
                                    <xsl:when test="$mimetype='video/mp4' or $mimetype='video/x-flv'">
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="//mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat/@xlink:href"/>
                                            </xsl:attribute>
                                                <img class="media-object" src="{$theme-path}images/icons/png/video-file.png"/>
                                        </a>
                                    </xsl:when>
                                    <xsl:when test="$mimetype='audio/mpeg'">
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="//mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat/@xlink:href"/>
                                            </xsl:attribute>
                                                <img class="media-object" src="{$theme-path}images/icons/png/mp3.png"/>
                                        </a>
                                    </xsl:when>
                                    <xsl:when test="$mimetype='application/zip'">
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="//mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat/@xlink:href"/>
                                            </xsl:attribute>
                                                <img class="media-object" src="{$theme-path}images/icons/png/zip.png"/>
                                        </a>
                                    </xsl:when>
                                    <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="//mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat/@xlink:href"/>
                                            </xsl:attribute>
                                                <img class="media-object" src="{$theme-path}images/icons/png/lock.png"/>
                                        </a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                   
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="//mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat/@xlink:href"/>
                                            </xsl:attribute>
                                        <img class="media-object" height="120" width="90" alt="Thumbnail" src="{$theme-path}images/mime.png"/>
                                        </a>
                                    </xsl:otherwise>
                                </xsl:choose>
                            
                            
                           
                        </xsl:when>
                        <xsl:otherwise>
                            
                    <img data-original-title="No existen archivos asociados, solo puede ver los metadatos" data-toggle="tooltip" class="media-object" height="120" width="90" alt="Thumbnail" src="{$theme-path}images/mime.png"/>
                    
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:otherwise>
            </xsl:choose>
        
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-abstract">
        <xsl:if test="dim:field[@element='description' and @qualifier='abstract']">
            <dl class="descripcion">
                <dt><i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text></dt>
                <dd>
                    <xsl:for-each select="dim:field[@element='description' and @qualifier='abstract']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </dd>
            </dl>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors">
        
        <xsl:choose>
                        <xsl:when test="dim:field[@element='contributor' and @qualifier='entity']">
                            <dl>
                            <dt><xsl:text>Autor Institucional: </xsl:text></dt>
                            <dd>
                            <xsl:for-each select="dim:field[@element='contributor' and @qualifier='entity']">
                                
                                
                                
                                <a>
                        <xsl:attribute name="href">
                                    <xsl:value-of
                                       select="concat($context-path,'/discover?filtertype=entity&amp;filter_relational_operator=equals&amp;filter=')"/>
                                    <xsl:copy-of select="./node()"/>
                        </xsl:attribute>
                    <xsl:copy-of select="./node()"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='contributor' and @qualifier='entity']) != 0">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                    </a>
                                
                                
                                
                                
                                
                            </xsl:for-each>
                            </dd>
                            </dl>
                        </xsl:when>
                        
                    </xsl:choose>
                    
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='category' and @qualifier='document']">
                            <dl>
                            <dt><xsl:text>Tipo de Estudio: </xsl:text></dt>
                            <dd>
                            <xsl:for-each select="dim:field[@element='category' and @qualifier='document']">
                                
                                
                                
                                <a>
                        <xsl:attribute name="href">
                                    <xsl:value-of
                                       select="concat($context-path,'/discover?filtertype=category&amp;filter_relational_operator=equals&amp;filter=')"/>
                                    <xsl:copy-of select="./node()"/>
                        </xsl:attribute>
                    <xsl:copy-of select="./node()"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='category' and @qualifier='document']) != 0">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                    </a>
                                
                                
                                
                                
                                
                            </xsl:for-each>
                            </dd>
                            </dl>
                        </xsl:when>
                        
<!--                        <xsl:otherwise>
                            <dl>
                            <dt><xsl:text>Autor: </xsl:text></dt>
                            <dd>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                            </dd>
                            </dl>
                        </xsl:otherwise>-->
                    </xsl:choose>
                    
                    
                    
<!--                    <xsl:choose>
                        <xsl:when test="dim:field[@element='source' and @qualifier='entity']">
                            <dl>
                            <dt><xsl:text>Fuente del Recurso: </xsl:text></dt>
                            <dd>
                            <xsl:for-each select="dim:field[@element='source' and @qualifier='entity']">
                                

                                
                                <a>
                        <xsl:attribute name="href">
                                    <xsl:value-of
                                       select="concat($context-path,'/discover?filtertype=fuente&amp;filter_relational_operator=equals&amp;filter=')"/>
                                    <xsl:copy-of select="./node()"/>
                        </xsl:attribute>
                    <xsl:copy-of select="./node()"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='source' and @qualifier='entity']) != 0">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                    </a>
                                
                            </xsl:for-each>
                            </dd>
                            </dl>
                        </xsl:when>
                    </xsl:choose>-->
        
        
<!--        <xsl:if test="dim:field[@element='contributor'][@qualifier='author' and descendant::text()] or dim:field[@element='creator' and descendant::text()] or dim:field[@element='contributor' and descendant::text()]">
            <dl>
                <dt><i18n:text>xmlui.dri2xhtml.METS-1.0.item-author</i18n:text><xsl:text>: </xsl:text></dt>
                <dd>
                <xsl:choose>
                    <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of
                                       select="concat($context-path,'/discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=')"/>
                                    <xsl:copy-of select="./node()"/>
                                </xsl:attribute>
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                            </a>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='creator']">
                        <xsl:for-each select="dim:field[@element='creator']">
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of
                                       select="concat($context-path,'/discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=')"/>
                                    <xsl:copy-of select="./node()"/>
                                </xsl:attribute>
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                            </a>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='contributor']">
                        <xsl:for-each select="dim:field[@element='contributor']">
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of
                                       select="concat($context-path,'/discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=')"/>
                                    <xsl:copy-of select="./node()"/>
                        </xsl:attribute>
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                            </a>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
                </dd>
            </dl>
        </xsl:if>-->
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors-entry">
        <div>
            <xsl:if test="@authority">
                <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="node()"/>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-URI">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='uri' and descendant::text()]">
            <dl>
                <dt>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-uri</i18n:text>
                    <xsl:text>: </xsl:text>
                </dt>
                
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='uri']">
                        <dd>
                        <a id="handle">
                            <xsl:attribute name="href">
                                <xsl:copy-of select="./node()"/>
                            </xsl:attribute>
                            <xsl:copy-of select="./node()"/>
                        </a>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                        </dd>
                    </xsl:for-each>
                
            </dl>
                
                
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-date">
        <xsl:if test="dim:field[@element='date' and @qualifier='issued' and descendant::text()]">
            <dl>
                <dt>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text><xsl:text>: </xsl:text>
                </dt>
                
                <xsl:for-each select="dim:field[@element='date' and @qualifier='issued']">
                    <dd>
                    <a>
                        <xsl:attribute name="href">
                                    <xsl:value-of
                                       select="concat($context-path,'/discover?filtertype=dateIssued&amp;filter_relational_operator=equals&amp;filter=')"/>
                                    <xsl:copy-of select="substring(./node(),1,10)"/>
                        </xsl:attribute>
                    <xsl:copy-of select="substring(./node(),1,10)"/>
                    </a>
                    <xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='issued']) != 0">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                    </dd>
                </xsl:for-each>
            </dl>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="itemSummaryView-DIM-ministerio">
        <xsl:if test="dim:field[@element='source' and @qualifier='ministerio']">
            <dl>
                <dt>
                    <xsl:text>Ministerio: </xsl:text>
                </dt>
                
                <xsl:for-each select="dim:field[@element='source' and @qualifier='ministerio']">
                    <dd>
                    <a>
                        <xsl:attribute name="href">
                                    <xsl:value-of
                                       select="concat($context-path,'/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=')"/>
                                    <xsl:copy-of select="./node()"/>
                        </xsl:attribute>
                    <xsl:copy-of select="./node()"/>
                    </a>
                    <xsl:if test="count(following-sibling::dim:field[@element='source' and @qualifier='ministerio']) != 0">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                    </dd>
                </xsl:for-each>
            </dl>
        </xsl:if>
    </xsl:template>
    
<!--    <xsl:template name="itemSummaryView-DIM-fuente">
        <xsl:if test="dim:field[@element='source' and @qualifier='entity']">
            <dl>
                <dt>
                    <xsl:text>Fuente del Recurso: </xsl:text>
                </dt>
                
                <xsl:for-each select="dim:field[@element='source' and @qualifier='entity']">
                    <dd>
                    <a>
                        <xsl:attribute name="href">
                                    <xsl:value-of
                                       select="concat($context-path,'/discover?filtertype=fuente&amp;filter_relational_operator=equals&amp;filter=')"/>
                                    <xsl:copy-of select="./node()"/>
                        </xsl:attribute>
                    <xsl:copy-of select="./node()"/>
                    </a>
                    <xsl:if test="count(following-sibling::dim:field[@element='source' and @qualifier='entity']) != 0">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                    </dd>
                </xsl:for-each>
            </dl>
        </xsl:if>
    </xsl:template>-->

    <xsl:template name="itemSummaryView-show-full">
            
   
            <a data-original-title="Ver todos los metadatos técnicos" data-placement="bottom" data-toggle="tooltip" class="btn btn-primary t-data">
                <xsl:attribute name="href"><xsl:value-of select="$ds_item_view_toggle_url"/></xsl:attribute>
                
                <i18n:text>xmlui.ArtifactBrowser.ItemViewer.show_full</i18n:text>
            </a>&#160;
            <a id="boton-handle" data-placement="bottom" data-original-title="Copiar URI Handle" data-toggle="tooltip" onclick="copiarAlPortapapeles('handle')" class="btn btn-primary"><i class="fa fa-files-o" aria-hidden="true">&#160;</i> <span class="hidden-xs">Copiar</span> URI Handle</a>
    </xsl:template>

    <xsl:template name="itemSummaryView-collections">
        <xsl:if test="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']">
            <dl class="simple-item-view-collections item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.mirage2.itemSummaryView.Collections</i18n:text>
                </h5>
                <xsl:apply-templates select="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']/dri:reference"/>
            </dl>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section">
        <xsl:choose>
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <div class="item-page-field-wrapper table word-break">
<!--                    <h5>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                    </h5>-->

                    <xsl:variable name="label-1">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.1')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.1')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>label</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="label-2">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.2')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.2')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>title</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>

                    <xsl:for-each select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                        <xsl:call-template name="itemSummaryView-DIM-file-section-entry">
                            <xsl:with-param name="href" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                            <xsl:with-param name="mimetype" select="@MIMETYPE" />
                            <xsl:with-param name="label-1" select="$label-1" />
                            <xsl:with-param name="label-2" select="$label-2" />
                            <xsl:with-param name="title" select="mets:FLocat[@LOCTYPE='URL']/@xlink:title" />
                            <xsl:with-param name="label" select="mets:FLocat[@LOCTYPE='URL']/@xlink:label" />
                            <xsl:with-param name="size" select="@SIZE" />
                        </xsl:call-template>
                    </xsl:for-each>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="//mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemSummaryView-DIM" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section-entry">
        <xsl:param name="href" />
        <xsl:param name="mimetype" />
        <xsl:param name="label-1" />
        <xsl:param name="label-2" />
        <xsl:param name="title" />
        <xsl:param name="label" />
        <xsl:param name="size" />
        
        <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
        <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
        
        
        <a href="{$href}" style="margin-top: 20px;" class="btn btn-primary" data-toggle="tooltip" data-placement="left" title="">
            <xsl:attribute name="data-original-title">
                <xsl:choose>
                    <xsl:when test="$size &lt; 1024">
                        <xsl:value-of select="$size"/>
                        <xsl:text> Bytes</xsl:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024">
                        <xsl:value-of select="substring(string($size div 1024),1,5)"/>
                        <xsl:text> Kb</xsl:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024 * 1024">
                        <xsl:value-of select="substring(string($size div (1024 * 1024)),1,5)"/>
                        <xsl:text> Mb</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring(string($size div (1024 * 1024 * 1024)),1,5)"/>
                        <xsl:text> Gb</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            
            <i class="fa fa-eye" aria-hidden="true"></i> Visualizar</a>
        <a href="{$href}" class="btn btn-primary" data-toggle="tooltip" data-placement="left" title="" download="">
            <xsl:attribute name="data-original-title">
                <xsl:choose>
                    <xsl:when test="$size &lt; 1024">
                        <xsl:value-of select="$size"/>
                        <xsl:text> Bytes</xsl:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024">
                        <xsl:value-of select="substring(string($size div 1024),1,5)"/>
                        <xsl:text> Kb</xsl:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024 * 1024">
                        <xsl:value-of select="substring(string($size div (1024 * 1024)),1,5)"/>
                        <xsl:text> Mb</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring(string($size div (1024 * 1024 * 1024)),1,5)"/>
                        <xsl:text> Gb</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <i class="fa fa-download" aria-hidden="true"></i> Descargar</a>
        <dd class="size">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                </xsl:attribute>
                <xsl:call-template name="getFileIcon">
                    <xsl:with-param name="mimetype">
                        <xsl:value-of select="substring-before($mimetype,'/')"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="contains($label-1, 'label') and string-length($label)!=0">
                        <xsl:value-of select="$label"/>
                    </xsl:when>
                    <xsl:when test="contains($label-1, 'title') and string-length($title)!=0">
                        <xsl:value-of select="$title"/>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'label') and string-length($label)!=0">
                        <xsl:value-of select="$label"/>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'title') and string-length($title)!=0">
                        <xsl:value-of select="$title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before($mimetype,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains($mimetype,';')">
                                        <xsl:value-of select="substring-before(substring-after($mimetype,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> (</xsl:text>
                <xsl:choose>
                    <xsl:when test="$size &lt; 1024">
                        <xsl:value-of select="$size"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024">
                        <xsl:value-of select="substring(string($size div 1024),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024 * 1024">
                        <xsl:value-of select="substring(string($size div (1024 * 1024)),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring(string($size div (1024 * 1024 * 1024)),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>)</xsl:text>
            </a>
        </dd>
    </xsl:template>

    <xsl:template match="dim:dim" mode="itemDetailView-DIM">
        <xsl:call-template name="itemSummaryView-DIM-title"/>
        <div class="ds-table-responsive">
            <table class="ds-includeSet-table detailtable table table-striped table-hover">
                <xsl:apply-templates mode="itemDetailView-DIM"/>
            </table>
        </div>

        <span class="Z3988">
            <xsl:attribute name="title">
                 <xsl:call-template name="renderCOinS"/>
            </xsl:attribute>
            &#xFEFF; <!-- non-breaking space to force separating the end tag -->
        </span>
        <xsl:copy-of select="$SFXLink" />
    </xsl:template>

    <xsl:template match="dim:field" mode="itemDetailView-DIM">
            <tr>
                <xsl:attribute name="class">
                    <xsl:text>ds-table-row </xsl:text>
                    <xsl:if test="(position() div 2 mod 2 = 0)">even </xsl:if>
                    <xsl:if test="(position() div 2 mod 2 = 1)">odd </xsl:if>
                </xsl:attribute>
                <td class="label-cell">
                    <xsl:value-of select="./@mdschema"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="./@element"/>
                    <xsl:if test="./@qualifier">
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="./@qualifier"/>
                    </xsl:if>
                </td>
            <td class="word-break">
              <xsl:copy-of select="./node()"/>
            </td>
                <td><xsl:value-of select="./@language"/></td>
            </tr>
    </xsl:template>

    <!-- don't render the item-view-toggle automatically in the summary view, only when it gets called -->
    <xsl:template match="dri:p[contains(@rend , 'item-view-toggle') and
        (preceding-sibling::dri:referenceSet[@type = 'summaryView'] or following-sibling::dri:referenceSet[@type = 'summaryView'])]">
    </xsl:template>

    <!-- don't render the head on the item view page -->
    <xsl:template match="dri:div[@n='item-view']/dri:head" priority="5">
    </xsl:template>

   <xsl:template match="mets:fileGrp[@USE='CONTENT']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
            <xsl:choose>
                <!-- If one exists and it's of text/html MIME type, only display the primary bitstream -->
                <xsl:when test="mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/html'">
                    <xsl:apply-templates select="mets:file[@ID=$primaryBitstream]">
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:when>
                <!-- Otherwise, iterate over and display all of them -->
                <xsl:otherwise>
                    <xsl:apply-templates select="mets:file">
                     	<!--Do not sort any more bitstream order can be changed-->
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>

   <xsl:template match="mets:fileGrp[@USE='LICENSE']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
            <xsl:apply-templates select="mets:file">
                        <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
        <div class="file-wrapper row">
            <div class="col-xs-6 col-sm-3">
                <div class="thumbnail">
                    <a class="image-link">
                        <xsl:attribute name="href">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                        mets:file[@GROUPID=current()/@GROUPID]">
                                <img class="img-thumbnail" alt="Thumbnail">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                    mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                    </xsl:attribute>
                                </img>
                            </xsl:when>
                            <xsl:otherwise>
                                <img class="img-thumbnail" alt="Thumbnail">
                                    <xsl:attribute name="data-src">
                                        <xsl:text>holder.js/100%x</xsl:text>
                                        <xsl:value-of select="$thumbnail.maxheight"/>
                                        <xsl:text>/text:No hay imagen disponible</xsl:text>
                                    </xsl:attribute>
                                </img>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                </div>
            </div>

            <div class="col-xs-6 col-sm-7">
                <dl class="file-metadata dl-horizontal">
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:attribute name="title">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        </xsl:attribute>
                        <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:title, 30, 5)"/>
                    </dd>
                <!-- File size always comes in bytes and thus needs conversion -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:choose>
                            <xsl:when test="@SIZE &lt; 1024">
                                <xsl:value-of select="@SIZE"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                <!-- Lookup File Type description in local messages.xml based on MIME Type.
         In the original DSpace, this would get resolved to an application via
         the Bitstream Registry, but we are constrained by the capabilities of METS
         and can't really pass that info through. -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains(@MIMETYPE,';')">
                                <xsl:value-of select="substring-before(substring-after(@MIMETYPE,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:with-param>
                        </xsl:call-template>
                    </dd>
                <!-- Display the contents of 'Description' only if bitstream contains a description -->
                <xsl:if test="mets:FLocat[@LOCTYPE='URL']/@xlink:label != ''">
                        <dt>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-description</i18n:text>
                            <xsl:text>:</xsl:text>
                        </dt>
                        <dd class="word-break">
                            <xsl:attribute name="title">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                            </xsl:attribute>
                            <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:label, 30, 5)"/>
                        </dd>
                </xsl:if>
                </dl>
            </div>

            <div class="file-link col-xs-6 col-xs-offset-6 col-sm-2 col-sm-offset-0">
                <xsl:choose>
                    <xsl:when test="@ADMID">
                        <xsl:call-template name="display-rights"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="view-open"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>

</xsl:template>

    <xsl:template name="view-open">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
            </xsl:attribute>
            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
        </a>
    </xsl:template>

    <xsl:template name="display-rights">
        <xsl:variable name="file_id" select="jstring:replaceAll(jstring:replaceAll(string(@ADMID), '_METSRIGHTS', ''), 'rightsMD_', '')"/>
        <xsl:variable name="rights_declaration" select="../../../mets:amdSec/mets:rightsMD[@ID = concat('rightsMD_', $file_id, '_METSRIGHTS')]/mets:mdWrap/mets:xmlData/rights:RightsDeclarationMD"/>
        <xsl:variable name="rights_context" select="$rights_declaration/rights:Context"/>
        <xsl:variable name="users">
            <xsl:for-each select="$rights_declaration/*">
                <xsl:value-of select="rights:UserName"/>
                <xsl:choose>
                    <xsl:when test="rights:UserName/@USERTYPE = 'GROUP'">
                       <xsl:text> (group)</xsl:text>
                    </xsl:when>
                    <xsl:when test="rights:UserName/@USERTYPE = 'INDIVIDUAL'">
                       <xsl:text> (individual)</xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="not ($rights_context/@CONTEXTCLASS = 'GENERAL PUBLIC') and ($rights_context/rights:Permissions/@DISPLAY = 'true')">
                <a href="{mets:FLocat[@LOCTYPE='URL']/@xlink:href}">
                    <img width="64" height="64" src="{concat($theme-path,'/images/Crystal_Clear_action_lock3_64px.png')}" title="Read access available for {$users}"/>
                    <!-- icon source: http://commons.wikimedia.org/wiki/File:Crystal_Clear_action_lock3.png -->
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="view-open"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getFileIcon">
        <xsl:param name="mimetype"/>
        <xsl:choose>
            <xsl:when test="$mimetype = 'application/pdf'">
                <img class="icono" src="{$theme-path}images/icons/png/pdf.png"/>
            </xsl:when>
            <xsl:when test="$mimetype='application/msword' or $mimetype='application/vnd.openxmlformats-officedocument.wordprocessingml.document' or $mimetype='text/richtext'">
                <img class="icono" src="{$theme-path}images/icons/png/doc.png"/>
            </xsl:when>
            <xsl:when test="$mimetype='application/vnd.ms-excel' or $mimetype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'">
                <img class="icono" src="{$theme-path}images/icons/png/xls.png"/>
            </xsl:when>
            <xsl:when test="$mimetype='image/png' or $mimetype='image/tiff' or $mimetype='image/x-ms-bmp' or $mimetype='image/gif' or $mimetype='image/jpeg'">
                <img class="icono" src="{$theme-path}images/icons/png/image.png"/>
            </xsl:when>
            <xsl:when test="$mimetype='video/mp4' or $mimetype='video/x-flv'">
                <img class="icono" src="{$theme-path}images/icons/png/video-file.png"/>
            </xsl:when>
            <xsl:when test="$mimetype='audio/mpeg'">
                <img class="icono" src="{$theme-path}images/icons/png/mp3.png"/>
            </xsl:when>
            <xsl:when test="$mimetype='application/zip'">
                <img class="icono" src="{$theme-path}images/icons/png/zip.png"/>
            </xsl:when>
            <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                <img class="icono" src="{$theme-path}images/icons/png/lock.png"/>
            </xsl:when>
            <xsl:otherwise>
                <img class="icono" src="{$theme-path}images/icons/png/file1.png"/>
            </xsl:otherwise>
        </xsl:choose>
        
        
        
        
        
        
        
<!--            <i aria-hidden="true">
                <xsl:attribute name="class">
                <xsl:text>glyphicon </xsl:text>
                <xsl:choose>
                    <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                        <xsl:text> glyphicon-lock</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> glyphicon-file</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                </xsl:attribute>
            </i>
        <xsl:text> </xsl:text>-->
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='CC-LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license_text']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_cc</i18n:text></a></li>
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license.txt']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_original_license</i18n:text></a></li>
    </xsl:template>

    <!--
    File Type Mapping template

    This maps format MIME Types to human friendly File Type descriptions.
    Essentially, it looks for a corresponding 'key' in your messages.xml of this
    format: xmlui.dri2xhtml.mimetype.{MIME Type}

    (e.g.) <message key="xmlui.dri2xhtml.mimetype.application/pdf">PDF</message>

    If a key is found, the translated value is displayed as the File Type (e.g. PDF)
    If a key is NOT found, the MIME Type is displayed by default (e.g. application/pdf)
    -->
    <xsl:template name="getFileTypeDesc">
        <xsl:param name="mimetype"/>

        <!--Build full key name for MIME type (format: xmlui.dri2xhtml.mimetype.{MIME type})-->
        <xsl:variable name="mimetype-key">xmlui.dri2xhtml.mimetype.<xsl:value-of select='$mimetype'/></xsl:variable>

        <!--Lookup the MIME Type's key in messages.xml language file.  If not found, just display MIME Type-->
        <i18n:text i18n:key="{$mimetype-key}"><xsl:value-of select="$mimetype"/></i18n:text>
    </xsl:template>
    
    <xsl:template name="segpres-reproducir">
        
        <xsl:choose>
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
        
                        
                        <xsl:variable name="label-1">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.1')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.1')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>label</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="label-2">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.2')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.2')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>title</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>
                    <dl>    
                    <xsl:for-each select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                        <xsl:variable name="href" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                        <xsl:variable name="title" select="mets:FLocat[@LOCTYPE='URL']/@xlink:title" />
                        <xsl:if test="@MIMETYPE='video/mp4' or @MIMETYPE='video/ogg' or @MIMETYPE='video/webm'">
<!--                           <dd>
                              <a href="{$href}">
                                 <i aria-hidden="true">
                                    <xsl:attribute name="class">
                                       <xsl:text>fa </xsl:text>
                                       <xsl:choose>
                                          <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                                             <xsl:text>fa-lock</xsl:text>
                                          </xsl:when>
                                          <xsl:otherwise>
                                             <xsl:text>fa-file-video-o</xsl:text>
                                          </xsl:otherwise>
                                       </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:attribute name="aria-hidden">
                                       <xsl:text>true</xsl:text>
                                    </xsl:attribute>
                                 </i>
                                 <xsl:text> </xsl:text>
                                 <xsl:value-of select="$title"/>
                              </a>
                           </dd>-->
                           <dd>
                              <video width="400" controls="">
                                 <source src="{$href}" type="video/mp4" codecs="avc1.4D401E, mp4a.40.2"/>
                                 <source src="{$href}" type="video/ogg" codecs="theora, vorbis"/>
                                 <source src="{$href}" type="video/webm" codecs="vp8.0, vorbis"/>
                              </video>
                           </dd>
                        </xsl:if>
                        <xsl:if test="@MIMETYPE='video/x-flv'">
<!--                           <dd>
                              <a href="{$href}">
                                 <i aria-hidden="true">
                                    <xsl:attribute name="class">
                                       <xsl:text>fa </xsl:text>
                                       <xsl:choose>
                                          <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                                             <xsl:text>fa-lock</xsl:text>
                                          </xsl:when>
                                          <xsl:otherwise>
                                             <xsl:text>fa-file-video-o</xsl:text>
                                          </xsl:otherwise>
                                       </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:attribute name="aria-hidden">
                                       <xsl:text>true</xsl:text>
                                    </xsl:attribute>
                                 </i>
                                 <xsl:text> </xsl:text>
                                 <xsl:value-of select="$title"/>
                              </a>
                           </dd>-->
                           <dd>
                              <object type="application/x-shockwave-flash" data="/themes/Mineduc-general/player/player.swf" width="400" height="200">
                                <param name="movie" value="/themes/Mineduc-general/player/player.swf" />
                                <param name="allowFullScreen" value="true" />
                                <param name="FlashVars" value="flv={$href}&amp;showstop=1&amp;showvolume=1&amp;showtime=1&amp;showfullscreen=1&amp;bgcolor1=5a5a5a&amp;bgcolor2=5a5a5a&amp;playercolor=5a5a5a&amp;showplayer=always&amp;showiconplay=1&amp;iconplaycolor=ffffff" />
                                <embed src="/themes/Mineduc-general/player/player.swf" PLUGINSPAGE="http://www.macromedia.com/go/getflashplayer"
                                TYPE="application/x-shockwave-flash" allowFullScreen="true" Flashvars="flv={$href}&amp;showstop=1&amp;showvolume=1&amp;showtime=1&amp;showfullscreen=1&amp;bgcolor1=5a5a5a&amp;bgcolor2=5a5a5a&amp;playercolor=5a5a5a&amp;showplayer=always&amp;showiconplay=1&amp;iconplaycolor=ffffff" />
                              </object>
                           </dd>
                        </xsl:if>
                        <xsl:if test="@MIMETYPE='audio/mpeg' or @MIMETYPE='audio/ogg'">
<!--                           <dd>
                              <a href="{$href}">
                                 <i aria-hidden="true">
                                    <xsl:attribute name="class">
                                       <xsl:text>fa </xsl:text>
                                       <xsl:choose>
                                          <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                                             <xsl:text>fa-lock</xsl:text>
                                          </xsl:when>
                                          <xsl:otherwise>
                                             <xsl:text>fa-file-video-o</xsl:text>
                                          </xsl:otherwise>
                                       </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:attribute name="aria-hidden">
                                       <xsl:text>true</xsl:text>
                                    </xsl:attribute>
                                 </i>
                                 <xsl:text> </xsl:text>
                                 <xsl:value-of select="$title"/>
                              </a>
                           </dd>-->
                           <dd>
                              <audio controls="">
                                 <source src="{$href}" type="audio/ogg"/>
                                 <source src="{$href}" type="audio/mpeg"/>
                              </audio>
                           </dd>
                        </xsl:if>
                     </xsl:for-each>
                        
                    </dl>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
