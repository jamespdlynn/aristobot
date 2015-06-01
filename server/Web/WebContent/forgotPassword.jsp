<%@page import="com.aristobot.utils.Constants"%>
<%@page import="com.aristobot.data.AuthenticationData"%>
<%@page import="com.aristobot.managers.JDBCManager"%>
<%@page import="com.aristobot.utils.Utility"%>
<%@page import="com.aristobot.repository.AuthenticationRepositiory"%>
<%@page import="com.aristobot.managers.AuthenticationManager"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%	
	Boolean isSuccess = false;
	String errorMessage = "";
	String formDisplay = "none";
	
	String username = request.getParameter("username");
	String password = request.getParameter("password");
	String confirmPassword = request.getParameter("confirmPassword");
	
	String accessToken = request.getParameter("ac");
	
	JDBCManager dbManager;
	AuthenticationRepositiory repo;
	
	if (username != null && username.length() > 0)
	{
		if (!Utility.isValidPassword(password)){
			formDisplay = "block";
			errorMessage = "Invalid password. Please try another.";
		}
		else if (!password.equals(confirmPassword)){
			formDisplay = "block";
			errorMessage = "Passwords do not match.";
		}
		else
		{
			dbManager = new JDBCManager();
			
			try{
			
				dbManager.connect();
				
				repo = new AuthenticationRepositiory(dbManager);
				repo.updatePassword(username,password);
				
				dbManager.commit();
				
				isSuccess = true;
				formDisplay = "none";
				
			}
			catch (Exception e){
				formDisplay = "block";
				errorMessage = "Unable to reset password at this time. Please <a href='/contact?support=true'>contact us</a>.";
				dbManager.rollback();
			}
			finally{
				dbManager.close();
			}
			
		}
			
	}
	else if (accessToken != null && accessToken.length() > 0){
		
		dbManager = new JDBCManager();
		
		try{
			
			dbManager.connect();
			
			repo = new AuthenticationRepositiory(dbManager);
			
			AuthenticationData data = repo.authenticateAccessToken(accessToken, Constants.ADMIN_APPLICATION_ID);
			
			if (data != null && data.username != null){
				username = data.username;
				formDisplay = "block";
			}
			else{
				errorMessage = "This page has expired. Please reset password again.";
			}
			
		}
		catch (Exception e){
			errorMessage = "We are having technical difficulties. Please <a href='/contact?support=true'>contact us</a>.";
		}
		finally{
			dbManager.close();
		}
		
	}
	else{
		errorMessage = "No token sent.";
	}
	
  
%>
<!DOCTYPE HTML PUBLIC "-/W3C/DTD HTML 4.01 Transitional/EN"
    	               "http:/www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
	<meta charset="UTF-8">
	<title>Forgot Password</title>
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
	<link rel="stylesheet" type="text/css" href="css/contact.css"/>
	<script src="http://code.jquery.com/jquery-latest.js"></script>
	
	</head>


    <body>
	
	   <div id="container">
	
		   <header>
		   	<a href="/"><img id="logo" src="images/logo.png" alt="logo"/></a>    		    
		   </header>
		
		   <div class="content">
		   
			   <section class="section">
			   
				   <h2>Password Reset</h2>
				   
				  	<div id="contact-form" class="clearfix">  
				
				        <%
				        	if (isSuccess){
				        		 out.print("<p id='success'>Your password has been successfully changed.</p>");
				        	}
				        	else if (errorMessage.length() > 0){
				        		 out.print("<p id='errors'>"+errorMessage+"</p>");
				        	}
				        %>
	
				        <form method="post" style="display:<%=formDisplay%>">  
				        
				        	<input type="hidden" id="username" name="username" value="<%=username%>"/>
				        	
				            <label for="password">New Password: </label>  
				            <input type="password" id="password" name="password" value=""  required="required" autofocus="autofocus" />  
				      
				            <label for="password">Confirm Password: </label>  
				            <input type="password" id="confirmPassword" name="confirmPassword" value="" required="required" />  
				            
				            <span id="loading"></span>  
				            <input type="submit" value="Submit" id="submit-button" />  
				        </form>  
				        
				       </div>  
			      </section>
			 </div>
		</div>

 </body>
</html>
