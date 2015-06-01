package com.aristobot.services;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Iterator;
import java.util.List;

import javax.ws.rs.Consumes;
import javax.ws.rs.DefaultValue;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import com.aristobot.data.AdminTask;
import com.aristobot.data.AdminTask.Task;
import com.aristobot.data.ApplicationUser;
import com.aristobot.data.EmailMessage;
import com.aristobot.data.PushNotification;
import com.aristobot.data.SystemMessage;
import com.aristobot.data.Tokens;
import com.aristobot.data.User;
import com.aristobot.data.UserCredentials;
import com.aristobot.data.UserIcon;
import com.aristobot.data.wrappers.IconsWrapper;
import com.aristobot.data.wrappers.MessagesWrapper;
import com.aristobot.exceptions.AuthenticationException;
import com.aristobot.exceptions.IconException;
import com.aristobot.exceptions.UserException;
import com.aristobot.managers.AuthenticationManager;
import com.aristobot.managers.LogManager;
import com.aristobot.managers.JDBCManager;
import com.aristobot.managers.JMSQueueManager;
import com.aristobot.managers.MailManager;
import com.aristobot.repository.AuthenticationRepositiory;
import com.aristobot.repository.IconRepository;
import com.aristobot.repository.MessageRepository;
import com.aristobot.repository.UserRepository;
import com.aristobot.utils.Constants;
import com.aristobot.utils.Constants.DeviceType;
import com.aristobot.utils.Constants.MessageType;
import com.aristobot.utils.Constants.QueueJDNI;
import com.sun.jersey.core.header.FormDataContentDisposition;
import com.sun.jersey.multipart.FormDataParam;

/**
 * Service used to authenticate and grant a user an accesstoken they can use
 * to make subsequent service calls
 * @author James
 *
 */
@Path("/admin")
public class AdminService
{

	private JDBCManager dbManager;
	private AuthenticationManager authManager;
		
	public AdminService()
	{
		try{
			dbManager = new JDBCManager();
			authManager = new AuthenticationManager(dbManager);
		}
		catch (RuntimeException e){
			throw LogManager.handleException(e);
		}
	}
	
	

    @POST
	@Path("/login")
    @Consumes("application/xml")
    @Produces("application/xml")
    public Tokens login(@Context HttpHeaders headers, UserCredentials creds)
    {       
    	
    	
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireAdminPrivelleges();
    		    		 
    		AuthenticationRepositiory repo = new AuthenticationRepositiory(dbManager);
    		
    		if (creds.deviceId == null || !repo.authenticateDeviceId(creds.deviceId).isValid){
        		throw new AuthenticationException(AuthenticationException.INVALID_DEVICE_ID);
        	}
        	
			String username = repo.authenticateAdminLogin(creds.username, creds.password);
						
	    	if (username == null){
	    		 throw new AuthenticationException(AuthenticationException.LOGIN_FAILED);
	    	} 
	    	
	    	String rt = repo.addAuthenticatedUser(authManager.getApplicationId(), username, creds.deviceId, creds.pushNotificationToken);
	    	
	    	Tokens tokens = new Tokens();
	    	tokens.accessToken = repo.createAccessToken(rt);
	    	
	    	repo.setRegisteredUsername(username, creds.deviceId);
	    	
	    	dbManager.commit();
	    	
	    	return tokens;
	    	
    	}
    	catch (RuntimeException e){
	    	dbManager.rollback();
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
        
	   
    }
	
    /**
     * Performs cleanup on database deleting or otherwise handling expired games, players or tokens
     * @return Response Object with 201 Success Message on successful addition of User
     */
    @POST
    @Path("/clean")
    @Consumes("text/xml")
	@Produces("application/xml")
	public Response clean(@Context HttpHeaders headers)
	{
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireAdminPrivelleges();
    		
    		JMSQueueManager queueManager = new JMSQueueManager();
    		queueManager.queueItem(QueueJDNI.ADMIN, new AdminTask(Task.CLEAN));    		
    		queueManager.sendQueuedItems();
    		
    		return Response.status(200).build();
    		
    	}
	    catch (RuntimeException e){
	    	throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
	}
        
    @POST
    @Path("/send-push-user")
    @Consumes("application/xml")
    @Produces("text/xml")
    public Response sendPushNotificationToUser(@Context HttpHeaders headers, PushNotification notification) 
    {        
        try{
        	dbManager.connect();	
        	
        	authManager.setHeaders(headers.getRequestHeaders());
        	authManager.requireAdminPrivelleges();
        	
        	UserRepository repo = new UserRepository(dbManager);
        	
        	if (notification.username == null || repo.getUser(notification.username ) == null){
        		throw new UserException(UserException.INVALID_USER_NAME);
        	}
        	
        	JMSQueueManager queueManager = new JMSQueueManager();
        	queueManager.sendItem(QueueJDNI.PUSH_NOTIFICATION, notification);

    	}
		catch (RuntimeException e){
			throw LogManager.handleException(e);
 		}
		finally{
			dbManager.close();
		}
		
	
		return Response.status(200).build();
    }
    
    @POST
    @Path("/send-push-all")
    @Consumes("application/xml")
    @Produces("text/xml")
    public Response sendPushNotificationToAll(@Context HttpHeaders headers, PushNotification notification) 
    {        
        try{
        	dbManager.connect();	
        	
        	authManager.setHeaders(headers.getRequestHeaders());
        	authManager.requireFullAuthentication();
        	        	
        	UserRepository userRepo = new UserRepository(dbManager);
        	JMSQueueManager queueManager = new JMSQueueManager();
        	
    		List<ApplicationUser> users = userRepo.getAllAppicationsUsers(notification.applicationId);
    		for (ApplicationUser user : users){
    			queueManager.queueItem(QueueJDNI.PUSH_NOTIFICATION, new PushNotification(user.username, notification.message, notification.params, notification.applicationId));
    		}
        	
    		queueManager.sendQueuedItems();
    	}
		catch (RuntimeException e){
			throw LogManager.handleException(e);
 		}
		finally{
			dbManager.close();
		}
		
	
		return Response.status(200).build();
    }
    

    @GET
    @Path("/messages")
	@Produces("application/xml")
    public MessagesWrapper getAllSystemMessages(@Context HttpHeaders headers, @QueryParam("applicationId") @DefaultValue("-1") int applicationId )
    {
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		
    		MessageRepository messageRepo = new MessageRepository(dbManager);
    		
    		MessagesWrapper wrapper = new MessagesWrapper();
    		wrapper.messages = messageRepo.getSystemMessages();
    		
    		return wrapper;
    	}
	    catch (RuntimeException e){
	    	dbManager.rollback();
	    	throw LogManager.handleException(e);
 		}
	    finally{
	    	
	    	dbManager.close();
	    }
	    
    }
    
    @POST
    @Path("/send-email")
    @Consumes("application/xml")
    @Produces("application/xml")
    public Response sendEmailMessage(@Context HttpHeaders headers, EmailMessage message) 
    {        
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireAdminPrivelleges();
    		

    		JMSQueueManager queueManager = new JMSQueueManager();
    		MailManager mailManager = new MailManager(dbManager, queueManager);
    		
    		mailManager.queueMessage(message);
    		queueManager.sendQueuedItems();
    	}
    	 catch (RuntimeException e){
 	    	dbManager.rollback();
 	    	throw LogManager.handleException(e);
  		}
 	    finally{
 	    	dbManager.close();
 	    }
		
 	   return Response.status(200).build();
    }
    
    @POST
    @Path("/send-message")
    @Consumes("application/xml")
	@Produces("application/xml")
    public Response sendSystemMessage(@Context HttpHeaders headers, SystemMessage message, @QueryParam("sendAsEmail") @DefaultValue("false") Boolean sendAsEmail )
    {    	
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		
    		UserRepository userRepo = new UserRepository(dbManager);
    		MessageRepository messageRepo = new MessageRepository(dbManager);
    		
    		String messageKey = messageRepo.addSystemMessage(Constants.ARISTOBOT_ICON_KEY, message.subject, message.body, MessageType.CUSTOM);
    		
    		JMSQueueManager queueManager = new JMSQueueManager();
    		
    		MailManager mailManager = new MailManager(dbManager, queueManager);
    		
    		
    		Iterator<? extends User> iter = userRepo.getAllUsers().iterator();
    		while (iter.hasNext())
    		{
    			User user = iter.next();
    			messageRepo.addMessageToUser(messageKey, user.username);
    			
    			if (sendAsEmail){
    				mailManager.queueMessage(new EmailMessage(Constants.OUTBOUND_EMAIL_ADDRESS, user.emailAddress, message.subject, message.body, EmailMessage.BODY_MIME_TYPE_HTML));
    			}
    		}	
    		
    		dbManager.commit();
    		queueManager.sendQueuedItems();
    		
    	}
	    catch (RuntimeException e){
	    	dbManager.rollback();
	    	throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
	    
	    return Response.status(200).build();
    }
    
    @POST
    @Path("/update-message")
    @Consumes("application/xml")
	@Produces("application/xml")
    public Response updateSystemMessage(@Context HttpHeaders headers, SystemMessage message)
    {
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		
    		MessageRepository messageRepo = new MessageRepository(dbManager);
    		
    		if (messageRepo.getSystemMessage(message.messageKey) == null){
    			throw new UserException(UserException.INVALID_MESSAGE);
    		}
    		    		
    		messageRepo.updateSystemMessage(message.messageKey, Constants.ARISTOBOT_ICON_KEY, message.subject, message.body, MessageType.generate(message.type));
    		
    		dbManager.commit();
    	}
	    catch (RuntimeException e){
	    	dbManager.rollback();
    		LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
	    
	    return Response.status(200).build();
    }
    
    @POST
    @Path("/delete-message")
    @Consumes("text/xml")
	@Produces("application/xml")
    public Response deleteSystemMessage(@Context HttpHeaders headers, String messageKey)
    {
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		
    		MessageRepository messageRepo = new MessageRepository(dbManager);
    		
    		if (messageRepo.getSystemMessage(messageKey) == null){
    			throw new UserException(UserException.INVALID_MESSAGE);
    		}
    		
    		if (messageKey.equals(Constants.REGISTRATION_MESSAGE_ID)){
    			throw new UserException(UserException.INVALID_MESSAGE);
    		}
    		    		
    		messageRepo.deleteSystemMessage(messageKey);
    		
    		dbManager.commit();
    	}
	    catch (RuntimeException e){
	    	dbManager.rollback();
    		LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
	    
	    return Response.status(200).build();
    }
    

    
    
    @GET
    @Path("/icons")
    @Produces("application/xml")
    public IconsWrapper getAllIcons(@Context HttpHeaders headers)
    {
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireAdminPrivelleges();
    		
        	IconRepository repo = new IconRepository(dbManager);
        	
        	IconsWrapper wrapper = new IconsWrapper();
	    	wrapper.icons = repo.getAllIcons();
	    	
	    	return wrapper;
	    		    	
    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
    }
    
    
    @GET
    @Path("/icons/{key}")
    @Produces("application/xml")
    public IconsWrapper getIconsByLevel(@Context HttpHeaders headers, @PathParam("key") int level)
    {
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireAdminPrivelleges();
    		
        	IconRepository repo = new IconRepository(dbManager);
        	        	
        	IconsWrapper wrapper = new IconsWrapper();
	    	wrapper.icons = repo.getIconsByLevel(level);
	    	
	    	return wrapper;
	    		    	
    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
    }
    
    @POST
    @Path("/icons/validate")
    @Consumes("application/xml")
    @Produces("text/xml")
    public Response validateIcon(@Context HttpHeaders headers, UserIcon icon)
    {
    	try
    	{
			dbManager.connect();
			
			authManager.setHeaders(headers.getRequestHeaders());
			authManager.requireAdminPrivelleges();
			
			validateIcon(icon);
			
			IconRepository repo = new IconRepository(dbManager);
			
			if (repo.getIcon(icon.iconKey) != null){
				throw new IconException(IconException.ICON_ALREADY_EXISTS);
			}
    	         
	        return Response.status(200).build();
	    		    	
    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
    }
    
    @POST
    @Path("/icons/add")
    @Consumes("application/xml")
    @Produces("text/xml")
    public Response addIcon(@Context HttpHeaders headers, UserIcon icon)
    {
    	try
    	{
			dbManager.connect();
			
			authManager.setHeaders(headers.getRequestHeaders());
			authManager.requireAdminPrivelleges();
			
			validateIcon(icon);
			
			IconRepository repo = new IconRepository(dbManager);
			
			if (repo.getIcon(icon.iconKey) != null){
				throw new IconException(IconException.ICON_ALREADY_EXISTS);
			}
			
			try{
				 URL url = new URL("http://localhost/media/icons/"+icon.iconKey+".png");
		         HttpURLConnection conn = (HttpURLConnection) url.openConnection();
		         conn.setRequestMethod("GET");
		         
		         if (conn.getResponseCode() != 200){
		        	 throw new IconException(IconException.ICON_NOT_ON_SERVER);
		         }

			}
	        catch (Exception e){
	        	LogManager.logException(e);
	        	throw new WebApplicationException();
	        }
	        
	        repo.addIcon(icon);
	        dbManager.commit();
    	         
	        return Response.status(200).build();
	    		    	
    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
    }
    
    @POST
    @Path("/icons/update")
    @Consumes("application/xml")
    @Produces("text/xml")
    public Response updateIcon(@Context HttpHeaders headers, UserIcon icon)
    {
    	try
    	{
			dbManager.connect();
			
			authManager.setHeaders(headers.getRequestHeaders());
			authManager.requireAdminPrivelleges();
			
			validateIcon(icon);
			
			IconRepository repo = new IconRepository(dbManager);
			
			if (repo.getIcon(icon.iconKey) == null){
				throw new IconException(IconException.INVALID_ICON_KEY);
			}
			
			repo.updateIcon(icon);
	        dbManager.commit();
    	         
	        return Response.status(200).build();
	    		    	
    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
    }
    
    @POST
    @Path("/icons/delete")
    @Consumes("text/xml")
    @Produces("text/xml")
    public Response deleteIcon(@Context HttpHeaders headers, String iconKey)
    {
    	try
    	{
			dbManager.connect();
			
			authManager.setHeaders(headers.getRequestHeaders());
			authManager.requireAdminPrivelleges();

			IconRepository repo = new IconRepository(dbManager);
			
			if (repo.getIcon(iconKey) == null){
				throw new IconException(IconException.INVALID_ICON_KEY);
			}
			
			if (repo.getIconOwners(iconKey).size() > 0){
				throw new IconException(IconException.ICON_BELONGS_TO_USER);
			}
			
			File f1 = new File(Constants.MEDIA_DIRECTORY+"/icons/"+iconKey+".png");
			
			if (f1.exists()){
				f1.delete();
			}
			
			repo.deleteIcon(iconKey);
	        dbManager.commit();
    	         
	        return Response.status(200).build();
	    		    	
    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
	    
    }
    

    @POST
    @Path("/icons/upload")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    @Produces("text/xml")
    public Response uploadIcon(@Context HttpHeaders headers,
    		@FormDataParam("Filedata") InputStream uploadedInputStream,
    		@FormDataParam("Filedata") FormDataContentDisposition fileDetail,
    		@QueryParam("iconKey") String iconKey)
    {
    	try
    	{
			dbManager.connect();
			
			authManager.setHeaders(headers.getRequestHeaders());
			authManager.requireAdminPrivelleges();
						
			if (iconKey == null || !iconKey.matches("^[a-zA-z_]+$")){
				throw new IconException(IconException.INVALID_ICON_KEY);
			}
			
			if (fileDetail.getSize() > 10000){
				throw new IconException(IconException.ICON_TOO_LARGE);
			}
		
			writeToFile(uploadedInputStream, Constants.MEDIA_DIRECTORY+"/icons/"+iconKey+".png");
			
	        return Response.status(200).build();
	    		    	
    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
    }
    
    @PUT
    @Path("/icons/unlock")
    @Produces("text/xml")
    public Response unlockIcon(@Context HttpHeaders headers, @QueryParam("username") String username, @QueryParam("level") int level, @QueryParam("applicationId") @DefaultValue("-1") int applicationId)
    {
    	try
    	{
			dbManager.connect();
			
			authManager.setHeaders(headers.getRequestHeaders());
			authManager.requireAdminPrivelleges();
			
			UserRepository userRepo = new UserRepository(dbManager);
			
			
			if (username == null || userRepo.getUser(username) == null){
				throw new UserException(UserException.INVALID_USER_NAME);
			}
			
			if (level <= 0){
				throw new IconException("Invalid Icon Level");
			}
			
						
			IconRepository iconRepo = new IconRepository(dbManager);
			iconRepo.unlockRandomIcon(username, level, applicationId);
		
	        return Response.status(200).build();
	    		    	
    	}
    	catch (RuntimeException e){
    		dbManager.rollback();
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
    }
    
   
    
    // save uploaded file to new location
	protected void writeToFile(InputStream uploadedInputStream, String uploadedFileLocation) 
	{
 
		try {
			OutputStream out = new FileOutputStream(new File(
					uploadedFileLocation));
			int read = 0;
			byte[] bytes = new byte[1024];
 
			out = new FileOutputStream(new File(uploadedFileLocation));
			while ((read = uploadedInputStream.read(bytes)) != -1) {
				out.write(bytes, 0, read);
			}
			out.flush();
			out.close();
		} catch (IOException e) {
			throw new RuntimeException("IOError: "+e.getMessage());
		}
 
	}
	
	protected void validateMessage(SystemMessage message)
    {
    	
		if (message == null){
			throw new UserException(UserException.INVALID_MESSAGE);
		}
		
		if (message.subject.length() == 0 || message.subject.length() > 40){
			throw new UserException(UserException.INVALID_MESSAGE_SUBJECT);
		}
		
		if (message.body.length() == 0 || message.body.length() > 10000){
			throw new UserException(UserException.INVALID_MESSAGE_BODY);
		}
		
    }
    
    protected void validateIcon(UserIcon icon)
    {
    	
		
		if (icon.iconKey == null || icon.iconKey.length() == 0 || !icon.iconKey.matches("^[a-zA-z_]+$")){
			throw new IconException(IconException.INVALID_ICON_KEY);
		}
		
		if (icon.iconName == null || icon.iconName.length() == 0 || icon.iconName.length() > 20){
			throw new IconException(IconException.INVALID_ICON_NAME);
		}
		
		if (icon.level < 1 || icon.level > 4){
			throw new IconException(IconException.INVALID_ICON_LEVEL);
		}
		
		if (icon.deviceType != null)
		{
			Boolean validDeviceType = false;
			for (DeviceType type: DeviceType.values())
			{
				if (type.value().equals(icon.deviceType)){
					validDeviceType = true;
					break;
				}
			}
			
			if (!validDeviceType){
				throw  new IconException(IconException.INVALID_DEVICE_TYPE);
			}
		}
    }
    
   
	
	

}
