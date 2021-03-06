<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Main structure of the page, determines where
    header, footer, body, navigation are structurally rendered.
    Rendering of the header, footer, trail and alerts

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
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
                xmlns:confman="org.dspace.core.ConfigurationManager"
                xmlns:ore="http://www.openarchives.org/ore/terms/"
                xmlns:oreatom="http://www.openarchives.org/ore/atom/"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dcterms="http://purl.org/dc/terms/"
                exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc confman">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <!--
        Requested Page URI. Some functions may alter behavior of processing depending if URI matches a pattern.
        Specifically, adding a static page will need to override the DRI, to directly add content.
    -->
    <xsl:variable name="request-uri" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI']"/>
    
    
    
    <xsl:variable name="puerto">
	
	<xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverPort'] != 80">
		<xsl:value-of select="concat(':',/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverPort'])"/>
	</xsl:if>
	
	</xsl:variable>
	<xsl:variable name="url-completa">

	<xsl:value-of select="concat(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='scheme'],
	'://',/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName'],$puerto,'/',
	/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI'])"/>
	</xsl:variable>
	
        <xsl:variable name="url-principal">

	<xsl:value-of select="concat(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='scheme'],
	'://',/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName'],$puerto,/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)])"/>
	</xsl:variable>
        
        <xsl:variable name="total" select="document('http://localhost:8080/solr/search/select?q=search.resourcetype:2%20AND%20withdrawn:false&amp;sort=dc.date.accessioned_dt%20desc&amp;rows=6&amp;fl=handle&amp;fl=title&amp;fl=dc.date.issued&amp;fl=dc.description.abstract&amp;omitHeader=true')"/>
        
        <xsl:variable name="historico" select="document('http://localhost:8080/solr/search/select?q=search.resourcetype:2%20AND%20withdrawn:false&amp;sort=dc.date.issued_dt%20asc&amp;rows=4&amp;fl=handle&amp;fl=dc.date.issued&amp;omitHeader=true')"/>
        
        <xsl:variable name="repositoryID" select="/dri:document/dri:meta/dri:repositoryMeta/dri:repository/@repositoryID"/>
        
        <xsl:variable name="isitem" select="/dri:document/dri:body/dri:div[@id='aspect.artifactbrowser.ItemViewer.div.item-view']/@n"/>
    
    
    <!--
        The starting point of any XSL processing is matching the root element. In DRI the root element is document,
        which contains a version attribute and three top level elements: body, options, meta (in that order).

        This template creates the html document, giving it a head and body. A title and the CSS style reference
        are placed in the html head, while the body is further split into several divs. The top-level div
        directly under html body is called "ds-main". It is further subdivided into:
            "ds-header"  - the header div containing title, subtitle, trail and other front matter
            "ds-body"    - the div containing all the content of the page; built from the contents of dri:body
            "ds-options" - the div with all the navigation and actions; built from the contents of dri:options
            "ds-footer"  - optional footer div, containing misc information

        The order in which the top level divisions appear may have some impact on the design of CSS and the
        final appearance of the DSpace page. While the layout of the DRI schema does favor the above div
        arrangement, nothing is preventing the designer from changing them around or adding new ones by
        overriding the dri:document template.
    -->
    <xsl:template match="dri:document">

        <xsl:choose>
            <xsl:when test="not($isModal)">


            <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;
            </xsl:text>
            <xsl:text disable-output-escaping="yes">&lt;!--[if lt IE 7]&gt; &lt;html class=&quot;no-js lt-ie9 lt-ie8 lt-ie7&quot; lang=&quot;es&quot;&gt; &lt;![endif]--&gt;
            &lt;!--[if IE 7]&gt;    &lt;html class=&quot;no-js lt-ie9 lt-ie8&quot; lang=&quot;es&quot;&gt; &lt;![endif]--&gt;
            &lt;!--[if IE 8]&gt;    &lt;html class=&quot;no-js lt-ie9&quot; lang=&quot;es&quot;&gt; &lt;![endif]--&gt;
            &lt;!--[if gt IE 8]&gt;&lt;!--&gt; &lt;html class=&quot;no-js&quot; lang=&quot;es&quot;&gt; &lt;!--&lt;![endif]--&gt;
            </xsl:text>

                <!-- First of all, build the HTML head element -->

                <xsl:call-template name="buildHead"/>

                <!-- Then proceed to the body -->
                <body>
                    <!-- Prompt IE 6 users to install Chrome Frame. Remove this if you support IE 6.
                   chromium.org/developers/how-tos/chrome-frame-getting-started -->
                    <!--[if lt IE 7]><p class=chromeframe>Your browser is <em>ancient!</em> <a href="http://browsehappy.com/">Upgrade to a different browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">install Google Chrome Frame</a> to experience this site.</p><![endif]-->
                    <xsl:choose>
                        <xsl:when
                                test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='framing'][@qualifier='popup']">
                            <xsl:apply-templates select="dri:body/*"/>
                        </xsl:when>
                        <xsl:otherwise>
<!--                            <xsl:call-template name="buildHeader"/>
                            <xsl:call-template name="buildTrail"/>-->
                            <xsl:choose>
                                <xsl:when test="$request-uri =''">
                                    <xsl:call-template name="segpres-header-home"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="segpres-header"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:call-template name="buildTrail"/>
                            <!--javascript-disabled warning, will be invisible if javascript is enabled-->
                            <div id="no-js-warning-wrapper" class="hidden">
                                <div id="no-js-warning">
                                    <div class="notice failure">
                                        <xsl:text>JavaScript is disabled for your browser. Some features of this site may not work without it.</xsl:text>
                                    </div>
                                </div>
                            </div>
                            
                          
                            
                            
                            
                            <xsl:choose>
                                <xsl:when test="$request-uri =''">
                                    
                                     <div class="container">

                                <div class="row row-home" role="toolbar">
                                            <xsl:apply-templates select="*[not(self::dri:options)]"/>
                                            <xsl:call-template name="segpres-ministerios"/>
                                            <xsl:call-template name="segpres-tipodocumento"/>
                                            <xsl:call-template name="segpres-ultimos"/>


                                </div>
                                
                         </div>

                           
                                </xsl:when>
                                <xsl:when test="starts-with($request-uri, 'handle')">

                            <!--<div id="main-container" class="container">-->

                                <div class="row-offcanvas row-offcanvas-right ficha">
                                    <div class="container">
                                        <div class="col-xs-12 col-sm-8">
                                            <div id="container-floating" class="visible-xs">
              <div id="floating-button" data-toggle="offcanvas">
                <p class="menu"><i class="fa fa-indent" aria-hidden="true"></i></p>
              </div>
            </div>
                                            <xsl:apply-templates select="*[not(self::dri:options)]"/>

<!--                                            <div class="visible-xs visible-sm">
                                                <xsl:call-template name="buildFooter"/>
                                            </div>-->
                                        </div>
                                        <div class="col-xs-6 col-sm-4 sidebar-offcanvas" id="sidebar" role="navigation">
                                            <xsl:apply-templates select="dri:options"/>
                                        </div>

                                    </div>
                                    <xsl:call-template name="segpres-footer"/>
                                </div>
                                
                                

                         
                         
                                </xsl:when>
                                
                                
                                <xsl:otherwise>
                                    
                                     <!--<div id="main-container" class="container">-->

                                <div class="row-offcanvas row-offcanvas-right ficha">
                                    <div class="container">
                                        <div class="search-list col-xs-12 col-sm-8">
                                            <div id="container-floating" class="visible-xs">
              <div id="floating-button" data-toggle="offcanvas">
                <p class="menu"><i class="fa fa-indent" aria-hidden="true"></i></p>
              </div>
            </div>
                                            <xsl:apply-templates select="*[not(self::dri:options)]"/>

<!--                                            <div class="visible-xs visible-sm">
                                                <xsl:call-template name="buildFooter"/>
                                            </div>-->
                                        </div>
                                        <div class="col-xs-6 col-sm-4 sidebar-offcanvas" id="sidebar" role="navigation">
                                            <xsl:apply-templates select="dri:options"/>
                                        </div>

                                    </div>
                                    <xsl:call-template name="segpres-footer"/>
                                </div>
                                
                    
                                   
                                    
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:choose>
                                <xsl:when test="$request-uri = ''">
                                    <xsl:call-template name="segpres-footer"/>
                                </xsl:when>
                            </xsl:choose>

                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- Javascript at the bottom for fast page loading -->
                    <xsl:call-template name="addJavascript"/>
                </body>
                <xsl:text disable-output-escaping="yes">&lt;/html&gt;</xsl:text>

            </xsl:when>
            <xsl:otherwise>
                <!-- This is only a starting point. If you want to use this feature you need to implement
                JavaScript code and a XSLT template by yourself. Currently this is used for the DSpace Value Lookup -->
                <xsl:apply-templates select="dri:body" mode="modal"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- The HTML head element contains references to CSS as well as embedded JavaScript code. Most of this
    information is either user-provided bits of post-processing (as in the case of the JavaScript), or
    references to stylesheets pulled directly from the pageMeta element. -->
    <xsl:template name="buildHead">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>

            <!-- Use the .htaccess and remove these lines to avoid edge case issues.
             More info: h5bp.com/i/378 -->
            <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>

            <!-- Mobile viewport optimized: h5bp.com/viewport -->
            <meta name="viewport" content="width=device-width,initial-scale=1"/>

            <link rel="shortcut icon">
                <xsl:attribute name="href">
                    <xsl:value-of select="$theme-path"/>
                    <xsl:text>images/favicon.ico</xsl:text>
                </xsl:attribute>
            </link>
            <link rel="apple-touch-icon">
                <xsl:attribute name="href">
                    <xsl:value-of select="$theme-path"/>
                    <xsl:text>images/apple-touch-icon.png</xsl:text>
                </xsl:attribute>
            </link>

            <meta name="Generator">
                <xsl:attribute name="content">
                    <xsl:text>DSpace</xsl:text>
                    <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']"/>
                    </xsl:if>
                </xsl:attribute>
            </meta>
            
            <meta name="author" content="Prodigio Consultores, http://prodigioconsultores.com"/>

            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='ROBOTS'][not(@qualifier)]">
                <meta name="ROBOTS">
                    <xsl:attribute name="content">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='ROBOTS']"/>
                    </xsl:attribute>
                </meta>
            </xsl:if>

            <!-- Add stylesheets -->

            <!--TODO figure out a way to include these in the concat & minify-->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='stylesheet']">
                <link rel="stylesheet" type="text/css">
                    <xsl:attribute name="media">
                        <xsl:value-of select="@qualifier"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$theme-path"/>
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </link>
            </xsl:for-each>

            <link rel="stylesheet" href="{concat($theme-path, 'styles/main.css')}"/>
            <link rel="stylesheet" href="{concat($theme-path, 'styles/segpres-style.css')}"/>
            <link rel="stylesheet" href="{concat($theme-path, 'styles/ie10-viewport-bug-workaround.css')}"/>
            <link rel="stylesheet" href="{concat($theme-path, 'styles/offcanvas.css')}"/>
            <link rel="stylesheet" href="{concat($theme-path, 'styles/slick.css')}"/>
            <link rel="stylesheet" href="{concat($theme-path, 'styles/slick-theme.css')}"/>
            
            <link href="https://fonts.googleapis.com/css?family=Roboto" rel="stylesheet"/>
            
            
            <xsl:choose>
                <xsl:when test="$request-uri !=''">
                    <link href="https://fonts.googleapis.com/css?family=Roboto+Slab:700, 400" rel="stylesheet"/>
                    <link href="https://fonts.googleapis.com/css?family=Roboto:400,700" rel="stylesheet"/>
                    
                </xsl:when>
                <xsl:otherwise>
                    <link href="https://fonts.googleapis.com/css?family=Roboto+Slab:700" rel="stylesheet"/>

                </xsl:otherwise>
            </xsl:choose>
            
            
            <script src="https://use.fontawesome.com/2014d578b9.js"></script>

            <!-- Add syndication feeds -->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']">
                <link rel="alternate" type="application">
                    <xsl:attribute name="type">
                        <xsl:text>application/</xsl:text>
                        <xsl:value-of select="@qualifier"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </link>
            </xsl:for-each>

            <!--  Add OpenSearch auto-discovery link -->
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']">
                <link rel="search" type="application/opensearchdescription+xml">
                    <xsl:attribute name="href">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='scheme']"/>
                        <xsl:text>://</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName']"/>
                        <xsl:text>:</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverPort']"/>
                        <xsl:value-of select="$context-path"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='autolink']"/>
                    </xsl:attribute>
                    <xsl:attribute name="title" >
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']"/>
                    </xsl:attribute>
                </link>
            </xsl:if>

            <!-- The following javascript removes the default text of empty text areas when they are focused on or submitted -->
            <!-- There is also javascript to disable submitting a form when the 'enter' key is pressed. -->
            <script>
                //Clear default text of empty text areas on focus
                function tFocus(element)
                {
                if (element.value == '<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){element.value='';}
                }
                //Clear default text of empty text areas on submit
                function tSubmit(form)
                {
                var defaultedElements = document.getElementsByTagName("textarea");
                for (var i=0; i != defaultedElements.length; i++){
                if (defaultedElements[i].value == '<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){
                defaultedElements[i].value='';}}
                }
                //Disable pressing 'enter' key to submit a form (otherwise pressing 'enter' causes a submission to start over)
                function disableEnterKey(e)
                {
                var key;

                if(window.event)
                key = window.event.keyCode;     //Internet Explorer
                else
                key = e.which;     //Firefox and Netscape

                if(key == 13)  //if "Enter" pressed, then disable!
                return false;
                else
                return true;
                }
            </script>

            <xsl:text disable-output-escaping="yes">&lt;!--[if lt IE 9]&gt;
                &lt;script src="</xsl:text><xsl:value-of select="concat($theme-path, 'vendor/html5shiv/dist/html5shiv.js')"/><xsl:text disable-output-escaping="yes">"&gt;&#160;&lt;/script&gt;
                &lt;script src="</xsl:text><xsl:value-of select="concat($theme-path, 'vendor/respond/dest/respond.min.js')"/><xsl:text disable-output-escaping="yes">"&gt;&#160;&lt;/script&gt;
                &lt;![endif]--&gt;</xsl:text>

            <!-- Modernizr enables HTML5 elements & feature detects -->
            <script src="{concat($theme-path, 'vendor/modernizr/modernizr.js')}">&#160;</script>

            <!-- Add the title in -->
            <xsl:variable name="page_title" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title'][last()]" />
            <title>
                <xsl:choose>
                    <xsl:when test="starts-with($request-uri, 'page/about')">
                        <i18n:text>xmlui.mirage2.page-structure.aboutThisRepository</i18n:text>
                    </xsl:when>
                    <xsl:when test="not($page_title)">
                        <xsl:text>  </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$page_title/node()" />
                    </xsl:otherwise>
                </xsl:choose>
            </title>

            <!-- Head metadata in item pages -->
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']"
                              disable-output-escaping="yes"/>
            </xsl:if>

            <!-- Add all Google Scholar Metadata values -->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[substring(@element, 1, 9) = 'citation_']">
                <meta name="{@element}" content="{.}"></meta>
            </xsl:for-each>

            <!-- Add MathJAX JS library to render scientific formulas-->
            <xsl:if test="confman:getProperty('webui.browse.render-scientific-formulas') = 'true'">
                <script type="text/x-mathjax-config">
                    MathJax.Hub.Config({
                      tex2jax: {
                        inlineMath: [['$','$'], ['\\(','\\)']],
                        ignoreClass: "detail-field-data|detailtable|exception"
                      },
                      TeX: {
                        Macros: {
                          AA: '{\\mathring A}'
                        }
                      }
                    });
                </script>
                <script type="text/javascript" src="//cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">&#160;</script>
            </xsl:if>

        </head>
    </xsl:template>


    <!-- The header (distinct from the HTML head element) contains the title, subtitle, login box and various
        placeholders for header images -->
    <xsl:template name="buildHeader">


        <header>
            <div class="navbar navbar-default navbar-static-top" role="navigation">
                <div class="container">
                    <div class="navbar-header">

                        <button type="button" class="navbar-toggle" data-toggle="offcanvas">
                            <span class="sr-only">
                                <i18n:text>xmlui.mirage2.page-structure.toggleNavigation</i18n:text>
                            </span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                        </button>

                        <a href="{$context-path}/" class="navbar-brand">
                            <img src="{$theme-path}images/DSpace-logo-line.svg" />
                        </a>


                        <div class="navbar-header pull-right visible-xs hidden-sm hidden-md hidden-lg">
                        <ul class="nav nav-pills pull-left ">

                            <xsl:if test="count(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='supportedLocale']) &gt; 1">
                                <li id="ds-language-selection-xs" class="dropdown">
                                    <xsl:variable name="active-locale" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='currentLocale']"/>
                                    <button id="language-dropdown-toggle-xs" href="#" role="button" class="dropdown-toggle navbar-toggle navbar-link" data-toggle="dropdown">
                                        <b class="visible-xs glyphicon glyphicon-globe" aria-hidden="true"/>
                                    </button>
                                    <ul class="dropdown-menu pull-right" role="menu" aria-labelledby="language-dropdown-toggle-xs" data-no-collapse="true">
                                        <xsl:for-each
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='supportedLocale']">
                                            <xsl:variable name="locale" select="."/>
                                            <li role="presentation">
                                                <xsl:if test="$locale = $active-locale">
                                                    <xsl:attribute name="class">
                                                        <xsl:text>disabled</xsl:text>
                                                    </xsl:attribute>
                                                </xsl:if>
                                                <a>
                                                    <xsl:attribute name="href">
                                                        <xsl:value-of select="$current-uri"/>
                                                        <xsl:text>?locale-attribute=</xsl:text>
                                                        <xsl:value-of select="$locale"/>
                                                    </xsl:attribute>
                                                    <xsl:value-of
                                                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='supportedLocale'][@qualifier=$locale]"/>
                                                </a>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </li>
                            </xsl:if>

                            <xsl:choose>
                                <xsl:when test="/dri:document/dri:meta/dri:userMeta/@authenticated = 'yes'">
                                    <li class="dropdown">
                                        <button class="dropdown-toggle navbar-toggle navbar-link" id="user-dropdown-toggle-xs" href="#" role="button"  data-toggle="dropdown">
                                            <b class="visible-xs glyphicon glyphicon-user" aria-hidden="true"/>
                                        </button>
                                        <ul class="dropdown-menu pull-right" role="menu"
                                            aria-labelledby="user-dropdown-toggle-xs" data-no-collapse="true">
                                            <li>
                                                <a href="{/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='url']}">
                                                    <i18n:text>xmlui.EPerson.Navigation.profile</i18n:text>
                                                </a>
                                            </li>
                                            <li>
                                                <a href="{/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='logoutURL']}">
                                                    <i18n:text>xmlui.dri2xhtml.structural.logout</i18n:text>
                                                </a>
                                            </li>
                                        </ul>
                                    </li>
                                </xsl:when>
                                <xsl:otherwise>
                                    <li>
                                        <form style="display: inline" action="{/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='loginURL']}" method="get">
                                            <button class="navbar-toggle navbar-link">
                                            <b class="visible-xs glyphicon glyphicon-user" aria-hidden="true"/>
                                            </button>
                                        </form>
                                    </li>
                                </xsl:otherwise>
                            </xsl:choose>
                        </ul>
                              </div>
                    </div>

                    <div class="navbar-header pull-right hidden-xs">
                        <ul class="nav navbar-nav pull-left">
                              <xsl:call-template name="languageSelection"/>
                        </ul>
                        <ul class="nav navbar-nav pull-left">
                            <xsl:choose>
                                <xsl:when test="/dri:document/dri:meta/dri:userMeta/@authenticated = 'yes'">
                                    <li class="dropdown">
                                        <a id="user-dropdown-toggle" href="#" role="button" class="dropdown-toggle"
                                           data-toggle="dropdown">
                                            <span class="hidden-xs">
                                                <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='firstName']"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='lastName']"/>
                                                &#160;
                                                <b class="caret"/>
                                            </span>
                                        </a>
                                        <ul class="dropdown-menu pull-right" role="menu"
                                            aria-labelledby="user-dropdown-toggle" data-no-collapse="true">
                                            <li>
                                                <a href="{/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='url']}">
                                                    <i18n:text>xmlui.EPerson.Navigation.profile</i18n:text>
                                                </a>
                                            </li>
                                            <li>
                                                <a href="{/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='logoutURL']}">
                                                    <i18n:text>xmlui.dri2xhtml.structural.logout</i18n:text>
                                                </a>
                                            </li>
                                        </ul>
                                    </li>
                                </xsl:when>
                                <xsl:otherwise>
                                    <li>
                                        <a href="{/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='loginURL']}">
                                            <span class="hidden-xs">
                                                <i18n:text>xmlui.dri2xhtml.structural.login</i18n:text>
                                            </span>
                                        </a>
                                    </li>
                                </xsl:otherwise>
                            </xsl:choose>
                        </ul>

                        <button data-toggle="offcanvas" class="navbar-toggle visible-sm" type="button">
                            <span class="sr-only"><i18n:text>xmlui.mirage2.page-structure.toggleNavigation</i18n:text></span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                        </button>
                    </div>
                </div>
            </div>

        </header>

    </xsl:template>


    <!-- The header (distinct from the HTML head element) contains the title, subtitle, login box and various
        placeholders for header images -->
    <xsl:template name="buildTrail">
        <!--<div class="trail-wrapper hidden-print">-->
            <!--<div class="container">-->
                <!--<div class="row">-->
                    <!--TODO-->
                    <!--<div class="col-xs-12">-->
                        <xsl:choose>
                            <xsl:when test="count(/dri:document/dri:meta/dri:pageMeta/dri:trail) > 1">
                                <ol class="breadcrumb dropdown visible-xs">
                                    
                                    <a id="trail-dropdown-toggle" href="#" role="button" class="dropdown-toggle"
                                       data-toggle="dropdown">
                                        <div class="breadcrumb container">
                                        <xsl:variable name="last-node"
                                                      select="/dri:document/dri:meta/dri:pageMeta/dri:trail[last()]"/>
                                        <xsl:choose>
                                            <xsl:when test="$last-node/i18n:*">
                                                <xsl:apply-templates select="$last-node/*"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:apply-templates select="$last-node/text()"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:text>&#160;</xsl:text>
                                        <b class="caret"/>
                                        </div>
                                    </a>
                                    
                                    
                                    <ul class="dropdown-menu" role="menu" aria-labelledby="trail-dropdown-toggle">
                                        <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"
                                                             mode="dropdown"/>
                                    </ul>
                                </ol>
                                <ol class="breadcrumb hidden-xs">
                                    <div class="breadcrumb container">
                                    <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"/>
                                    </div>
                                </ol>
                            </xsl:when>
                            <xsl:otherwise>
                                <ol class="breadcrumb">
                                    <div class="breadcrumb container">
                                    <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"/>
                                    </div>
                                </ol>
                            </xsl:otherwise>
                        </xsl:choose>
                    <!--</div>-->
                <!--</div>-->
            <!--</div>-->
        <!--</div>-->


    </xsl:template>

    <!--The Trail-->
    <xsl:template match="dri:trail">
        <!--put an arrow between the parts of the trail-->
        <li>
            <xsl:if test="position()=1">
                <i class="glyphicon glyphicon-home" aria-hidden="true"/>&#160;
            </xsl:if>
            <!-- Determine whether we are dealing with a link or plain text trail link -->
            <xsl:choose>
                <xsl:when test="./@target">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="./@target"/>
                        </xsl:attribute>
                        <xsl:apply-templates />
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">active</xsl:attribute>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>

    <xsl:template match="dri:trail" mode="dropdown">
        <!--put an arrow between the parts of the trail-->
        <li role="presentation">
            <!-- Determine whether we are dealing with a link or plain text trail link -->
            <xsl:choose>
                <xsl:when test="./@target">
                    <a role="menuitem">
                        <xsl:attribute name="href">
                            <xsl:value-of select="./@target"/>
                        </xsl:attribute>
                        <xsl:if test="position()=1">
                            <i class="glyphicon glyphicon-home" aria-hidden="true"/>&#160;
                        </xsl:if>
                        <xsl:apply-templates />
                    </a>
                </xsl:when>
                <xsl:when test="position() > 1 and position() = last()">
                    <xsl:attribute name="class">disabled</xsl:attribute>
                    <a role="menuitem" href="#">
                        <xsl:apply-templates />
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">active</xsl:attribute>
                    <xsl:if test="position()=1">
                        <i class="glyphicon glyphicon-home" aria-hidden="true"/>&#160;
                    </xsl:if>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>

    <!--The License-->
    <xsl:template name="cc-license">
        <xsl:param name="metadataURL"/>
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="$metadataURL"/>
            <xsl:text>?sections=dmdSec,fileSec&amp;fileGrpTypes=THUMBNAIL</xsl:text>
        </xsl:variable>

        <xsl:variable name="ccLicenseName"
                      select="document($externalMetadataURL)//dim:field[@element='rights']"
                />
        <xsl:variable name="ccLicenseUri"
                      select="document($externalMetadataURL)//dim:field[@element='rights'][@qualifier='uri']"
                />
        <xsl:variable name="handleUri">
            <xsl:for-each select="document($externalMetadataURL)//dim:field[@element='identifier' and @qualifier='uri']">
                <a>
                    <xsl:attribute name="href">
                        <xsl:copy-of select="./node()"/>
                    </xsl:attribute>
                    <xsl:copy-of select="./node()"/>
                </a>
                <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:if test="$ccLicenseName and $ccLicenseUri and contains($ccLicenseUri, 'creativecommons')">
            <div about="{$handleUri}" class="row">
            <div class="col-sm-3 col-xs-12">
                <a rel="license"
                   href="{$ccLicenseUri}"
                   alt="{$ccLicenseName}"
                   title="{$ccLicenseName}"
                        >
                    <xsl:call-template name="cc-logo">
                        <xsl:with-param name="ccLicenseName" select="$ccLicenseName"/>
                        <xsl:with-param name="ccLicenseUri" select="$ccLicenseUri"/>
                    </xsl:call-template>
                </a>
            </div> <div class="col-sm-8">
                <span>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.cc-license-text</i18n:text>
                    <xsl:value-of select="$ccLicenseName"/>
                </span>
            </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="cc-logo">
        <xsl:param name="ccLicenseName"/>
        <xsl:param name="ccLicenseUri"/>
        <xsl:variable name="ccLogo">
             <xsl:choose>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by/')">
                       <xsl:value-of select="'cc-by.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-sa/')">
                       <xsl:value-of select="'cc-by-sa.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nd/')">
                       <xsl:value-of select="'cc-by-nd.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nc/')">
                       <xsl:value-of select="'cc-by-nc.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nc-sa/')">
                       <xsl:value-of select="'cc-by-nc-sa.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nc-nd/')">
                       <xsl:value-of select="'cc-by-nc-nd.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/publicdomain/zero/')">
                       <xsl:value-of select="'cc-zero.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/publicdomain/mark/')">
                       <xsl:value-of select="'cc-mark.png'" />
                  </xsl:when>
                  <xsl:otherwise>
                       <xsl:value-of select="'cc-generic.png'" />
                  </xsl:otherwise>
             </xsl:choose>
        </xsl:variable>
        <img class="img-responsive">
             <xsl:attribute name="src">
                <xsl:value-of select="concat($theme-path,'/images/creativecommons/', $ccLogo)"/>
             </xsl:attribute>
             <xsl:attribute name="alt">
                 <xsl:value-of select="$ccLicenseName"/>
             </xsl:attribute>
        </img>
    </xsl:template>

    <!-- Like the header, the footer contains various miscellaneous text, links, and image placeholders -->
    <xsl:template name="buildFooter">
        <footer>
                <div class="row">
                    <hr/>
                    <div class="col-xs-7 col-sm-8">
                        <div>
                            <a href="http://www.dspace.org/" target="_blank">DSpace software</a> copyright&#160;&#169;&#160;2002-2016&#160; <a href="http://www.duraspace.org/" target="_blank">DuraSpace</a>
                        </div>
                        <div class="hidden-print">
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of
                                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                    <xsl:text>/contact</xsl:text>
                                </xsl:attribute>
                                <i18n:text>xmlui.dri2xhtml.structural.contact-link</i18n:text>
                            </a>
                            <xsl:text> | </xsl:text>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of
                                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                    <xsl:text>/feedback</xsl:text>
                                </xsl:attribute>
                                <i18n:text>xmlui.dri2xhtml.structural.feedback-link</i18n:text>
                            </a>
                        </div>
                    </div>
                    <div class="col-xs-5 col-sm-4 hidden-print">
                        <div class="pull-right">
                            <span class="theme-by">Theme by&#160;</span>
                            <br/>
                            <a title="Atmire NV" target="_blank" href="http://atmire.com">
                                <img alt="Atmire NV" src="{concat($theme-path, 'images/atmire-logo-small.svg')}"/>
                            </a>
                        </div>

                    </div>
                </div>
                <!--Invisible link to HTML sitemap (for search engines) -->
                <a class="hidden">
                    <xsl:attribute name="href">
                        <xsl:value-of
                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/htmlmap</xsl:text>
                    </xsl:attribute>
                    <xsl:text>&#160;</xsl:text>
                </a>
            <p>&#160;</p>
        </footer>
    </xsl:template>


    <!--
            The meta, body, options elements; the three top-level elements in the schema
    -->




    <!--
        The template to handle the dri:body element. It simply creates the ds-body div and applies
        templates of the body's child elements (which consists entirely of dri:div tags).
    -->
    <xsl:template match="dri:body">
        <!--<div>-->
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']">
                <div class="alert alert-warning">
                    <button type="button" class="close" data-dismiss="alert">&#215;</button>
                    <xsl:copy-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']/node()"/>
                </div>
            </xsl:if>

            <!-- Check for the custom pages -->
            <xsl:choose>
                <xsl:when test="starts-with($request-uri, 'page/about')">
                    <div class="hero-unit">
                        <h1><i18n:text>xmlui.mirage2.page-structure.heroUnit.title</i18n:text></h1>
                        <p><i18n:text>xmlui.mirage2.page-structure.heroUnit.content</i18n:text></p>
                    </div>
                </xsl:when>
                <!-- Otherwise use default handling of body -->
                <xsl:otherwise>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>

        <!--</div>-->
    </xsl:template>


    <!-- Currently the dri:meta element is not parsed directly. Instead, parts of it are referenced from inside
        other elements (like reference). The blank template below ends the execution of the meta branch -->
    <xsl:template match="dri:meta">
    </xsl:template>

    <!-- Meta's children: userMeta, pageMeta, objectMeta and repositoryMeta may or may not have templates of
        their own. This depends on the meta template implementation, which currently does not go this deep.
    <xsl:template match="dri:userMeta" />
    <xsl:template match="dri:pageMeta" />
    <xsl:template match="dri:objectMeta" />
    <xsl:template match="dri:repositoryMeta" />
    -->

    <xsl:template name="addJavascript">

        <script type="text/javascript"><xsl:text>
                         if(typeof window.publication === 'undefined'){
                            window.publication={};
                          };
                        window.publication.contextPath= '</xsl:text><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/><xsl:text>';</xsl:text>
            <xsl:text>window.publication.themePath= '</xsl:text><xsl:value-of select="$theme-path"/><xsl:text>';</xsl:text>
        </script>
        <!--TODO concat & minify!-->

        <script>
            <xsl:text>if(!window.DSpace){window.DSpace={};}window.DSpace.context_path='</xsl:text><xsl:value-of select="$context-path"/><xsl:text>';window.DSpace.theme_path='</xsl:text><xsl:value-of select="$theme-path"/><xsl:text>';</xsl:text>
        </script>

        <!--inject scripts.html containing all the theme specific javascript references
        that can be minified and concatinated in to a single file or separate and untouched
        depending on whether or not the developer maven profile was active-->
        <xsl:variable name="scriptURL">
            <xsl:text>cocoon://themes/</xsl:text>
            <!--we can't use $theme-path, because that contains the context path,
            and cocoon:// urls don't need the context path-->
            <xsl:value-of select="$pagemeta/dri:metadata[@element='theme'][@qualifier='path']"/>
            <xsl:text>scripts-dist.xml</xsl:text>
        </xsl:variable>
        <xsl:for-each select="document($scriptURL)/scripts/script">
            <script src="{$theme-path}{@src}">&#160;</script>
        </xsl:for-each>

        <!-- Add javascript specified in DRI -->
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][not(@qualifier)]">
            <script>
                <xsl:attribute name="src">
                    <xsl:value-of select="$theme-path"/>
                    <xsl:value-of select="."/>
                </xsl:attribute>&#160;</script>
        </xsl:for-each>

        <!-- add "shared" javascript from static, path is relative to webapp root-->
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][@qualifier='static']">
            <!--This is a dirty way of keeping the scriptaculous stuff from choice-support
            out of our theme without modifying the administrative and submission sitemaps.
            This is obviously not ideal, but adding those scripts in those sitemaps is far
            from ideal as well-->
            <xsl:choose>
                <xsl:when test="text() = 'static/js/choice-support.js'">
                    <script>
                        <xsl:attribute name="src">
                            <xsl:value-of select="$theme-path"/>
                            <xsl:text>js/choice-support.js</xsl:text>
                        </xsl:attribute>&#160;</script>
                </xsl:when>
                <xsl:when test="not(starts-with(text(), 'static/js/scriptaculous'))">
                    <script>
                        <xsl:attribute name="src">
                            <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                            <xsl:text>/</xsl:text>
                            <xsl:value-of select="."/>
                        </xsl:attribute>&#160;</script>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <!-- add setup JS code if this is a choices lookup page -->
        <xsl:if test="dri:body/dri:div[@n='lookup']">
            <xsl:call-template name="choiceLookupPopUpSetup"/>
        </xsl:if>

        <xsl:call-template name="addJavascript-google-analytics" />
    </xsl:template>

    <xsl:template name="addJavascript-google-analytics">
        <!-- Add a google analytics script if the key is present -->
        <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']">
            <script><xsl:text>
                (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
                (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
                m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
                })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

                ga('create', '</xsl:text><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']"/><xsl:text>', '</xsl:text><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName']"/><xsl:text>');
                ga('send', 'pageview');
            </xsl:text></script>
        </xsl:if>
    </xsl:template>

    <!--The Language Selection
        Uses a page metadata curRequestURI which was introduced by in /xmlui-mirage2/src/main/webapp/themes/Mirage2/sitemap.xmap-->
    <xsl:template name="languageSelection">
        <xsl:variable name="curRequestURI">
            <xsl:value-of select="substring-after(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='curRequestURI'],/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI'])"/>
        </xsl:variable>

        <xsl:if test="count(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='supportedLocale']) &gt; 1">
            <li id="ds-language-selection" class="dropdown">
                <xsl:variable name="active-locale" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='currentLocale']"/>
                <a id="language-dropdown-toggle" href="#" role="button" class="dropdown-toggle" data-toggle="dropdown">
                    <span class="hidden-xs">
                        <xsl:value-of
                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='supportedLocale'][@qualifier=$active-locale]"/>
                        <xsl:text>&#160;</xsl:text>
                        <b class="caret"/>
                    </span>
                </a>
                <ul class="dropdown-menu pull-right" role="menu" aria-labelledby="language-dropdown-toggle" data-no-collapse="true">
                    <xsl:for-each
                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='supportedLocale']">
                        <xsl:variable name="locale" select="."/>
                        <li role="presentation">
                            <xsl:if test="$locale = $active-locale">
                                <xsl:attribute name="class">
                                    <xsl:text>disabled</xsl:text>
                                </xsl:attribute>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="$curRequestURI"/>
                                    <xsl:call-template name="getLanguageURL"/>
                                    <xsl:value-of select="$locale"/>
                                </xsl:attribute>
                                <xsl:value-of
                                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='supportedLocale'][@qualifier=$locale]"/>
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </li>
        </xsl:if>
    </xsl:template>

    <!-- Builds the Query String part of the language URL. If there already is an existing query string
like: ?filtertype=subject&filter_relational_operator=equals&filter=keyword1 it appends the locale parameter with the ampersand (&) symbol -->
    <xsl:template name="getLanguageURL">
        <xsl:variable name="queryString" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='queryString']"/>
        <xsl:choose>
            <!-- There allready is a query string so append it and the language argument -->
            <xsl:when test="$queryString != ''">
                <xsl:text>?</xsl:text>
                <xsl:choose>
                    <xsl:when test="contains($queryString, '&amp;locale-attribute')">
                        <xsl:value-of select="substring-before($queryString, '&amp;locale-attribute')"/>
                        <xsl:text>&amp;locale-attribute=</xsl:text>
                    </xsl:when>
                    <!-- the query string is only the locale-attribute so remove it to append the correct one -->
                    <xsl:when test="starts-with($queryString, 'locale-attribute')">
                        <xsl:text>locale-attribute=</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$queryString"/>
                        <xsl:text>&amp;locale-attribute=</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>?locale-attribute=</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="segpres-header-home">
        
        <nav class="navbar">
        <div class="container">
          <div class="up bicolor row">
            <!--<a href="" class="ministerio min-logo text-center hidden-xs"><img src="{$theme-path}images/logo-segpres.png"/></a>-->

                <span class="col-md-6 azul"></span>
                <span class="col-md-6 rojo"></span> 
                <!--<a href="/" class="ministerio text-center">Ministerio Segpres</a>-->

          </div>
          <div class="navbar-header">
            <a type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
              <i class="fa fa-bars" aria-hidden="true"></i>
            </a>
          </div>
          <div id="navbar" class="navbar-collapse collapse">
            <ul class="nav navbar-nav navbar-right">
              <!--<li class="active"><a href="/">Volver al Inicio</a></li>-->
              
              <xsl:choose>
                <xsl:when test="/dri:document/dri:meta/dri:userMeta/@authenticated = 'yes'">
                    <li class="dropdown">
                                        <a id="user-dropdown-toggle" href="#" role="button" class="dropdown-toggle"
                                           data-toggle="dropdown">
                                            <span class="hidden-xs">
                                                <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='firstName']"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='lastName']"/>
                                                &#160;
                                                <b class="caret"/>
                                            </span>
                                        </a>
                                        <ul class="dropdown-menu pull-right" role="menu"
                                            aria-labelledby="user-dropdown-toggle" data-no-collapse="true">
                                            <li>
                                                <a href="{/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='url']}">
                                                    <i18n:text>xmlui.EPerson.Navigation.profile</i18n:text>
                                                </a>
                                            </li>
                                            <li>
                                                <a href="{/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='logoutURL']}">
                                                    <i18n:text>xmlui.dri2xhtml.structural.logout</i18n:text>
                                                </a>
                                            </li>
                                        </ul>
                                    </li>
                </xsl:when>
                <xsl:otherwise>
                    <li><a class="login-aux" href="/openid">Clave única</a></li>
                </xsl:otherwise>
              </xsl:choose>
              
              
              
              
              
            </ul>
          </div><!--/.nav-collapse -->
        </div>
      </nav>


      <div class="home jumbotron text-center">
        <span class="shadow">
         <div class="container">    
          <h1><a href="/">Biblioteca Digital del Gobierno de Chile</a></h1>
          <blockquote>Un Gobierno abierto a la Ciudadanía</blockquote>
        </div>

        <xsl:if test="$request-uri = ''">
        <div id="main-search" class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
          <div class="container"> 
            <div class="row">
              <div class="search-box">
               <form method="get" action="/discover">
               <div class="input-group input-group-lg">
                   <xsl:variable name="itemsTotal">
                            <xsl:value-of select='format-number($total//response/result/@numFound, "###,###")'/>
                     </xsl:variable>
                <input class="form-control" type="text" placeholder="Busca en más de {$itemsTotal} recursos">
                                <xsl:attribute name="name">
                                    <xsl:value-of
                                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='queryField']"/>
                                </xsl:attribute>
                </input>
                <!--<input type="text" class="form-control" placeholder="Busca en más de 13.244 recursos"/>-->
                <span class="input-group-btn">
                  <button class="btn btn-search" type="submit"><i class="fa fa-search" aria-hidden="true"></i></button>
                </span>
              </div><!-- /input-group -->
               </form>
            </div>
            <a href="/discover" class="advance-search btn btn-outline">Búsqueda avanzada</a>
          </div>
        </div>
      </div><!-- /.col-lg-12-->
        </xsl:if>
    </span>
  </div>
        
    </xsl:template>
    <xsl:template name="segpres-header">
        
        <nav class="navbar">
        <div class="container">
          <div class="up bicolor row">
            <!--<a href="" class="ministerio min-logo text-center hidden-xs"><img src="{$theme-path}images/logo-segpres.png"/></a>-->

                <span class="col-md-6 azul"></span>
                <span class="col-md-6 rojo"></span> 
                <!--<a href="/" class="ministerio text-center">Ministerio Segpres</a>-->

          </div>
          <div class="navbar-header">
            <a type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
              <i class="fa fa-bars" aria-hidden="true"></i>
            </a>
          </div>
          <div id="navbar" class="navbar-collapse collapse">
            <ul class="nav navbar-nav navbar-right">
              <!--<li class="active"><a href="/">Volver al Inicio</a></li>-->
              
              <xsl:choose>
                <xsl:when test="/dri:document/dri:meta/dri:userMeta/@authenticated = 'yes'">
                    <li class="dropdown">
                                        <a id="user-dropdown-toggle" href="#" role="button" class="dropdown-toggle"
                                           data-toggle="dropdown">
                                            <span class="hidden-xs">
                                                <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='firstName']"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='lastName']"/>
                                                &#160;
                                                <b class="caret"/>
                                            </span>
                                        </a>
                                        <ul class="dropdown-menu pull-right" role="menu"
                                            aria-labelledby="user-dropdown-toggle" data-no-collapse="true">
                                            <li>
                                                <a href="{/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='url']}">
                                                    <i18n:text>xmlui.EPerson.Navigation.profile</i18n:text>
                                                </a>
                                            </li>
                                            <li>
                                                <a href="{/dri:document/dri:meta/dri:userMeta/
                            dri:metadata[@element='identifier' and @qualifier='logoutURL']}">
                                                    <i18n:text>xmlui.dri2xhtml.structural.logout</i18n:text>
                                                </a>
                                            </li>
                                        </ul>
                                    </li>
                </xsl:when>
                <xsl:otherwise>
                    <li><a class="login-aux" href="/openid">Clave única</a></li>
                </xsl:otherwise>
              </xsl:choose>
              
              
              
              
              
            </ul>
          </div><!--/.nav-collapse -->
        </div>
      </nav>


      <div class="jumbotron text-center">
        <span class="shadow">
         <div class="container">    
          <h1><a href="/">Biblioteca Digital del Gobierno de Chile</a></h1>
          <blockquote>Un Gobierno abierto a la Ciudadanía</blockquote>
        </div>

        <xsl:if test="$request-uri = ''">
        <div id="main-search" class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
          <div class="container"> 
            <div class="row">
              <div class="search-box">
               <form method="get" action="/discover">
               <div class="input-group input-group-lg">
                   <xsl:variable name="itemsTotal">
                            <xsl:value-of select='format-number($total//response/result/@numFound, "###,###")'/>
                     </xsl:variable>
                <input class="form-control" type="text" placeholder="Busca en más de {$itemsTotal} recursos">
                                <xsl:attribute name="name">
                                    <xsl:value-of
                                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='queryField']"/>
                                </xsl:attribute> 
                </input>
                <!--<input type="text" class="form-control" placeholder="Busca en más de 13.244 recursos"/>-->
                <span class="input-group-btn">
                  <button class="btn btn-search" type="submit"><i class="fa fa-search" aria-hidden="true"></i></button>
                </span>
              </div><!-- /input-group -->
               </form>
            </div>
            <a href="/discover" class="advance-search btn btn-outline">Búsqueda avanzada</a>
          </div>
        </div>
      </div><!-- /.col-lg-12-->
        </xsl:if>
    </span>
  </div>
        
    </xsl:template>
    
    <xsl:template name="segpres-ministerios">
        <div class="clearfix"></div>
        
        <h2 class="text-center">MINISTERIOS</h2>
      <p class="short-dec text-center">Acceda directamente a documentos y estudios desarrollados por cada ministerio.</p>
      <section class="sec-ministerios row">

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio del Interior y Seguridad Pública">
          <img class="img-circle" src="{$theme-path}images/interior.png"/>
          <h3 class="text-center carrusel">Ministerio del Interior y Seguridad Pública</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio del Interior y Seguridad Pública" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Relaciones Exteriores">
          <img class="img-circle" src="{$theme-path}images/minrel.jpg"/>
          <h3 class="text-center carrusel">Ministerio de Relaciones Exteriores</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Relaciones Exteriores" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Defensa Nacional">
          <img class="img-circle" src="{$theme-path}images/dfensa.jpg"/>
          <h3 class="text-center carrusel">Ministerio de Defensa Nacional</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Defensa Nacional" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio+de+Hacienda">
          <img class="img-circle" src="{$theme-path}images/hacienda.png"/>
          <h3 class="text-center carrusel">Ministerio de Hacienda</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio+de+Hacienda" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio+Secretaría+General+de+la+Presidencia">
          <img class="img-circle" src="{$theme-path}images/segpress.png"/>
          <h3 class="text-center carrusel">Ministerio Secretaría General de la Presidencia</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio+Secretaría+General+de+la+Presidencia" class="vermas"> Ver más</a>
        </div>


        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio Secretaría General de Gobierno">
          <img class="img-circle" src="{$theme-path}images/msgg.jpg"/>
          <h3 class="text-center carrusel">Ministerio Secretaría General de Gobierno</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio Secretaría General de Gobierno" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Economía, Fomento y Turismo">
          <img class="img-circle" src="{$theme-path}images/economia.png"/>
          <h3 class="text-center carrusel">Ministerio de Economía, Fomento y Turismo</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Economía, Fomento y Turismo" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Desarrollo Social">
          <img class="img-circle" src="{$theme-path}images/MDS.png"/>
          <h3 class="text-center carrusel">Ministerio de Desarrollo Social</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Desarrollo Social" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Educación">
          <img class="img-circle" src="{$theme-path}images/mineduc.png"/>
          <h3 class="text-center carrusel">Ministerio de Educación</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Educación" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Justicia y Derechos Humanos">
          <img class="img-circle" src="{$theme-path}images/justicia.png"/>
          <h3 class="text-center carrusel">Ministerio de Justicia y Derechos Humanos</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Justicia y Derechos Humanos" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio del Trabajo y Previsión Social">
          <img class="img-circle" src="{$theme-path}images/trabajo.jpg"/>
          <h3 class="text-center carrusel">Ministerio del Trabajo y Previsión Social</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio del Trabajo y Previsión Social" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Obras Públicas">
          <img class="img-circle" src="{$theme-path}images/MOP.jpg"/>
          <h3 class="text-center carrusel">Ministerio de Obras Públicas</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Obras Públicas" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Salud">
          <img class="img-circle" src="{$theme-path}images/MINSAL.png"/>
          <h3 class="text-center carrusel">Ministerio de Salud</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Salud" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Vivienda y Urbanismo">
          <img class="img-circle" src="{$theme-path}images/vivienda.png"/>
          <h3 class="text-center carrusel">Ministerio de Vivienda y Urbanismo</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Vivienda y Urbanismo" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Agricultura">
          <img class="img-circle" src="{$theme-path}images/agricultura.jpg"/>
          <h3 class="text-center carrusel">Ministerio de Agricultura</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Agricultura" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Minería">
          <img class="img-circle" src="{$theme-path}images/mineria.jpg"/>
          <h3 class="text-center carrusel">Ministerio de Minería</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Minería" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Transportes y Telecomunicaciones">
          <img class="img-circle" src="{$theme-path}images/mtt.jpg"/>
          <h3 class="text-center carrusel">Ministerio de Transportes y Telecomunicaciones</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Transportes y Telecomunicaciones" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Bienes Nacionales">
          <img class="img-circle" src="{$theme-path}images/bienes.jpg"/>
          <h3 class="text-center carrusel">Ministerio de Bienes Nacionales</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Bienes Nacionales" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Energía">
          <img class="img-circle" src="{$theme-path}images/energia.jpg"/>
          <h3 class="text-center carrusel">Ministerio de Energía</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de Energía" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio del Medio Ambiente">
          <img class="img-circle" src="{$theme-path}images/medioambiente.jpg"/>
          <h3 class="text-center carrusel">Ministerio del Medio Ambiente</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio del Medio Ambiente" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio del Deporte">
          <img class="img-circle" src="{$theme-path}images/deporte.png"/>
          <h3 class="text-center carrusel">Ministerio del Deporte</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio del Deporte" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de la Mujer y la Equidad de Género">
          <img class="img-circle" src="{$theme-path}images/mujer.png"/>
          <h3 class="text-center carrusel">Ministerio de la Mujer y la Equidad de Género</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de la Mujer y la Equidad de Género" class="vermas"> Ver más</a>
        </div>

        <div class="minis-item">
            <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de las Culturas, las Artes y el Patrimonio">
          <img class="img-circle" src="{$theme-path}images/cultura.png"/>
          <h3 class="text-center carrusel">Ministerio de las Culturas, las Artes y el Patrimonio</h3>
            </a>
          <a href="/discover?filtertype=ministerio&amp;filter_relational_operator=equals&amp;filter=Ministerio de las Culturas, las Artes y el Patrimonio" class="vermas"> Ver más</a>
        </div>



        
      </section>
        
        
    </xsl:template>
    
    <xsl:template match="dri:body/dri:div[@n='comunity-browser']">
        <xsl:choose>
            <xsl:when test="$request-uri !=''">
                <xsl:apply-templates />
            </xsl:when>
        </xsl:choose>
    </xsl:template> 
    
    <xsl:template match="dri:body/dri:div/dri:div[@n='site-recent-submission']">
        <xsl:choose>
            <xsl:when test="$request-uri !=''">
                <xsl:apply-templates />
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template name="segpres-tipodocumento">
        <div class="clearfix"></div>
      <h2 class="text-center">TIPOS DE DOCUMENTOS</h2>
      <p class="short-dec text-center">Acceda a los documentos clasificados por tipo de estudio.</p>
      <section class="r-est-items row">
        <div class="est-items col-md-6"><a href="/handle/{$repositoryID}/22" class="algo"><img class="img-circle" src="{$theme-path}images/icons/tipos/1.svg"/><br/>Estudios Nacionales Finales</a></div>

        <div class="est-items col-md-6"><a href="/handle/{$repositoryID}/25" class="algo"><img class="img-circle" src="{$theme-path}images/icons/tipos/2.svg"/><br/>Informes</a></div>

        <div class="est-items col-md-6"><a href="/handle/{$repositoryID}/57" class="algo"><img class="img-circle" src="{$theme-path}images/icons/tipos/4.svg"/><br/>Prospectivas</a></div>

        <div class="est-items col-md-6"><a href="/handle/{$repositoryID}/55" class="algo"><img class="img-circle" src="{$theme-path}images/icons/tipos/3.svg"/><br/>Modelos</a></div>

        <div class="est-items col-md-6"><a href="/handle/{$repositoryID}/24" class="algo"><img class="img-circle" src="{$theme-path}images/icons/tipos/3.svg"/><br/>Estrategias</a></div>

<!--        <div class="est-items col-md-6"><a href="/handle/{$repositoryID}/23" class="algo"><img class="img-circle" src="{$theme-path}images/icons/tipos/4.svg"/><br/>Evaluaciones de Planes</a></div>
        
        <div class="est-items col-md-6"><a href="/handle/{$repositoryID}/25" class="algo"><img class="img-circle" src="{$theme-path}images/icons/tipos/4.svg"/><br/>Informes</a></div>
        
        <div class="est-items col-md-6"><a href="/handle/{$repositoryID}/26" class="algo"><img class="img-circle" src="{$theme-path}images/icons/tipos/4.svg"/><br/>Investigaciones</a></div>
        
        <div class="est-items col-md-6"><a href="/handle/{$repositoryID}/54" class="algo"><img class="img-circle" src="{$theme-path}images/icons/tipos/4.svg"/><br/>Mediciones</a></div>
        
        <div class="est-items col-md-6"><a href="/handle/{$repositoryID}/56" class="algo"><img class="img-circle" src="{$theme-path}images/icons/tipos/4.svg"/><br/>Monitoreo</a></div>-->
      </section><!-- est-items -->
      <a href="/handle/{$repositoryID}/19" class="vermas col-md-offset-4 col-md-4 col-sm-offset-4 col-sm-4 col-xs-10 col-xs-offset-1">Ver todos los estudios</a>

    </xsl:template>
    
    <xsl:template name="segpres-ultimos">
        
        <div class="clearfix"></div>

      <h2 class="text-center">ULTIMAS PUBLICACIONES</h2>
      <section class="destacados">
              
          <xsl:choose>
            <xsl:when test="$total//response/result/doc">
                <xsl:for-each select="$total//response/result/doc">
                    <xsl:if test="position() &lt;= 6">
                    <xsl:variable name="item" select="concat($url-principal,'/metadata/handle/',str[@name='handle'], '/mets.xml')"/>
                    <xsl:variable name="titulo" select="arr[@name='title']/str"/>
                    <xsl:variable name="fecha" select="arr[@name='dc.date.issued']/str"/>
                    <xsl:variable name="abstract" select="arr[@name='dc.description.abstract']/str"/>
                    <xsl:variable name="datos" select="document($item)"/>
                    
                    
                    <xsl:variable name="enlace" select="concat('/handle/', str[@name='handle'])"/>
                    
                    <div class="media col-xs-12  col-sm-12 col-md-4">
                    <div class="media-left media-top">
                    <a class="uestudios" href="{$enlace}">
                    <xsl:choose>
                                 <xsl:when test="$datos//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']">
                                     <xsl:for-each select="$datos//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat">
                                         <xsl:if test="position()=1">
                                     
                           
                                    <img class="media-object">
                                    <xsl:attribute name="src">
                                       <xsl:value-of select="@xlink:href"/>
                                    </xsl:attribute>
                                    </img>
                                    
                        
                                         </xsl:if>
                                     </xsl:for-each>
                                 </xsl:when>
                                 <xsl:when test="$datos//mets:fileSec/mets:fileGrp[@USE='ORE']">
                                     <xsl:variable name="ore" select="$datos//mets:fileSec/mets:fileGrp[@USE='ORE']/mets:file/mets:FLocat/@xlink:href"/>
                                     <xsl:variable name="miniatura" select="document($ore)"/>
                                     <xsl:variable name="thumbnail" select="$miniatura//oreatom:triples/rdf:Description[dcterms:description='THUMBNAIL']/@rdf:about"/>
                                     
                                     <img class="media-object">
                                    <xsl:attribute name="src">
                                       <xsl:value-of select="$thumbnail"/>
                                    </xsl:attribute>
                                    </img>
                                     
                                     
                                     
                                 </xsl:when>
                                 <xsl:when test="$datos//mets:fileSec/mets:fileGrp[@USE='CONTENT']">
                                         
                                     <xsl:variable name="mimetype" select="$datos//mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file/@MIMETYPE"/>
                           
<!--                                    <img class="media-object">
                                    <xsl:attribute name="src">
                                       <xsl:value-of select="@xlink:href"/>
                                    </xsl:attribute>
                                    </img>-->
                                    
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
                                     
                                    <img class="media-object" height="120" width="90" alt="Thumbnail" src="{$theme-path}images/mime.png"/>
                                    
                                 </xsl:otherwise>
                    </xsl:choose>
                    </a>
                    </div>
                    <!--<xsl:value-of select="substring('Hola como estas',1, 24 )"/>-->
                    <div class="media-body">
                    <h4 class="media-heading "><a href="{$enlace}"><xsl:value-of select="substring($titulo,1,30)"/>
                    <xsl:if test="string-length($titulo) &gt; 30">
                        <xsl:text>...</xsl:text>
                    </xsl:if>
                    </a>
                    </h4>
                    
                    <p class="date"><xsl:value-of select="$fecha"/></p>
                    <p class="desc"><xsl:value-of select="substring($abstract,1,60)"/></p>
                  </div>
                    
                    </div>
                    
                    
                    </xsl:if>
                </xsl:for-each>
                
            </xsl:when>
        </xsl:choose>
                
        </section><!--/ ultimos envios-->
      <a href="/recent-submissions" class="vermas col-md-offset-4 col-md-4 col-sm-offset-4 col-sm-4 col-xs-10 col-xs-offset-1">Ver todas las publicaciones</a>
        <div class="clearfix"></div>
    </xsl:template>
    
    <xsl:template name="segpres-footer">
        
        
        <footer class="row">
      <div class="bicolor">
        <span class="azul"></span>
        <span class="rojo"></span>
      </div>
      <div class="container">
      <div class="col-md-5 col-lg-5 lista border">
        <h5>Sitios de Interés</h5>


        <ul>
          <li><a target="_blank" href="https://www.iadb.org/es">Banco Interamericano de Desarrollo</a></li>
          <li><a target="_blank" href="https://www.cepal.org/es">Cepal</a></li>
          <li><a target="_blank" href="http://www.oecd.org/chile/">OECD</a></li>
          <li><a target="_blank" href="https://es.unesco.org/">UNESCO</a></li>
        </ul>
      </div>

      <div class="col-md-7 col-lg-7 lista">
        <h5>Sitios de Interés</h5>

        <ul>
          <li><a target="_blank" href="http://www.dipres.gob.cl/">Dipres</a></li>
          <li><a target="_blank" href="http://www.conicyt.cl/">Conicyt</a></li>
          <li><a target="_blank" href="https://www.bcn.cl/">Biblioteca del Congreso Nacional</a></li>
          <li><a target="_blank" href="http://www.bibliotecanacional.cl/">Biblioteca Nacional</a></li>
          
          
        </ul>
      </div>
      <div class="clearfix"></div>
      <hr/>

      <div class="address col-md-6 col-lg-6">
        <h5>Ministerio Secretaría General de la Presidencia</h5>
        <p>Teléfono +562 2694 5888</p>
        <p>Moneda 1160 Entrepiso, Santiago - Chile.</p>
      </div>

      <div class="links col-md-6 col-lg-6">
        <ul class="list-inline admin">
          <a href="/" class="ministerio min-logo text-center hidden-xs"><img src="{$theme-path}images/logo-segpres.png"/></a>
        </ul>
      </div>
      <div class="bottom footerbottom col-md-12">
        <div class="bicolor">
          <span class="azul"></span>
          <span class="rojo"></span>
        </div>
      </div>
      </div><!--/.container-->
    </footer>
        
    </xsl:template>
    
    <xsl:template name="segpres-menu">
        
          
<!--                            <xsl:choose>
                                <xsl:when test="/dri:document/dri:options/dri:list[@n='browse']/dri:list/dri:item">
                                    
                                    <xsl:for-each select="/dri:document/dri:options/dri:list[@n='browse']/dri:list/dri:item">
                                        
                                        <i18n:text>
                                            <xsl:value-of select="."/>
                                        </i18n:text>
                                        <xsl:text> === </xsl:text>
                                        <xsl:value-of select="dri:xref/@target"/>
                                        <br/>
                                        
                                    </xsl:for-each>
                                    
                                </xsl:when>
                            </xsl:choose>-->
                            
                            <xsl:choose>
                                <xsl:when test="/dri:document/dri:options/dri:list[@n='browse']">
                                    
                                    <xsl:for-each select="/dri:document/dri:options/dri:list[@n='browse']/dri:list">
                                        <h2>
                                        <i18n:text>
                                            <xsl:value-of select="node()"/>
                                        </i18n:text>
                                        </h2>
<!--                                        <xsl:text> === </xsl:text>
                                        <xsl:value-of select="dri:xref/@target"/>-->
                                        <br/>
                                        <xsl:for-each select="dri:item">
                                            <i18n:text>
                                            <xsl:value-of select="node()"/>
                                        </i18n:text><br/>
                                        </xsl:for-each>
                                        
                                        
                                    </xsl:for-each>
                                    
                                </xsl:when>
                            </xsl:choose>
                            <xsl:choose>
                                <xsl:when test="/dri:document/dri:options/dri:list[@n='account']">
                                    
                                    <xsl:for-each select="/dri:document/dri:options/dri:list[@n='account']">
<!--                                        <h2>
                                        <i18n:text>
                                            <xsl:value-of select="dri/head"/>
                                        </i18n:text>
                                        </h2>-->
<!--                                        <xsl:text> === </xsl:text>
                                        <xsl:value-of select="dri:xref/@target"/>-->
                                        <!--<br/>-->
                                        <xsl:for-each select="dri:item">
                                            <i18n:text>
                                                <xsl:value-of select="node()[not(self::dri:xref/i18n:translate)]"/>
                                            </i18n:text>
<!--                                            <i18n:text>
                                            <xsl:value-of select="node()"/>
                                        </i18n:text>-->
                                        <br/>
                                        </xsl:for-each>
                                        
                                        
                                    </xsl:for-each>
                                    
                                </xsl:when>
                            </xsl:choose>
                            <xsl:choose>
                                <xsl:when test="/dri:document/dri:options/dri:list[@n='context']">
                                    
                                    <xsl:for-each select="/dri:document/dri:options/dri:list[@n='context']/dri:list">
                                        <h2>
                                        <i18n:text>
                                            <xsl:value-of select="node()"/>
                                        </i18n:text>
                                        </h2>
<!--                                        <xsl:text> === </xsl:text>
                                        <xsl:value-of select="dri:xref/@target"/>-->
                                        <br/>
                                        <xsl:for-each select="dri:item">
                                            <i18n:text>
                                            <xsl:value-of select="node()"/>
                                        </i18n:text><br/>
                                        </xsl:for-each>
                                        
                                        
                                    </xsl:for-each>
                                    
                                </xsl:when>
                            </xsl:choose>
                            <xsl:choose>
                                <xsl:when test="/dri:document/dri:options/dri:list[@n='administrative']">
                                    
                                    <xsl:for-each select="/dri:document/dri:options/dri:list[@n='administrative']/dri:list">
                                        <h2>
                                        <i18n:text>
                                            <xsl:value-of select="node()"/>
                                        </i18n:text>
                                        </h2>
<!--                                        <xsl:text> === </xsl:text>
                                        <xsl:value-of select="dri:xref/@target"/>-->
                                        <br/>
                                        <xsl:for-each select="dri:item">
                                            <i18n:text>
                                            <xsl:value-of select="node()"/>
                                        </i18n:text><br/>
                                        </xsl:for-each>
                                        
                                        
                                    </xsl:for-each>
                                    
                                </xsl:when>
                            </xsl:choose>
                            <xsl:choose>
                                <xsl:when test="/dri:document/dri:options/dri:list[@n='discovery']">
                                    
                                    <xsl:for-each select="/dri:document/dri:options/dri:list[@n='discovery']/dri:list">
                                        <h2>
                                        <i18n:text>
                                            <xsl:value-of select="node()"/>
                                        </i18n:text>
                                        </h2>
<!--                                        <xsl:text> === </xsl:text>
                                        <xsl:value-of select="dri:xref/@target"/>-->
                                        <br/>
                                        <xsl:for-each select="dri:item">
                                            <i18n:text>
                                            <xsl:value-of select="node()"/>
                                        </i18n:text><br/>
                                        </xsl:for-each>
                                        
                                        
                                    </xsl:for-each>
                                    
                                </xsl:when>
                            </xsl:choose>
        
    </xsl:template>

</xsl:stylesheet>
