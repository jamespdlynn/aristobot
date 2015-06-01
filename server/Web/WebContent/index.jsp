<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-/W3C/DTD HTML 4.01 Transitional/EN"
    	               "http:/www.w3.org/TR/html4/loose.dtd">

<html>
<head>
<meta charset="UTF-8">
<title>Aristobot Games - Competitive Multiplayer Games for Mobile Platforms</title>
<link rel="icon" href="images/favicon.gif" type="image/x-icon"/>

<!--[if lt IE 9]>
   <script>
      document.createElement('header');
      document.createElement('nav');
      document.createElement('section');
      document.createElement('footer');
   </script>
<![endif]-->

<link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon"/> 
<link rel="stylesheet" type="text/css" href="css/global.css"/>
<script src="http://code.jquery.com/jquery-latest.js"></script>

</head>


 <body>
 
 <div id="fb-root"></div>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_GB/all.js#xfbml=1&appId=50637303025";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>

 <div id="container">

   <jsp:include page="components/header.jsp">
   		<jsp:param name="current" value="games" />
   	</jsp:include>

	<div class="content">
   
	   <section class="section">
	   
		   <jsp:include page="components/chess-mates-blurb.jsp"/>
		   
		   	<div class="linkButtons">
		  	 	<a href="/chess-chaps" class="button next">View More</a>
		   	</div>
		   			   	
		</section>
	</div>
	
<footer>
	<div class="fb-like" data-href="https://www.facebook.com/Aristobot" data-send="true" data-width="450" data-show-faces="true"></div>
 	<p>© 2012 Aristobot, LLC. <a href="/privacy-policy">Privacy Policy</a>.</p>
 </footer>
 

</div>


</body>
</html>
