package com.aristobot.services;

import java.util.List;

import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.Response;

import com.aristobot.data.ApplicationData;
import com.aristobot.data.AuthenticationData;
import com.aristobot.data.DeviceData;
import com.aristobot.data.EmailMessage;
import com.aristobot.data.PushNotificationToken;
import com.aristobot.data.RegistrationData;
import com.aristobot.data.Tokens;
import com.aristobot.data.User;
import com.aristobot.data.UserCredentials;
import com.aristobot.data.UserIcon;
import com.aristobot.exceptions.AuthenticationException;
import com.aristobot.exceptions.UserException;
import com.aristobot.managers.AuthenticationManager;
import com.aristobot.managers.LogManager;
import com.aristobot.managers.JDBCManager;
import com.aristobot.managers.JMSQueueManager;
import com.aristobot.repository.AuthenticationRepositiory;
import com.aristobot.repository.IconRepository;
import com.aristobot.repository.MessageRepository;
import com.aristobot.repository.UserRepository;
import com.aristobot.utils.Constants;
import com.aristobot.utils.Constants.DeviceType;
import com.aristobot.utils.Constants.MessageType;
import com.aristobot.utils.Constants.QueueJDNI;
import com.aristobot.utils.Utility;

/**
 * Service used to authenticate and grant a user an accesstoken they can use
 * to make subsequent service calls
 * @author James
 *
 */
@Path("/authentication")
public class AuthenticationService
{
	private JDBCManager dbManager;
	private AuthenticationManager authManager;
	
	public AuthenticationService()
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
    @Path("/connect")
    @Consumes("application/xml")
	@Produces("text/xml")
	public RegistrationData connect(@Context HttpHeaders headers, DeviceData deviceData)
	{
		RegistrationData registrationData;
		
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireValidApiKey();
    		
    		if (deviceData==null || deviceData.deviceType == null){
    			throw new AuthenticationException(AuthenticationException.INVALID_DEVICE_TYPE);
    		}
    		
    		//Verify the device type String is a valid type
    		Boolean validDeviceType = false;
    		for (DeviceType type : DeviceType.values())
    		{
    			if (type.value().equals(deviceData.deviceType)){
    				validDeviceType = true;
    				break;
    			}
    		}
    			
    		if (!validDeviceType){
    			throw new AuthenticationException(AuthenticationException.INVALID_DEVICE_TYPE);
    		}
    		
    		registrationData = new RegistrationData();
    		AuthenticationRepositiory authRepo = new AuthenticationRepositiory(dbManager);
    		if (deviceData.deviceId == null || deviceData.deviceId.length() == 0)
    		{
    			deviceData.deviceId = Utility.generateRandomDeviceId();
    			authRepo.addDevice(deviceData);
    		}
    		else
    		{
    			AuthenticationData authData = authRepo.getAuthenticatedUser(deviceData.deviceId, authManager.getApplicationId());

    			if (authData.isValid){
    				registrationData.registeredUsername = authData.username;
        		}
    			else{
    				authRepo.addDevice(deviceData);
    			}
    		}    		
    		
    		IconRepository repo = new IconRepository(dbManager);
    		
    		registrationData.deviceId = deviceData.deviceId;
    		registrationData.defaultIcons = repo.getDefaultIcons(authManager.getApplicationId(), deviceData.deviceType);	
    		registrationData.appData = createApplicationData();
    	    
    	    dbManager.commit();    
    	}
	    catch (RuntimeException e){
	    	dbManager.rollback();
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
	    
	    return registrationData;
	}
	
	 /**
     * This call adds a User to the Database, used mainly for registration
     * @param creds UserCredentials object containing necessary User Data
     * @return Response Object with 201 Success Message on successful addition of User
     */
    @POST
    @Path("/registerUser")
    @Consumes("application/xml")
	@Produces("application/xml")
	public Tokens registerUser(@Context HttpHeaders headers, UserCredentials creds)
	{
    	Tokens tokens;
    	
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullWriteAccess();
        	
        	AuthenticationRepositiory authRepo = new AuthenticationRepositiory(dbManager);
        	UserRepository userRepo = new UserRepository(dbManager);
        	IconRepository iconRepo = new IconRepository(dbManager);
        	MessageRepository messageRepo = new MessageRepository(dbManager);
        	
        	int applicationId = authManager.getApplicationId();
        	
        	if (creds.deviceId == null) {
        		throw new AuthenticationException(AuthenticationException.INVALID_DEVICE_ID);
        	}
        	
        	AuthenticationData deviceData = authRepo.authenticateDeviceId(creds.deviceId);
        	        	
        	if (!deviceData.isValid){
        		throw new AuthenticationException(AuthenticationException.INVALID_DEVICE_ID);
        	}
    		if (!Utility.isValidUserName(creds.username)) {
                throw new UserException(UserException.INVALID_USER_NAME);
            }
            //Validate the password is given and has valid character length
            else if (!Utility.isValidPassword(creds.password)) {
                throw new UserException(UserException.INVALID_PASSWORD);
            }
            //Validate the email address is given and is in valid format
            else if (!Utility.isValidEmailAddress(creds.emailAddress)) {
                throw new UserException(UserException.INVALID_EMAIL_ADDRESS);
            } 
            //Validate the icon key is given and exists in the database
            else if (!Utility.hasLengthOfAtleast(creds.iconKey,1) || !iconRepo.iconExists(creds.iconKey)){
            	throw new UserException(UserException.INVALID_ICON_ID);
            }
            //Validate that this username does not already exist to another user
            else if (userRepo.userExists(creds.username)) {
                throw new UserException(UserException.DUPLICATE_USER_NAME);
            }
            //Validate that this email address does not already exist to another user
            else if (userRepo.getUserByEmail(creds.emailAddress) != null) {
                throw new UserException(UserException.DUPLICATE_EMAIL_ADDRESS);
            }
    		
    		userRepo.addUser(creds);
    		iconRepo.addDefaultIcons(creds.username, deviceData.deviceType);
    		
    		grantBonusIcons(creds.username, applicationId);
    		
    		authRepo.setRegisteredUsername(creds.username, deviceData.deviceId);
    		
    		if (creds.pushNotificationToken != null){
    			authRepo.deletePushNotifcationToken(creds.pushNotificationToken);
	    	}
    		
    		String refreshToken = authRepo.addAuthenticatedUser(applicationId, creds.username, creds.deviceId, creds.pushNotificationToken);
    		String accessToken = authRepo.createAccessToken(refreshToken);
    		authManager.setAccessToken(accessToken);
    		authManager.authenticateAccessToken();
    	    
    	    tokens = new Tokens();
    	    tokens.refreshToken = refreshToken;
    	    tokens.accessToken = accessToken;
    	    tokens.appData = createApplicationData();
    	    
    	    messageRepo.addMessageToUser(Constants.REGISTRATION_MESSAGE_ID, creds.username);
    	    
    	    dbManager.commit();    
    	}
	    catch (RuntimeException e){
	    	dbManager.rollback();
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
	    
	    return tokens;	
	    
	    
	}
    /**
     * Authenticate a user using a given username and password
     * @param creds UserCredentials value object containing both a username and password
     * @return newly generated access token
     * @throws AuthenticationException
     */
    @POST
	@Path("/login")
    @Consumes("application/xml")
    @Produces("application/xml")
    public Tokens login(@Context HttpHeaders headers, UserCredentials creds)
    {       
    	
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireValidApiKey();
    		    		 
    		AuthenticationRepositiory repo = new AuthenticationRepositiory(dbManager);
    		
    		if (creds.deviceId == null || !repo.authenticateDeviceId(creds.deviceId).isValid){
        		throw new AuthenticationException(AuthenticationException.INVALID_DEVICE_ID);
        	}
        	
    		int applicationId = authManager.getApplicationId();
			String username = repo.authenticateUserLogin(creds.username, creds.password);
						
			//If the username and password are not valid throw AuthenticationException
	    	if (username == null){
	    		 throw new AuthenticationException(AuthenticationException.LOGIN_FAILED);
	    	} 
	    	
	    	//Add the User to the ApplicationUser table if they do not already exist
	    	if (repo.addApplicationUser(applicationId, username)){
	    		grantBonusIcons(username, applicationId);
	    	}
	    	
	    	repo.setRegisteredUsername(username, creds.deviceId);
	    	
	    	if (creds.pushNotificationToken != null){
	    		repo.deletePushNotifcationToken(creds.pushNotificationToken);
	    	}
	    		    		    	
	    	String refreshToken = repo.addAuthenticatedUser(applicationId, username, creds.deviceId, creds.pushNotificationToken);
    		String accessToken = repo.createAccessToken(refreshToken);
    		authManager.setAccessToken(accessToken);
    		authManager.authenticateAccessToken();
    		
	    	Tokens tokens = new Tokens();
	    	tokens.refreshToken = refreshToken;
	    	tokens.accessToken = accessToken;
	    	tokens.appData = createApplicationData();
	    	
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
    
	@POST
	@Path("/autoLogin")
    @Produces("application/xml")
    @Consumes("text/xml")
    public Tokens autologin(@Context HttpHeaders headers, String refreshToken)
    {        	
		
		try{ 
			dbManager.connect();
			
			authManager.setHeaders(headers.getRequestHeaders());
			authManager.requireValidApiKey();
			
	    	AuthenticationRepositiory repo = new AuthenticationRepositiory(dbManager);
	    	
			if (!repo.isAuthenticated(refreshToken)){
				throw new AuthenticationException(AuthenticationException.AUTO_LOGIN_FAILED);
			}
			
			repo.updateRefreshToken(refreshToken);
			repo.deleteAllAccessTokens(refreshToken);
			
			String accessToken = repo.createAccessToken(refreshToken);
			authManager.setAccessToken(accessToken);
    		authManager.authenticateAccessToken();
    		
    		Tokens tokens = new Tokens();
	    	tokens.refreshToken = refreshToken;
	    	tokens.accessToken = accessToken;
	    	tokens.appData = createApplicationData();
	    	
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
	
	@POST
	@Path("/setPushNotificationToken")
    @Produces("application/xml")
    @Consumes("application/xml")
    public Response setPushNotificationToken(@Context HttpHeaders headers, PushNotificationToken pushNotificationToken)
    {        			
		try{ 
			dbManager.connect();
			
			authManager.setHeaders(headers.getRequestHeaders());
			authManager.requireFullAuthentication();
			
	    	if (pushNotificationToken == null || pushNotificationToken.token == null){
	    		throw new AuthenticationException(AuthenticationException.INVALID_PUSH_NOTIFCATION_TOKEN);
	    	}
	    	
	    	AuthenticationRepositiory repo = new AuthenticationRepositiory(dbManager);
	    	repo.deletePushNotifcationToken(pushNotificationToken);
	    	repo.updatePushNotifcationToken(authManager.getRefreshToken(), pushNotificationToken);
	        
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
	
	@POST
	@Path("/deletePushNotificationToken")
    @Produces("application/xml")
    @Consumes("text/xml")
    public Response deletePushNotificationToken(@Context HttpHeaders headers)
    {        			
		try{ 
			dbManager.connect();
			
			authManager.setHeaders(headers.getRequestHeaders());
			authManager.requireFullAuthentication();

	    	AuthenticationRepositiory repo = new AuthenticationRepositiory(dbManager);
	    	repo.deletePushNotifcationToken(authManager.getRefreshToken());
	        
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
    
    
    /**
     * Deauthenticate a user by deleting their access token from the database
     */
    @POST
	@Path("/logout")
    public Response logout(@Context HttpHeaders headers)
    {   
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		
    		AuthenticationRepositiory repo = new AuthenticationRepositiory(dbManager);
        	
        	repo.deleteAuthenticatedUser(authManager.getRefreshToken());
        	dbManager.commit();
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
    @Consumes("application/xml")
    @Path("/forgotPassword")
    public Response forgotPassword(@Context HttpHeaders headers, UserCredentials creds)
    {
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireValidApiKey();
    		
    		AuthenticationRepositiory authRepo = new AuthenticationRepositiory(dbManager);
    		
    		if (creds.deviceId == null || !authRepo.authenticateDeviceId(creds.deviceId).isValid){
        		throw new AuthenticationException(AuthenticationException.INVALID_DEVICE_ID);
        	}
    		
    		UserRepository userRepo = new UserRepository(dbManager);
    		User user = null;
    		
    		if (creds.username != null && creds.username.length() > 0){
    			user = userRepo.getUser(creds.username);
    			
    			if (user == null){
    				throw new UserException(UserException.INVALID_USER_NAME);
    			}
    		}
    		else if (creds.emailAddress != null && creds.emailAddress.length() > 0){
 
    			user = userRepo.getUserByEmail(creds.emailAddress);
    			
    			if (user == null){
    				throw new UserException(UserException.INVALID_EMAIL_ADDRESS);
    			}
    		}
    		else{
    			throw new UserException(UserException.INVALID_USER_NAME);
    		}
    	
        	
        	String refreshToken = authRepo.addAuthenticatedUser(Constants.ADMIN_APPLICATION_ID, user.username, creds.deviceId, null);
        	
        	String contactURL = Constants.DOMAIN_NAME+"/contact/support";
        	String accessToken = authRepo.createAccessToken(refreshToken);
        	
        	String forgotPasswordLink = Constants.DOMAIN_NAME+"/forgotPassword.jsp?ac="+accessToken;
        	
        	String subject = "Aristobot Games Account Credentials Enquiry";
        	
        	String body = "<p>A request has been made for your Aristobot Games Account Credentials. Your username along with a link to reset your password should be printed below.</p>" +
	  		      		  "<p><b>Username: </b>"+user.username+"<br/><a href='"+forgotPasswordLink+"'>Click here to reset your password</a></p>" +
	  		      		  "<p>If you are still having problems authenticating or think you have received this email in error, please <a href='"+contactURL+"'>contact us</a>.</p>"+
	  		      		  "<p>Thanks,<br/>Aristobot Games</p>";
        	
        	JMSQueueManager queueManager = new JMSQueueManager();
        	queueManager.sendItem(QueueJDNI.MAIL, new EmailMessage(Constants.OUTBOUND_EMAIL_ADDRESS, creds.emailAddress, subject, body, EmailMessage.BODY_MIME_TYPE_HTML));
        	  
        	
        	dbManager.commit();
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
	

    protected ApplicationData createApplicationData()
    {    	
    	ApplicationData appData = new ApplicationData();
    	appData.contactURL = Constants.DOMAIN_NAME+"/contact?enquiry=support";
    	appData.supportURL = Constants.DOMAIN_NAME+"/support";
    	appData.currentVersion = authManager.getApplicationVersion();
    	appData.updateURL = authManager.getAuthData().updateURL;
    	
    	return appData;
    }
    
    protected void grantBonusIcons(String username, int applicationId)
    {
    	try{
    		AuthenticationRepositiory authRepo = new  AuthenticationRepositiory(dbManager);
        	UserRepository userRepo = new UserRepository(dbManager);
        	MessageRepository messageRepo = new MessageRepository(dbManager);
        	
    		User user = userRepo.getUserExtended(username);
    		List<String> pendingInviters = authRepo.getPendingInviters(user.emailAddress, applicationId);
    		
    		AuthenticationData appData = authRepo.getApplicationData(applicationId);
    		
    		if (pendingInviters.size() > 0){
    			
    			IconRepository iconRepo = new IconRepository(dbManager);
    			
    			//Grant user a bonus level 1 icon
    			iconRepo.unlockRandomIcon(username, 1, applicationId);
    			
    			//Grant all inviters a bonus level two icon
    			for (String inviter : pendingInviters){
    				try{
    					UserIcon icon = iconRepo.unlockRandomIcon(inviter, 2, applicationId);
    					
    					//Send a message informing this user of their new icons
        				String body = "<p>Your friend <b>"+username+"</b> (<i>"+user.emailAddress+"</i>) responded to your invite and successfully installed "+appData.applicationName+"!</p>";
        				body += "<p>In return for helping expand this game's user base, a new icon (<i>"+icon.iconName+"</i>) has been added to your account. You can view or select this icon at anytime from your icons screen.</p>";
        				
        				String messageKey = messageRepo.addSystemMessage(icon.iconKey, "You have been rewarded a new icon!", body, MessageType.CUSTOM);
        				messageRepo.addMessageToUser(messageKey, inviter);
        				
        				int oppositionId = userRepo.addOpponent(username, inviter);
        	    		userRepo.addApplicationOppostion(applicationId, oppositionId);
    				}
    				catch (Exception e){
    		    		LogManager.logException(e);
    		    	}
    			}
    			
    			authRepo.deletePendingInvitations(user.emailAddress, applicationId);
    		}
    	}catch (Exception e){
    		LogManager.logException(e);
    	}
    	
    	
    }

}
