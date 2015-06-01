<%@page import="javax.ws.rs.WebApplicationException"%>
<%@page import="com.aristobot.utils.Constants"%>
<%@page import="com.aristobot.managers.LogManager"%>
<%@page import="com.aristobot.data.ApplicationUser"%>
<%@page import="java.util.List"%>
<%@page import="com.aristobot.repository.UserRepository"%>
<%@page import="com.aristobot.managers.JDBCManager"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%	

	List<ApplicationUser> users;
	JDBCManager dbManager = new JDBCManager();
	try{
		dbManager.connect();
		
		UserRepository userRepo = new UserRepository(dbManager);
		users = userRepo.getUsersByRank(100001);
	}
	catch (RuntimeException e){
		throw new WebApplicationException(500);
	}
    finally{
    	dbManager.close();
    }
%>
<!DOCTYPE HTML PUBLIC "-/W3C/DTD HTML 4.01 Transitional/EN"
    	               "http:/www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta charset="UTF-8">
<title>Leaderboard</title>
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
<link rel="stylesheet" type="text/css" href="css/leaderboard.css"/>
<script src="http://code.jquery.com/jquery-latest.js"></script>

</head>


    <body>
	
    <!--start container-->
    <div id="container">

   <jsp:include page="components/header.jsp">
   		<jsp:param name="current" value="games" />
   	</jsp:include>

   	 
   <div class="content">
   	 <section class="section">
   	 
   	 	<h1>Leaderboards</h1>
   	 
   	 		
   	 		<p>  * User ratings are calculated using a version the <a href="http://en.wikipedia.org/wiki/Elo_rating">ELO rating algorithm</a>.</p>
   	 		<p>  * To be ranked users must have completed at least <%out.print(Constants.MIN_GAMES_PLAYED_FOR_RANK);%> games and have a top <%out.print(Constants.NUM_RANKED_USERS);%> rating.</p>
   	 	
   	 	
         <select id="enquiry" name="enquiry" disabled="disabled">  
             <option value="Chess Chaps">Chess Chaps</option>  
      
         </select>  

   	 
   	 	<table width="100%" border="1" align="center" class="leaderboard">
   	 	
   	 		<tr align="left">
   	 			<td class="title" colspan="6"><img width="64" height="64" src="images/chess.png" alt="Chess Chaps"/>Chess Chaps</td>
   	 		</tr>
   	 		
   	 		<tr align="center">
   	 			<td>Rank</td>
   	 			<td>User</td>
   	 			<td>Wins</td>
   	 			<td>Losses</td>
   	 			<td>Ties</td>
   	 			<td>Rating</td>
   	 		</tr>
   	 		<%
	        	for (ApplicationUser user : users)
	        	{
	        		out.print("<tr align='center'>");
	        		out.print("<td class='rank' style='background-image:url("+user.icon.badgeURL+")'>"+user.icon.rank+"</td>");
	        		out.print("<td class='user' align='left'><img width='56' height='56' alt='"+user.icon.iconName+"' src='"+user.icon.iconURL+"'/>"+user.username+"</td>");
	        		out.print("<td class='win'>"+user.wins+"</td>");
	        		out.print("<td class='loss'>"+user.losses+"</td>");
	        		out.print("<td class='tie'>"+user.ties+"</td>");
	        		out.print("<td class='rating'>"+user.rating+"</td>");
	        		out.print("</tr>");
	        	}
       		 %>
   	 	</table>
   	 	
   	 </section>
   	 
   </div>
   
   

    <footer>
 		<p>© 2012 Aristobot, LLC. <a href="/privacy-policy">Privacy Policy</a>.</p>
 	</footer>
    </div>
  
   </body></html>
