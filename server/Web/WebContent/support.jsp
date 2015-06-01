<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.aristobot.utils.Constants"%>
<!DOCTYPE HTML PUBLIC "-/W3C/DTD HTML 4.01 Transitional/EN"
    	               "http:/www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta charset="UTF-8">
<title>Aristobot Games - Support</title>
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
<link rel="stylesheet" type="text/css" href="css/faq.css"/>
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
	
<script type="text/javascript">
$(document).ready(function()
{
  //hide the all of the element with class msg_body
  $(".answer").hide();
  $(".question").attr("class","question closed");
  
  //toggle the componenet with class msg_body
  $(".question").click(function()
  {
	var answer =  $(this).next(".answer");
	answer.is(":visible") ? $(this).attr("class","question closed") : $(this).attr("class","question open");
	answer.slideToggle(500);
   
  });
  
});
</script>

 <div id="container">


     <jsp:include page="components/header.jsp">
   		<jsp:param name="current" value="support" />
   	</jsp:include>

   <div class="content">
   
	   <section class="section">
	   <h2>Support</h2>
	   <p>If you have any questions or concerns with your game or account please <a href="/contact/support">contact us</a> at any time.</p>
	   </section>
	</div>
	
	<div class="content">
		 <section class="section">
			   
			  <div class="faq-section-title">General</div>
			  
			  <div class="faq-section">
				  <div class="question">What is Aristobot Games?</div>
				   <div class="answer">Aristobot Games is an online multiplayer games platform that consists of multiple applications available to play on Android and IOS mobile devices.</div>
				   
				   <div class="question">What devices are currently supported?</div>
				   <div class="answer">Most Android phones and tablets with a minimum of Android 2.2 operating system are supported. For IOS the IPhone 3GS, 4, 4s, 5 and all IPads running at least IOS 4.0 are currently supported.</div>
				   
				   <div class="question">Can I play against my friend who has a different device from me?</div>
				   <div class="answer">Absolutely, Aristobot Games are cross-platform and can be played between Android and IOS devices.</div>
				   
				   <div class="question">Is there a computer to play against?</div>
				   <div class="answer">No, at this time Aristobot Games are purely multiplayer, but if you have an unfortunate lack of friends you can simply choose to play a random opponent.</div>
				   
				</div>
			
			  <div class="faq-section-title">Account</div>
			  
			  <div class="faq-section">
				   <div class="question">How do I register for an Aristobot Games account?</div>
				   <div class="answer">Download and install any Aristobot Games application onto your phone or tablet. When you first launch the app you will be prompted to register a new account. This account can be used for all current and future Aristobot Games apps.</div>
				   
				   <div class="question">It says I have to put in my email address, am I going to get spammed?</div>
				   <div class="answer">No don't worry. We just need your email address as a way of identification and for you to recover a forgotten password. We may also use it infrequently to notify you of important game changes or updates.
				   <b>Note: Aristobot LLC. will never mine or collect any personal data without your knowledge, and what little personal information we do get from you will be kept securely.</b></div>
				   
				  <div class="question">How do I change my username, password or email address?</div>
				  <div class="answer">While logged into a game, click the Setting icon in the top right corner of the screen, then click on the "Account" button. From here you can change your password or email address. We
				  do not allow users to directly alter their username, but please  <a href="/contact/support">let us know</a> if this is an issue.</div>
				  
				   <div class="question">I forgot my username or password and can't sign in.</div>
				   <div class="answer">From the sign in screen inside the app, click on the "Forgot Password" link. Follow the instructions and an email will be sent
				   to the address your account is registered with. The email will notify you of your username and supply you a link to reset your password. If you are still having issues, don't hesitate to <a href="/contact/support">contact us</a>.</div>
			   
			  </div>  
			  
			 <div class="faq-section-title">Getting Started</div>
			  
			  <div class="faq-section">
				  <div class="question">How do I start a new game against my friend?</div>
				   <div class="answer">From your profile screen go <b>"Games > Create New Game > Find New Opponent"</b>. On this screen enter either your friend's Aristobot Games username or his email address, and click "Search".
				   If successful your friend will be saved as an opponent, a new game will be started and an invite will be sent to him.</div>
				   
				   <div class="question">How do I start a new game against a stranger?</div>
			   <div class="answer">From your profile screen go <b>"Games > Create New Game > Quick Match"</b>. This will match you with a random user with a similar skill rating as you who is not currently saved in your opponent's list. A game will be created and an invite will be sent to this user to accept.</div>
				   
				  <div class="question">How do I make a move?</div>
				  <div class="answer">Once on the Game screen make sure that the game is signifying it's "Your Turn" in the title bar up top, then interact with the game board in a way
				  that generates a valid move. In "Chess Chaps" for instance, touch down on one of your pieces and drag it on top of a valid square. When prompted click "Submit" to send the move to the server, then wait for your opponent to respond.</div>
				  
				   <div class="question">My opponent's not responding, what now?</div>
				   <div class="answer">Patience. If it's been a few days, you can try re-notifying your opponent by nudging him. To do this open up the game you are waiting on, click the option button in the bottom right corner of the screen, then select the "Nudge" option.
				   If your opponent does not make a move after a period of <%out.print(Constants.MAX_ROUND_TIME_DAYS);%> days, they will be automatically resigned and you will be credited with a win.</div>
				  
				  <div class="question">How do I abort or resign from a game I'm playing?</div>
				  <div class="answer">You can only abort or cancel a game you are in without penalty if you have just created it and your opponent has not yet accepted. If this is not the case
				  your only option is to either resign from the game which will be counted as a loss on your part, or send a request to your opponent asking to end the game in a draw. To perform any of these actions, make sure it's your turn and from the game screen
				  click the options button in the bottom right corner to bring up the in game menu.</div>
				  
				  <div class="question">How do I chat with my opponent?</div>
				  <div class="answer">From the Game screen either click on your opponent's icon in the bottom bar, or click the options button and select the chat option from the menu to take you to the Chat screen. Click the back button to return to the game.</div>
				  
				  <div class="question">Where can I see my record against a single opponent?</div>
				  <div class="answer">Your overall record is displayed prominently on the My Profile screen. To see your record against a certain opponent click on the "Opponents" menu option, this will
				  show all of your saved opponents and your wins, losses and ties against each one (notified by the "vs"). You can then click on an opponent to see their overall record.</div>
				  
				<div class="question">How do I turn on/off the sound or enable/disable push notifications?</div>
				<div class="answer">Click the Settings icon in the top right corner of any screen to bring up these options amongst others.</div>
			   
			  </div>  
			 
			 <div class="faq-section-title">Icons and Ranking</div>
			  
			  <div class="faq-section">
				   <div class="question">I only have a few available icons how do I unlock more?</div>
				   <div class="answer"><p>When you complete a game you are rewarded experience towards unlocking a new icon. The amount of experience you gain is based on a myriad of factors, the biggest factor being the result of the game.
				   A win will garner you much more experience than a draw, which will in turn garner more experience than a loss. Other factor's include which application you're using, the difficulty of your opponent, and the number of times you've played this opponent in the past.</p><p>When you earn enough experience, you
				   unlock a new random icon which you can choose to attach to your user. You can view all your icons along with your progress towards your next unlock from the <b>My Icons</b> screen.</p></div>
				   
				   <div class="question">How many wins does it take to unlock an icon?</div>
				   <div class="answer">That depends. It usually only takes one or two wins to receive your first icon, though as you progress though the longer it will take to receive each subsequent one. But on the other hand, as you progress rarer, higher level icons will become available to you.</div>
				   
				   <div class="question">Can I choose which icon I unlock?</div>
				   <div class="answer">At the moment you can only receive a randomly chosen icon of a level based on your experience. In the future though we may indeed include a kind of "Icon Store" with which you can use your experience points to choose which icon to purchase.</div>
				   
				   <div class="question">Can I keep the same icons across different Aristobot Games apps?</div>
				   <div class="answer">Yes! All your icons and your icon experience are shared across all Aristobot Games. So that icon you unlocked while playing chess will also be available in your account in checkers.</div>
				   
				    <div class="question">How do I qualify for ranking and how do I tell if I'm ranked?</div>
				   	<div class="answer">To qualify for ranking you must have played at least <%out.print(Constants.MIN_GAMES_PLAYED_FOR_RANK);%> in a given application and your player rating must be amongst the top <%out.print(Constants.NUM_RANKED_USERS);%> users for the app. Your ranking will be shown through a badge displayed
				   	over the icon on your profile screen. If you are ranked, you will also be able to view yoursef in the in game leaderboard.</div>
				   	
				   	<div class="question">How is my player rating calculated?</div>
				   	<div class="answer">
					   	<p>Your player rating is calculated through the ELO rating system. Simply put, in this system you start out with a rating of 1500 which increases or decreases after every game based on the result and the difficulty of your opponent.</p>
					   	<p>For example, if you play a game against someone with the same rating as you, a win might garner you 15 rating points while a loss would lose you 15 points. 
					   	Playing a game against someone with a higher rating though may give you 20 points for a win and only cost you 10 points for a loss. The net gain would be flipped if you played someone with a lower rating than yourself.  
					   	In our implementation there is also a slight rating bonus given for each game you play, so someone with a 20-20-0 record would likely have an edge over someone with a 5-5-0 record.</p>
					   	<p> You can read more about the <a href="http://en.wikipedia.org/wiki/Elo_rating">Elo Rating System here</a>.</p>
				   	</div>
				   	
				   	<div class="question">Where can I view my player rating?</div>
				   	<div class="answer">
				   		At the moment, your player rating is not viewable anywhere in the application, however it is available on the website <a href="/leaderboard">leaderboard</a>.
				   	</div>
				   	
				   	<div class="question">Does my ranking transfer between Aristobot Games apps?</div>
				   	<div class="answer">No, unlike icons, your ranking and your record are application specific. This means that while you may be ranked number four in the world in chess, when you sign up for checkers you will have to start from ground zero like everybody else.</div>
			   
			  </div>  
			 
			 <div class="faq-section-title">Troubleshooting</div>
			 
		   <div class="faq-section">
			  <div class="question">I'm getting a message that says: "Connection error. Please check your internet connection and try again."</div>
			   <div class="answer">Fully exit the application, then use the browser on your device to make sure you are still connected to the internet at a reasonable speed and restart the app.
			   If the problem persists check our <a href="https://www.facebook.com/Aristobot">facebook page</a> to see if there's any information on current server outages and timetables for fixes.</div>
			  
			   <div class="question">I'm not receiving push notifications.</div>
			   <div class="answer"><p>Check if push notifications are turned on by clicking the Settings icon in the top right corner of any screen. If they are, try turning them off then on again.</p>
			   <p>IOS users may also want to check if notifications are enabled on a system level by going to <b>"Settings > Notifications"</b> outside the application.</p>
			   <p>We do not currently support push notifications for Amazon Kindle users, but we hope to include this functionality in the near future</p>
			   <p>For other Android users, sometimes notifications are no longer received when the OS kills the application because of low system memory. To fix this, you might want to try and free some memory by having less apps running at the same time.</p>
			    </div>
			   
			  <div class="question">The app is hanging or unresponsive.</div>
			  <div class="answer">Exit the app completely by force closing it from the OS level and restart. If the problem persists please <a href="/contact/support">contact us</a> immediately.</div>
		   
		  </div> 
			   
		</section>
	 </div>

  


<footer>
	<div class="fb-like" data-href="https://www.facebook.com/Aristobot" data-send="true" data-width="450" data-show-faces="true"></div>
 	<p>© 2012 Aristobot, LLC. <a href="/privacy-policy">Privacy Policy</a>.</p>
 </footer>
 


</body>
</html>
