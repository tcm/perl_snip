<?xml version="1.0" encoding="ISO8859-1"?>
<xsl:stylesheet	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" >
<xsl:template match="/">
	<html>
	<head>
	<title> - Contenu de l'ordinateur : - ISCIO Hardware Inventory</title>
	<style type="text/css">
		body { margin-top:10px; margin-bottom:25px; font-family: verdana, sans-serif; font-size: 80%; line-height: 1.45em; } 
		p { padding-top: 0px; margin-top: 0px; }
		dl { margin-left: 20px; background-color: #f0f0f0; margin-bottom: 15px; padding-bottom: 10px;}
		dl dt h4{ text-align: center; border: 1px solid #000; background-color: #cccccc;}
		ul#index { list-style-type: none; margin-left: 0px; padding-left: 0px;}
		ul#index li {float:left; margin-left: 10px;}
		.spacer {clear: both; };
		a {white-space: nowrap;}
	</style>
	</head>
	<body>
		<h1 id="top">ISCIO Hardware Inventory</h1>
		<h2>Computer id</h2>
		<h3>Index</h3>

		<ul id="index">

		<xsl:for-each select="computer/component">
		    <li><a href="#" ><xsl:value-of select="type" /></a></li>
		</xsl:for-each>
		</ul>

		<div class="spacer"></div>
		<br />
		<h3>Détails : </h3>

		<xsl:for-each select="computer/component">
		<a href="#top" title="top" style="float:right;">Top </a>
		<dl>
			<dt><a name="1" id="1"><h4><xsl:value-of select="type" /></h4></a></dt>
			<dd>
				<h5><xsl:value-of select="name" /></h5>
				<ul>
					<xsl:for-each select="attr">
						<li><strong><xsl:value-of select="name" /></strong> : <xsl:value-of select="value" /></li>
					</xsl:for-each>
				</ul>
			</dd>
		</dl>
		<br />
		</xsl:for-each>

	</body>
	</html>
</xsl:template>

</xsl:stylesheet>
