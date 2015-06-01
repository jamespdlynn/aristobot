<%@page import="com.aristobot.utils.Constants"%>
<%
	String current = request.getParameter("current");
	 
	if (request.getLocalPort() == Constants.DEBUG_PORT){  
 		out.print("<script type='text/javascript'>$('document').ready(function(){var debugHTML='<div class=\"debug-bar\">';for(var i=0; i<50; i++)debugHTML+='Development&nbsp&nbsp&nbsp';debugHTML+='</div>';$('body').prepend(debugHTML);});</script>");
 	}
%>

<header>
    <a href="/"><img id="logo" src="images/logo.png" alt="logo"/></a>    

	<nav>
		<ul>
		    <li class="subnav">
		   	 	<a href="/" <%if (current != null && current.equals("games")) out.print("class=\"current\"");%>>Games</a>
		   	 	<ul class="subnav">
		   	 		 <li><a href="/chess-chaps">Chess Chaps</a></li>
					 <li><a href="/leaderboards">Leaderboards</a></li>
				</ul>
		    </li>
		    
		    <li><a href="/about-us" <%if (current != null && current.equals("about-us")) out.print("class=\"current\"");%>>About us</a></li>
			<li><a href="/support" <%if (current != null && current.equals("support")) out.print("class=\"current\"");%>>Support</a></li>
		    <li><a href="/contact" <%if (current != null && current.equals("contact")) out.print("class=\"current\"");%>>Contact</a></li>
		</ul>
    </nav>
    
</header>