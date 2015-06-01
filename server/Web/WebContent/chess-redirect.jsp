<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE HTML PUBLIC "-/W3C/DTD HTML 4.01 Transitional/EN"
    	               "http:/www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Chess Chaps Redirect</title>
	<%	
		String ua = request.getHeader( "User-Agent" );
		
		if (ua.contains("iPhone") || ua.contains("iPad") || ua.contains("iPod")){
			response.sendRedirect("http://appstore.com/chesschaps");
		}
		else if (ua.contains("Kindle") || ua.contains("Silk")){
			response.sendRedirect("amzn://apps/android?asin=B0094KMY1K");
		}
		else if (ua.contains("Android")){
			response.sendRedirect("market://details?id=air.com.aristobot.chess");
		}
		else{
			response.sendRedirect("/chess-chaps");
		}
	%>
	</head>
</html>
