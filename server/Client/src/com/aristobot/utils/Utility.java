package com.aristobot.utils;

import java.text.DateFormat;
import java.util.Collections;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Random;
import java.util.UUID;
import java.util.regex.Pattern;

import com.aristobot.data.AuthenticationData;
import com.aristobot.data.RoboDate;
import com.aristobot.data.SystemMessage;
import com.aristobot.data.UserIcon;
import com.aristobot.data.wrappers.MessagesWrapper;
import com.aristobot.managers.JDBCManager;
import com.aristobot.managers.LocalCacheManager;
import com.aristobot.managers.LogManager;

/**
 * Static Utility Class providing a variety of utilty functions
 * @author James
 *
 */
public class Utility  
{
		
	public static void initialize() 
	{
		Constants.loadConfigFile();
		JDBCManager.initializeDatasource(); 
		LocalCacheManager.initializeCache();
	}
	

    public static Boolean equals(String string1, String string2){
    	return string1.compareToIgnoreCase(string2) == 0;
    }
    
    /**
     * Generates a random 32 bit token without the '-' characters.
     * May be used for generating API Keys or access tokens.
     * 
     * @return 32 bit random token string
     */
    public static String generateRandomToken() {
        return UUID.randomUUID().toString().replace("-", "");
    }
    
    public static String generateSeededToken(String seed){
    	return Integer.toString(seed.hashCode());
    }
    
    public static String generateSeededToken(List<String> seeds)
    {
    	Collections.sort(seeds);
    	String concat = "";
    	for (String str:seeds) concat+=(str+"&");
    	return generateSeededToken(concat);
    }
    
    public static String generateRandomDeviceId()
    {
    	StringBuilder hex = new StringBuilder("AA:");
    	
    	Random rand = new Random();
    	
    	for (int i = 0; i < 6; i++){
    		int random = rand.nextInt(256)+16;
    		hex.append(":");
    		hex.append(Integer.toHexString(random).toUpperCase());
    	}
    	
    	return hex.toString();
    }
    
    public static RoboDate generateRoboDate(long time, long currentTime)
    {    	
    	RoboDate date = new RoboDate();
    	date.dateString = DateFormat.getInstance().format(new Date(time));
    	date.timeAgo =  currentTime - time;
    	
    	return date;
    }
    
    public static boolean hasLengthOfAtleast(String string, int length){
    	return string != null && string.length() >= length;
    }

    public static boolean isValidUserName(String username) {
        Pattern p = Pattern.compile("^[a-z0-9_]{5,12}$");
        return p.matcher(username.toLowerCase()).matches();
    }

    public static boolean isValidEmailAddress(String emailAddress) {
    	if (!hasLengthOfAtleast(emailAddress, 5)){
    		return false;
    	}
    	
        Pattern p = Pattern.compile(".+@.+\\.[a-z]+");
        return p.matcher(emailAddress.toLowerCase()).matches();
    }

    public static boolean isValidPassword(String password) {
        return (password.length() >= Constants.MIN_PASSWORD_LENGTH && password.length() <= Constants.MAX_PASSWORD_LENGTH);
    }

    
    /**
     * Static function to determine a future date of a given number of days in the future.
     * Used to determine expiration dates for games or user tokens.
     * 
     * @param daysFromNow 
     * @return the time in milliseconds of the given date from now
     */
    public static long getTimeFromDays(long startTime, int days) {
        return startTime+ (days * 24 * 60 * 60  * 1000);
    }
    
    
    public static long getTimeFromMinutes(long startTime, int minutes) {
        return startTime + (minutes * 60 * 1000);
    }
    
    /**
     * Generates and Icon Object from a given Icon Key
     * 
     * @param iconKey icon key value stored in database
     * @return icon object containing both the given icon key and the url of the icon
     */
    public static UserIcon getIcon(String iconKey) 
    {
        UserIcon icon = new UserIcon();
        icon.iconKey = iconKey;
        icon.iconURL = Constants.MEDIA_DOMAN  + "/icons/" + iconKey + ".png";

        return icon;
    }
    
    public static UserIcon getIcon(String iconKey, String iconName, int level) 
    {
        UserIcon icon = new UserIcon();
        icon.iconKey = iconKey;
        icon.iconName = iconName;
        icon.level = level;
        icon.iconURL = Constants.MEDIA_DOMAN + "/icons/" + iconKey + ".png";

        return icon;
    }
    
    public static UserIcon getIcon(String iconKey, String iconName, int level, String deviceType, int applicationId, Boolean isDefault) 
    {
    	 UserIcon icon = new UserIcon();
         icon.iconKey = iconKey;
         icon.iconName = iconName;
         icon.level = level;
         icon.deviceType = deviceType;
         icon.applicationId = applicationId;
         icon.isDefault = isDefault;
         icon.iconURL = Constants.MEDIA_DOMAN + "/icons/" + iconKey + ".png";
        

         return icon;
    }
    
    public static UserIcon getIconRank(String iconKey, int rank) 
    {    	
        UserIcon icon = new UserIcon();
        icon.iconKey = iconKey;
        icon.iconURL = Constants.MEDIA_DOMAN + "/icons/" + iconKey + ".png";
        icon.rank = rank;
        
        if (rank > 0)
        {
        	icon.rank = rank;
        	
        	if (rank <= 3){
        		icon.badgeURL = Constants.MEDIA_DOMAN + "/badges/gold_shield.png";
        	}
        	else if (rank <= 10){
        		icon.badgeURL = Constants.MEDIA_DOMAN + "/badges/gold_octagon.png";
        	}
        	else if (rank <= 15){
        		icon.badgeURL = Constants.MEDIA_DOMAN + "/badges/silver_shield.png";
        	}
        	else if (rank <= 25){
        		icon.badgeURL = Constants.MEDIA_DOMAN + "/badges/silver_octagon.png";
        	}
        	else if (rank <= 35){
        		icon.badgeURL = Constants.MEDIA_DOMAN + "/badges/bronze_shield.png";
        	}
        	else{
        		icon.badgeURL = Constants.MEDIA_DOMAN + "/badges/bronze_octagon.png";
        	}
        }

        return icon;
    }
    
    public static String buildListQueryParam(int size) {
    	StringBuilder buffer = new StringBuilder("(");
        for (int i=0; i < size; i++){
        	 buffer.append("?");
        	 if (i < size-1){
        		 buffer.append(",");
        	 }
        }
    
        buffer.append(")");
        return buffer.toString();
    }
    

    public static void formatSystemMessage(SystemMessage message, final AuthenticationData authData)
	{
    	try{
    		message.subject = message.subject.replace("{APPLICATION_NAME}", authData.applicationName)
									   		 .replace("{APP_STORE_URL}", authData.updateURL)
									   		 .replace("{APP_STORE_NAME}", authData.updateName);
   		
	   		message.body = message.body.replace("{APPLICATION_NAME}", authData.applicationName)
	   						 .replace("{APP_STORE_URL}", authData.updateURL)
	   						 .replace("{APP_STORE_NAME}", authData.updateName);
    	}catch (Exception e){
    		LogManager.logException(e);
    	}
		
	}
    
    public static MessagesWrapper createMessagesWrapper(List<SystemMessage> messages, final AuthenticationData authData)
	{
    	MessagesWrapper wrapper = new MessagesWrapper();
    	
		for (SystemMessage message: messages){
			formatSystemMessage(message, authData);
			
			if (!message.isRead){
				wrapper.hasUnreadMessages = true;
				if (message.isPriority){
					wrapper.hasUnreadPriorityMessages = true;
				}
			}
		}
    
    	wrapper.messages = messages;
    	
    	return wrapper;
	}
        

   
    
   
}
