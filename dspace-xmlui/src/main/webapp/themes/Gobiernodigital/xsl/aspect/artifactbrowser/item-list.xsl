<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Rendering of a list of items (e.g. in a search or
    browse results page)

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
    xmlns:confman="org.dspace.core.ConfigurationManager"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util confman">

    <xsl:output indent="yes"/>

    <!--these templates are modfied to support the 2 different item list views that
    can be configured with the property 'xmlui.theme.mirage.item-list.emphasis' in dspace.cfg-->

    <xsl:template name="itemSummaryList-DIM">
        <xsl:variable name="itemWithdrawn" select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/@withdrawn" />

        <xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="$itemWithdrawn">
                    <xsl:value-of select="@OBJEDIT"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@OBJID"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="emphasis" select="confman:getProperty('xmlui.theme.mirage.item-list.emphasis')"/>
        <xsl:choose>
            <xsl:when test="'file' = $emphasis">


                <div class="media">
                    
                    <div class="media-left">
                        <xsl:apply-templates select="./mets:fileSec" mode="artifact-preview">
                            <xsl:with-param name="href" select="$href"/>
                        </xsl:apply-templates>
                    </div>

                    <div class="media-body">
                        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                             mode="itemSummaryList-DIM-metadata">
                            <xsl:with-param name="href" select="$href"/>
                        </xsl:apply-templates>
                    </div>

                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                     mode="itemSummaryList-DIM-metadata"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--handles the rendering of a single item in a list in file mode-->
    <!--handles the rendering of a single item in a list in metadata mode-->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM-metadata">
        <xsl:param name="href"/>
            <h4 class="media-heading">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$href"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title']">
                            <xsl:value-of select="substring(dim:field[@element='title'][1]/node(),1,100)"/>
                            <xsl:if test="string-length(dim:field[@element='title'][1]/node()) &gt; 100">
                                <xsl:text>...</xsl:text>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
<!--                <span class="Z3988">
                    <xsl:attribute name="title">
                        <xsl:call-template name="renderCOinS"/>
                    </xsl:attribute>
                    &#xFEFF;  non-breaking space to force separating the end tag 
                </span>-->
            </h4>
                
                        <xsl:choose>
                        <xsl:when test="dim:field[@element='contributor']">
                            <dl>
                            <dt><xsl:text>Autor: </xsl:text></dt>
                            <dd>
                            <xsl:for-each select="dim:field[@element='contributor']">
                                
<!--                                  <xsl:if test="@authority">
                                    <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                  </xsl:if>
                                  <xsl:copy-of select="node()"/>
                                
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>-->
                                
                                
                                
                                <a>
                        <xsl:attribute name="href">
                                    <xsl:value-of
                                       select="concat($context-path,'/discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=')"/>
                                    <xsl:copy-of select="./node()"/>
                        </xsl:attribute>
                    <xsl:copy-of select="./node()"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                    </a>
                                
                                
                                
                                
                                
                            </xsl:for-each>
                            </dd>
                            </dl>
                        </xsl:when>
                        
                        <xsl:otherwise>
                            <dl>
                            <dt><xsl:text>Autor: </xsl:text></dt>
                            <dd>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                            </dd>
                            </dl>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    
                    
                    
               
                
                <xsl:choose>
                        <xsl:when test="dim:field[@element='date' and @qualifier='issued']">
                            <dl>
                            <dt><xsl:text>Fecha de Publicación: </xsl:text></dt>
                            <dd>
                            <xsl:for-each select="dim:field[@element='date' and @qualifier='issued']">
                                

                                
                                <a>
                        <xsl:attribute name="href">
                                    <xsl:value-of
                                       select="concat($context-path,'/discover?filtertype=dateIssued&amp;filter_relational_operator=equals&amp;filter=')"/>
                                    <xsl:copy-of select="./node()"/>
                        </xsl:attribute>
                    <xsl:copy-of select="./node()"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='issued']) != 0">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                    </a>
                                
                            </xsl:for-each>
                            </dd>
                            </dl>
                        </xsl:when>
                    </xsl:choose>
                    
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='source' and @qualifier='ministerio']">
                            <dl>
                            <dt><xsl:text>Ministerio: </xsl:text></dt>
                            <dd>
                            <xsl:for-each select="dim:field[@element='source' and @qualifier='ministerio']">
                                

                                
                                <a>
                        <xsl:attribute name="href">
                                    <xsl:value-of
                                       select="concat($context-path,'/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=')"/>
                                    <xsl:copy-of select="./node()"/>
                        </xsl:attribute>
                    <xsl:copy-of select="./node()"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='source' and @qualifier='ministerio']) != 0">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                    </a>
                                
                            </xsl:for-each>
                            </dd>
                            </dl>
                        </xsl:when>
                    </xsl:choose>
                    
                    <xsl:choose>
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
                    </xsl:choose>
                
                
            
                <xsl:if test="dim:field[@element = 'description' and @qualifier='abstract']">
                <xsl:variable name="abstract" select="dim:field[@element = 'description' and @qualifier='abstract']/node()"/>
                <br/>
                <p class="desc">
                    <xsl:value-of select="substring($abstract, 1, 190)"/>
                </p>
            </xsl:if>
                
            
            
    </xsl:template>

    <xsl:template name="itemDetailList-DIM">
        <xsl:call-template name="itemSummaryList-DIM"/>
    </xsl:template>


    <xsl:template match="mets:fileSec" mode="artifact-preview">
        <xsl:param name="href"/>
        <xsl:variable name="mets" select="concat($url-principal,'/metadata/',$href,'/mets.xml')"/>
        <xsl:variable name="metadatos" select="document($mets)"/>
                    <a class="uestudios" href="{$href}">
                <xsl:choose>
                    <xsl:when test="$metadatos//mets:fileGrp[@USE='ORE']">
                        <xsl:variable name="ore" select="concat($url-principal,$metadatos//mets:FLocat/@xlink:href)"/>
                        <xsl:variable name="miniatura" select="document($ore)"/>
                        <xsl:variable name="thumbnail" select="$miniatura//oreatom:triples/rdf:Description[dcterms:description='THUMBNAIL']/@rdf:about"/>
                        <img class="media-object" alt="Thumbnail">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$thumbnail"/>
                                    </xsl:attribute>
                        </img>
                    </xsl:when>
                    <xsl:when test="mets:fileGrp[@USE='THUMBNAIL']">
                        <!-- Checking if Thumbnail is restricted and if so, show a restricted image --> 
                        <xsl:variable name="src">
                            <xsl:value-of select="mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="contains($src,'isAllowed=n')">
                                <div style="width: 100%; text-align: center">
                                    <i aria-hidden="true" class="glyphicon  glyphicon-lock"></i>
                                </div>
                            </xsl:when>
                            <xsl:otherwise>
                                <img class="media-object" alt="xmlui.mirage2.item-list.thumbnail" i18n:attr="alt">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$src"/>
                                    </xsl:attribute>
                                </img>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        
                       <xsl:choose>
                        <xsl:when test="$metadatos//mets:fileSec/mets:fileGrp[@USE='CONTENT']">
                            
                            
                            <xsl:variable name="mimetype" select="$metadatos//mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/@MIMETYPE"/>
                            
                            <xsl:choose>
                                    <xsl:when test="$mimetype = 'application/pdf'">
                                        
                                                <img class="media-object" src="{$theme-path}images/icons/png/pdf.png"/>
                                        
                                    </xsl:when>
                                    <xsl:when test="$mimetype='application/msword' or $mimetype='application/vnd.openxmlformats-officedocument.wordprocessingml.document' or $mimetype='text/richtext'">
                                        
                                                <img class="media-object" src="{$theme-path}images/icons/png/doc.png"/>
                                        
                                    </xsl:when>
                                    <xsl:when test="$mimetype='application/vnd.ms-excel' or $mimetype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'">
                                        
                                        <img class="media-object" src="{$theme-path}images/icons/png/xls.png"/>
                                     
                                    </xsl:when>
                                    <xsl:when test="$mimetype='image/png' or $mimetype='image/tiff' or $mimetype='image/x-ms-bmp' or $mimetype='image/gif' or $mimetype='image/jpeg'">
                                        
                                                <img class="media-object" src="{$theme-path}images/icons/png/image.png"/>
                                        
                                    </xsl:when>
                                    <xsl:when test="$mimetype='video/mp4' or $mimetype='video/x-flv'">
                                        
                                                <img class="media-object" src="{$theme-path}images/icons/png/video-file.png"/>
                                        
                                    </xsl:when>
                                    <xsl:when test="$mimetype='audio/mpeg'">
                                        
                                                <img class="media-object" src="{$theme-path}images/icons/png/mp3.png"/>
                                        
                                    </xsl:when>
                                    <xsl:when test="$mimetype='application/zip'">
                                        
                                                <img class="media-object" src="{$theme-path}images/icons/png/zip.png"/>
                                        
                                    </xsl:when>
                                    <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                                        
                                                <img class="media-object" src="{$theme-path}images/icons/png/lock.png"/>
                                        
                                    </xsl:when>
                                    <xsl:otherwise>
                                   
                                        
                                        <img class="media-object" height="120" width="90" alt="Thumbnail" src="{$theme-path}images/mime.png"/>
                                        
                                    </xsl:otherwise>
                                </xsl:choose>
                            
                            
                           
                        </xsl:when>
                        <xsl:otherwise>
                            
                    <img data-original-title="No existen archivos asociados a este item, solo puede ver los metadatos" data-toggle="tooltip" class="media-object" height="120" width="90" alt="Thumbnail" src="{$theme-path}images/mime.png"/>
                    
                        </xsl:otherwise>
                    </xsl:choose>
                        
                    </xsl:otherwise>
                </xsl:choose>
            </a>
    </xsl:template>




    <!--
        Rendering of a list of items (e.g. in a search or
        browse results page)

        Author: art.lowel at atmire.com
        Author: lieven.droogmans at atmire.com
        Author: ben at atmire.com
        Author: Alexey Maslov

    -->



        <!-- Generate the info about the item from the metadata section -->
        <xsl:template match="dim:dim" mode="itemSummaryList-DIM">
            <xsl:variable name="itemWithdrawn" select="@withdrawn" />
            <div class="artifact-description">
                <div class="artifact-title">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:choose>
                                <xsl:when test="$itemWithdrawn">
                                    <xsl:value-of select="ancestor::mets:METS/@OBJEDIT" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="ancestor::mets:METS/@OBJID" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="dim:field[@element='title']">
                                <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </div>
<!--                <span class="Z3988">
                    <xsl:attribute name="title">
                        <xsl:call-template name="renderCOinS"/>
                    </xsl:attribute>
                    &#xFEFF;  non-breaking space to force separating the end tag 
                </span>-->
                <div class="artifact-info">
                    <span class="author">
                        <xsl:choose>
                            <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                                <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                    <span>
                                        <xsl:if test="@authority">
                                            <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                        </xsl:if>
                                        <xsl:copy-of select="node()"/>
                                    </span>
                                    <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="dim:field[@element='creator']">
                                <xsl:for-each select="dim:field[@element='creator']">
                                    <xsl:copy-of select="node()"/>
                                    <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="dim:field[@element='contributor']">
                                <xsl:for-each select="dim:field[@element='contributor']">
                                    <xsl:copy-of select="node()"/>
                                    <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                    <xsl:text> </xsl:text>
                    <xsl:if test="dim:field[@element='date' and @qualifier='issued'] or dim:field[@element='publisher']">
                        <span class="publisher-date">
                            <xsl:text>(</xsl:text>
                            <xsl:if test="dim:field[@element='publisher']">
                                <span class="publisher">
                                    <xsl:copy-of select="dim:field[@element='publisher']/node()"/>
                                </span>
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <span class="date">
                                <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                            </span>
                            <xsl:text>)</xsl:text>
                        </span>
                    </xsl:if>
                </div>
            </div>
        </xsl:template>

</xsl:stylesheet>
