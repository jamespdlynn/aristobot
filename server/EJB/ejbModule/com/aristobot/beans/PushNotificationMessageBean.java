package com.aristobot.beans;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.URL;
import java.net.URLEncoder;
import java.util.List;

import javax.ejb.ActivationConfigProperty;
import javax.ejb.MessageDriven;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.ObjectMessage;
import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLSession;

import com.aristobot.data.AuthenticationData;
import com.aristobot.data.PushNotification;
import com.aristobot.managers.JDBCManager;
import com.aristobot.managers.LogManager;
import com.aristobot.repository.AuthenticationRepositiory;
import com.aristobot.repository.GameRepository;
import com.aristobot.utils.Constants;
import com.aristobot.utils.Constants.DeviceType;
import com.google.android.gcm.server.Result;
import com.google.android.gcm.server.Sender;
import com.notnoop.apns.APNS;
import com.notnoop.apns.ApnsService;


/**
 * Message-Driven Bean implementation class for: MailMessageBean
 *
 */
@MessageDriven(mappedName="jms/pushNotificationQueue",
		activationConfig = { @ActivationConfigProperty(
				propertyName = "destinationType", propertyValue = "javax.jms.Queue"
		) })
public class PushNotificationMessageBean implements MessageListener {

	
    private static final String C2DM_URL = "https://android.apis.google.com/c2dm/send";
    private static final String PARAM_REGISTRATION_ID = "registration_id";
    private static final String PARAM_COLLAPSE_KEY = "collapse_key";
    private static final String UTF8 = "UTF-8";
    private static final String MISMATCH_SENDER_ERROR = "MismatchSenderId";
    
    private static final String APNS_PASS = "fR0gg3r56!";
    private static final String APNS_SANDBOX_PASS = "fR0gg3r!";
    private static final String GOOGLE_AUTH_KEY = "DQAAALUAAABQC93bJgR_LqBPxO0GTLDcQ6urNqldWduW1TM1jkfPwnRBkwnLEl3uq8PW1nuXeapGeQRaJKOwc-ZcQhMwyvpI_xA8D41OmJ8l3nQmVSv3Ff1wymYeSQ47jDP7VID75GPeGW_7WA2BoUjuM93W1dGOefJeAG1dW5fcRHD8heaJIcCoovg-UTsVuD0AMOmqg-QNE7IGJDBfMP7UarXuD8mBfwKjEGfgeDLEUr2rZxdINHM4smZTuUN43dHqlwKXpXg";
    private static final String GCM_API_KEY =  "AIzaSyBOJGE76rRz_sA06cehMt8zUBudJyv8nwo";
        
     
	private JDBCManager dbManager;
	private AuthenticationRepositiory authRepo;
	private GameRepository gameRepo;
	
	private Sender sender;
	
	{
		HttpsURLConnection.setDefaultHostnameVerifier(new HostnameVerifier() {
			@Override
			public boolean verify(String hostname, SSLSession session) {
				return true;
			}
		});
	}
	
	public PushNotificationMessageBean()
	{
		dbManager = new JDBCManager(); 
		authRepo = new AuthenticationRepositiory(dbManager);
		gameRepo = new GameRepository(dbManager);
		sender = new Sender(GCM_API_KEY);
	}
	
	private Boolean isPushEnabled(AuthenticationData data){
	    return data.isValid && data.deviceType != DeviceType.OTHER && data.pushNotificationToken != null && data.pushNotificationToken.length() > 0;
	}
	    
    private ApnsService getApnsService(int applicationId){
    	
    	String certPath = Constants.APNS_PATH+applicationId+".p12";
    	
    	try{    		
	    	if (Constants.APNS_SANDBOX){
	    		return APNS.newService().withCert(certPath, APNS_SANDBOX_PASS).withSandboxDestination().build();
	    	}else{
	    		return APNS.newService().withCert(certPath, APNS_PASS).withProductionDestination().build();
	    	}
    	}
    	catch (Exception e){
    		LogManager.logException("Unable to create APN Service with given cert: "+certPath, e);
    	}
    	
    	return null;
    }
	    

    public void onMessage(Message message) 
    {
    	try{
    		PushNotification pn = (PushNotification)((ObjectMessage)message).getObject();
    		sendPushNotification(pn);
    	}
        catch (Exception e){
        	LogManager.logException("Error parsing Push Notifcation Message",e);
        }
    }
    
    public void sendPushNotification(PushNotification pn)
    {
    	try
    	{
    		dbManager.connect(); 
    		
    		ApnsService service = getApnsService(pn.applicationId);
    		List<AuthenticationData> authDataList = authRepo.getAuthenticatedUsers(pn.username, pn.applicationId);
        	
        	for (AuthenticationData data : authDataList)
        	{
        		if (!isPushEnabled(data)){
        			continue;
        		}
        		
    			if (data.deviceType == DeviceType.IOS && service != null)
    			{
	    			int badgeNumber = gameRepo.getNumPendingGames(pn.username, pn.applicationId);
	    			if (pn.badgeOnly){
	    				sendIOSBadge(service, data.pushNotificationToken, badgeNumber);
	    			}else{
	    				sendIOSMessage(service, data.pushNotificationToken, pn.message, badgeNumber);
	    			}
	    			
	    		}
	    		else if (data.deviceType == DeviceType.ANDROID && !pn.badgeOnly){
	    			sendAndroidMessage(data.pushNotificationToken, ""+data.hashCode(), pn.message, pn.params);
	    		}
        	}
    	}
    	catch (Exception e){
    		LogManager.logException("Error sending push notification",e); 
    	}
    	finally{
    		dbManager.close();
    	}
    }

    
  
    private void sendIOSBadge(ApnsService service, String token, int badgeNumber){
    	try{
        	String payload = APNS.newPayload().badge(badgeNumber).build();
        	service.push(token, payload);
    	}
    	catch (Exception e){
			LogManager.logException(e);
		}
    }
    
    private void sendIOSMessage(ApnsService service, String token, String message, int badgeNumber) 
    {
    	try{
        	String payload = APNS.newPayload().alertBody(message).badge(badgeNumber).sound("chime").build();
        	service.push(token, payload);
    	}
    	catch (Exception e){
			LogManager.logException(e);
		}
    }
    
    private void sendAndroidMessage(String token, String collapseKey, String message, String params){
    	
    	try{


        	com.google.android.gcm.server.Message msg = new com.google.android.gcm.server.Message.Builder()
	        												.collapseKey(collapseKey)
			        										.addData("message", message)
			        										.addData("parameters", params).build();
		        	
            Result result = sender.send(msg, token, 3);
            
            if (result.getMessageId() == null){
            	
            	//If a mismatched sender id then device may be using older C2DM messaging id system
            	if (result.getErrorCodeName().equalsIgnoreCase(MISMATCH_SENDER_ERROR)){
            		sendC2DMMessage(token, collapseKey, message, params);
            	}else{
            		throw new Exception("GCM Error: "+result.getErrorCodeName());
            	}

            }
    	}
    	catch (Exception e){
			LogManager.logException(e);
		}
	
    }
    
    //Deprecated Android Device Messaging, only used for older versions of App
    private void sendC2DMMessage(String token, String collapseKey, String message, String params)
    {
    	try
    	{
	    	URL url = new URL(C2DM_URL); 
			
			
			HttpsURLConnection request = (HttpsURLConnection) url.openConnection();
	        request.setDoOutput(true);
	        request.setDoInput(true);
	        	                
	        StringBuilder buf = new StringBuilder();
	        buf.append(PARAM_REGISTRATION_ID).append("=").append((URLEncoder.encode(token, UTF8)));
	        buf.append("&"+PARAM_COLLAPSE_KEY).append("=").append((URLEncoder.encode(collapseKey, UTF8)));
	        buf.append("&data.message").append("=").append((URLEncoder.encode(message, UTF8)));
	        buf.append("&data.parameters").append("=").append((URLEncoder.encode(params, UTF8)));
	        
	        request.setRequestMethod("POST");
	        request.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
	        request.setRequestProperty("Content-Length", buf.toString().getBytes().length+"");
	        request.setRequestProperty("Authorization", "GoogleLogin auth=" + GOOGLE_AUTH_KEY);
	        
	        OutputStreamWriter post = new OutputStreamWriter(request.getOutputStream());
	        post.write(buf.toString());
	        post.flush();
			
			if (request.getResponseCode() != 200){
				request.disconnect();
				throw new Exception("Invalid C2DM Response Code :"+request.getResponseCode());
			}
			// Read the response
			BufferedReader reader = new BufferedReader(new InputStreamReader(
					request.getInputStream()));
			String line = null;
			while ((line = reader.readLine()) != null) {
				System.out.println(line);
				if (line.contains("Error")){
					reader.close();
					throw new Exception("C2DM Error :"+line);
				}
			}
			
			request.disconnect();
		
		
    	}
    	catch (Exception e){
			LogManager.logException(e);
		}
    }
    
   

}
