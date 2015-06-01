<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-/W3C/DTD HTML 4.01 Transitional/EN"
    	               "http:/www.w3.org/TR/html4/loose.dtd">

<html>
<head>
<meta charset="UTF-8">
<title>Chess Chaps</title>
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
<link rel="stylesheet" href="css/screen.css" type="text/css" media="screen" />
<link rel="stylesheet" href="css/lightbox.css" type="text/css" media="screen" />


<script src="js/jquery-1.7.2.min.js"></script>
<script src="js/lightbox.js"></script>

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
		  	 	<a href="/leaderboards" class="button leaderboard">Leaderboard</a>
		   	</div>
		   			   	
		</section>

   </div>
		
	
	
	<div class="content">
	
		<section class="section">
	   
	   	<div id="imageGroup" style="padding-left:60px;">
	 
		   <div class="imageRow">
		   
		  	<div class="single">
		  		<a href="images/chess_game.png" rel="lightbox[chess]" title="Play chess games in real time or at your own leisure."><img src="images/chess_game_thumb.png" alt="" /></a>
		  	</div>
		  	<div class="single">
		  		<a href="images/chess_victory.png" rel="lightbox[chess]" title="As you complete games, you earn experience towards unlocking new icons."><img src="images/chess_victory_thumb.png" alt="" /></a>
		  	</div>
		  	<div class="single">
		  		<a href="images/chess_replay.png" rel="lightbox[chess]" title="View and navigate turn by turn replays of your completed matches."><img src="images/chess_replay_thumb.png" alt="" /></a>
		  	</div>
		  </div>
		  
		  <div class="imageRow" style="padding-left:120px;padding-top:25px;">
		  	
		  	<div class="single">
		  		<a href="images/chess_profile.png" rel="lightbox[chess]" title="Keep track of your continually updated games, record and unlocks."><img src="images/chess_profile_thumb.png" alt="" /></a>
		  	</div>
		  	<div class="single">
		  		<a href="images/chess_leaderboard.png" rel="lightbox[chess]" title="Play well enough and boast your ranking to the world on the Chess Chaps leaderboard."><img src="images/chess_leaderboard_thumb.png" alt="" /></a>
		  	</div>
		  </div>
		</div>
		
		</section>
		
		
	</div>
	
	<div class="content">
		<section class="section">
	   
		   <h2>Features</h2>
		   <ul>
		   	<li>Play multiple chess games against friends or strangers online. Play an entire game in real time or at your own leisure.</li>
		   	<li>Take advantage of (optional) push notifications for both Android and IOS devices that alert you when an opponent has made their move and the app is not currently open.</li>
		   	<li>Keep track of the number of wins, losses and ties you tally throughout your playing career, as well as your record against individual opponents.</li>
		   	<li>Make use of a fully functional replay system that allows you to view the entirety of your completed games so you can learn from your mistakes.</li>
		   	<li>Take part in a robust global ranking system, that featuring the ELO rating system used to rank real life professional chess players. Use it to match yourself with players of similar skill levels.</li>
		   	<li>Earn experience towards unlocking rare icons for your user as you complete games. Over one hundred unique icons available!</li>
		   </ul>
	
		</section>
	</div>
	
	
		


<footer>
	<div class="fb-like" data-href="https://www.facebook.com/Aristobot" data-send="true" data-width="450" data-show-faces="true"></div>
 	<p>© 2012 Aristobot, LLC. <a href="/privacy-policy">Privacy Policy</a>.</p>
 </footer>
 
</div>


</body>
</html>
