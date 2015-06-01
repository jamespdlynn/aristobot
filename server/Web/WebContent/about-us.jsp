<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-/W3C/DTD HTML 4.01 Transitional/EN"
    	               "http:/www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta charset="UTF-8">
<title>Aristobot Games - About Us</title>
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
   		<jsp:param name="current" value="about-us" />
   	</jsp:include>

   <div class="content">
   
   	   <section class="section">
   	   	  <h2>About Aristobot Games</h2>
	   	  <p>The recent success of many online mobile games should not come as much of a surprise. The social playing experience coupled with the portability of mobile devices are why these apps have garnered such widespread appeal. 
	   	  However, most modern social games are so lenient and casual they do not lend themselves well to more competitive players.

		  <p>Aristobot LLC., founded in 2012, looks to fill this void through creating a suite of skill based multiplayer games for Android and IOS platforms. Each app will retain the accessible nature of a casual mobile game, while adding features such as statistic tracking, global user rankings, and a progressive unlock system, to allow for a more competitive and rewarding user experience.</p>

		</section>
	</div>
	
	<div class="content">
			
		<section class="section">
		   <h3>Founders</h3>
		   
			<h4>James Lynn</h4>
			<p>James is the chief architect and programmer for Aristobot Games. He graduated from the University of Georgia in 2009 with a B.S in Computer science. 
			He has spent the past five years in the software industry focusing on web and mobile development, and now resides in Austin, Texas.</p>
			 
			 <h4>Christian Rhodes</h4>
			 <p>Christian is the head of business and marketing operations for Aristobot Games.
			 He obtained his bachelor’s degree from the University of South Carolina in 2009 and then his Juris Doctorate from the University of Georgia in 2012. 
			 He currently lives in Atlanta, Georgia.</p>
		 
		</section>
   </div>


<footer>
<div class="fb-like" data-href="https://www.facebook.com/Aristobot" data-send="true" data-width="450" data-show-faces="true"></div>
 	<p>© 2012 Aristobot, LLC. <a href="/privacy-policy">Privacy Policy</a>.</p>
 </footer>
 
</div>


</body>
</html>
