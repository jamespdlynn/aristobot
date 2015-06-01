<%@page import="com.aristobot.data.EmailMessage"%>
<%@page import="com.aristobot.utils.Constants"%>
<%@page import="com.aristobot.utils.Constants.QueueJDNI"%>
<%@page import="com.aristobot.managers.JMSQueueManager"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%	
	Boolean isSuccess = false;
	Boolean isError = false; 
	String errorMessage = "";
	
	String name = request.getParameter("name");
	String email = request.getParameter("email");
	String telephone = request.getParameter("telephone");
	String enquiry = request.getParameter("enquiry");
	String message =  request.getParameter("message");
		
	if (request.getParameter("sent") != null)
	{
	  if (name == null || name.length() == 0){
		  isError = true;
		  errorMessage = "Please enter your name.";
	  }
	  
	  else if (email == null || email.length() == 0){
		  isError = true;
		  errorMessage = "Please enter a valid email address.";
	  }
	  
	  else  if (message == null || message.length() < 20){
		  isError = true;
		  errorMessage = "Message must be atleast 20 characters.";
	  }
	  
	  if (!isError)
	  {
		  try
		   {
		      String subject = name+"- Contact Form - "+enquiry;
		      String body = "Name: "+name+"\nEmail: "+email;
		      
		      if (telephone != null && telephone.length() > 0){
		    	  body+="\nPhone: "+telephone;
		      }
		      
		      body+="\n\n"+message;

		      JMSQueueManager queueManager = new JMSQueueManager();
		      queueManager.sendItem(QueueJDNI.MAIL, new EmailMessage(Constants.OUTBOUND_EMAIL_ADDRESS, Constants.INBOUND_EMAIL_ADDRESS, subject, body));
		      
		      isSuccess = true;
		   }
		   catch (Exception e) {
		      isError = true;
		      errorMessage = "Sorry there was an error sending your message. Please contact us directly using the email address above or try again later.";
		   }
	  } 
		  
	   
	}

  
%>
<!DOCTYPE HTML PUBLIC "-/W3C/DTD HTML 4.01 Transitional/EN"
    	               "http:/www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta charset="UTF-8">
<title>Aristobot Games - Contact</title>
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
 
 <div id="fb-root"></div>
	<script>(function(d, s, id) {
	  var js, fjs = d.getElementsByTagName(s)[0];
	  if (d.getElementById(id)) return;
	  js = d.createElement(s); js.id = id;
	  js.src = "//connect.facebook.net/en_GB/all.js#xfbml=1&appId=50637303025";
	  fjs.parentNode.insertBefore(js, fjs);
	}(document, 'script', 'facebook-jssdk'));</script>
	
    <!--start container-->
    <div id="container">

     <jsp:include page="components/header.jsp">
   		<jsp:param name="current" value="contact" />
   	</jsp:include>


   <div class="content">
   	 <section class="section">
   	 	<h2>Contact Us</h2>
   	 	<p>Please contact us by email at <a href='mailto:info@aristobotgames.com'>info@aristobotgames.com</a> or by filling out the form below. We will respond to your inquiry as soon as we possibly can.</p>
   	 	<%if (enquiry != null && enquiry.equalsIgnoreCase("support")){
   	 	 	out.print("<p><b>If you are having a specific issue, please include in your message your username, the app, the device you're using, and a detailed description of the problem.</b></p>");
   	 	}
   	 	%>
   	 </section>
   </div>
   
   <div class="content">
   		 <section class="section">

	    <div id="contact-form" class="clearfix">  
	    
        <%
        	if (isSuccess){
        		 out.print("<p id='success'>Thank you for your input! We'll get back to you as soon as possible.</p>");
        	}
        	else if (isError){
        		 out.print("<p id='errors'>"+errorMessage+"</p>");
        	}
        %>

        
        <form method="post">  
            <label for="name">Name: <span class="required">*</span></label>  
            <input type="text" id="name" name="name" value="<%if (isError && name != null) out.print(name);%>" placeholder="John Doe" required="required" autofocus="autofocus" />  
      
            <label for="email">Email Address: <span class="required">*</span></label>  
            <input type="email" id="email" name="email" value="<%if (isError && email != null) out.print(email);%>"" placeholder="johndoe@example.com" required="required" />  
      
            <label for="telephone">Telephone: </label>  
            <input type="tel" id="telephone" name="telephone" value="<%if (isError && telephone != null) out.print(telephone);%>" placeholder="xxx-xxx-xxxx"/>  
      
            <label for="enquiry">Enquiry: </label>  
            <select id="enquiry" name="enquiry">  
                <option value="General"<%if (enquiry != null && enquiry.equalsIgnoreCase("general")) out.print("selected='selected'");%>>General</option>  
                <option value="Business"<%if (enquiry != null && enquiry.equalsIgnoreCase("business")) out.print("selected='selected'");%>>Business</option>  
                <option value="Support"<%if (enquiry != null && enquiry.equalsIgnoreCase("support")) out.print("selected='selected'");%>>Support</option>  
            </select>  
            
            <input type="hidden" id="sent" name="sent" value="sent"/>
      
            <label for="message">Message: <span class="required">*</span></label>  
            <textarea id="message" name="message" value="<%if (isError && message != null) out.print(message);%>" placeholder="Your message must be greater than 20 characters" required="required" data-minlength="20"></textarea>  
      
            <span id="loading"></span>  
            <input type="submit" value="Send" id="submit-button" />  
            <p id="req-field-desc"><span class="required">*</span> indicates a required field</p>  
        </form>  
    </div>  
  	</section>
   </div>
   

    <footer>
    <div class="fb-like" data-href="https://www.facebook.com/Aristobot" data-send="true" data-width="450" data-show-faces="true"></div>
 	<p>© 2012 Aristobot, LLC. <a href="/privacy-policy">Privacy Policy</a>.</p>
 </footer>
    </div>
  
   </body></html>
