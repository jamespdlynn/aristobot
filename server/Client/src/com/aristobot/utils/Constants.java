package com.aristobot.utils;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.lang.reflect.Field;
import java.util.LinkedList;
import java.util.List;
import java.util.Properties;

import com.aristobot.data.AdminTask;
import com.aristobot.data.EmailMessage;
import com.aristobot.data.PushNotification;
import com.aristobot.managers.LogManager;

/**
 * Static class that contains constant values accessible from any class
 * @author James
 *
 */
public class Constants 
{
		
	private static String SERVER_PROPERTIES_PATH = "server.properties";
	private static String APPLICATION_PROPERTIES_PATH = "application.properties";
	
	//Server Properties
	public static String CURRENT_VERSION_NUMBER = "1.45";
	public static String REQUIRED_VERSION_NUMBER  = "1.25";
	
	public static String DATABASE_JDNI = "jdbc/mysql";
	public static String QUEUE_CONNECTION_FACTORY_JDNI = "jms/queueConnectionFactory";
	public static String MEDIA_DIRECTORY = "../media";
	public static String DOMAIN_NAME = "http://aristobotgames.com";
	public static String MEDIA_DOMAN = "http://d3cuw0f9oklxkl.cloudfront.net";
	public static String INBOUND_EMAIL_ADDRESS = "info@aristobotgames.com";
	public static String OUTBOUND_EMAIL_ADDRESS = "Aristobot Games<info@aristobotgames.com>";
	public static Integer DEBUG_PORT = 2080;
	
	public static Boolean APNS_SANDBOX = false; 
	public static String APNS_PATH = "../data/apns/";
	
	
	public static Boolean CACHE_ENABLED = true;
    public static String AUTH_CACHE_NAME = "authCache"; 
    public static String GAME_CACHE_NAME = "gameCache";
	
	//Application Properties
	public static Integer ACCESS_TOKEN_EXPIRATION_TIME_MINUTES = 30;
	public static Integer REFRESH_TOKEN_EXPIRATION_TIME_DAYS = 28;
	public static Integer MIN_GAMES_PLAYED_FOR_RANK = 3;
	public static Integer NUM_RANKED_USERS = 50;
	public static Integer MAX_ROUND_TIME_DAYS = 6;
    public static Integer GAME_EXPIRATION_TIME_DAYS = 7;
    public static Integer GAME_MIN_RUNNING_TIME_MINUTES = 30;
    public static Integer MIN_USERNAME_LENGTH = 5;
    public static Integer MAX_USERNAME_LENGTH = 12;
    public static Integer MIN_PASSWORD_LENGTH = 6;
    public static Integer MAX_PASSWORD_LENGTH = 15;
    public static Integer MAX_GAME_PLAYERS = 4;
    public static Integer MAX_GAMES = 10;
    public static Integer MAX_GAMES_PER_OPPONENT= 1;
    public static Integer RATING_MESSAGE_DAYS = 7;
    public static Integer MAX_SEARCH_RESULTS = 10;
    public static Integer MAX_GAME_TURNS = 150;
    
    //Other Properties
    public static String CACHE_CONFIG_PATH = "ehcache.xml";
    public static Integer ADMIN_APPLICATION_ID = 100003;
    public static String ARISTOBOT_ICON_KEY = "sir_robot";
	public static String REGISTRATION_MESSAGE_ID = "e57be7a77564410f911f975328b36d4d";
    
    
    public static void loadConfigFile()
    {
	       List<String> serverKeys = new LinkedList<String>();
	       serverKeys.add("DATABASE_JDNI");
	       serverKeys.add("QUEUE_CONNECTION_FACTORY_JDNI");
	       serverKeys.add("MEDIA_DIRECTORY"); 
	       serverKeys.add("DOMAIN_NAME");
	       serverKeys.add("MEDIA_DOMAN");
	       serverKeys.add("INBOUND_EMAIL_ADDRESS");
	       serverKeys.add("OUTBOUND_EMAIL_ADDRESS");
	       serverKeys.add("DEBUG_PORT");
	       serverKeys.add("CACHE_ENABLED");
	       serverKeys.add("AUTH_CACHE_NAME");
	       serverKeys.add("GAME_CACHE_NAME");
	       serverKeys.add("APNS_PATH");
	       serverKeys.add("APNS_SANDBOX");
	       
	       loadProperties(SERVER_PROPERTIES_PATH, serverKeys);
           
           List<String> applicationKeys = new LinkedList<String>();
           applicationKeys.add("ACCESS_TOKEN_EXPIRATION_TIME_MINUTES");
           applicationKeys.add("REFRESH_TOKEN_EXPIRATION_TIME_DAYS");
           applicationKeys.add("MIN_GAMES_PLAYED_FOR_RANK");
           applicationKeys.add("NUM_RANKED_USERS");
           applicationKeys.add("MAX_ROUND_TIME_DAYS");
           applicationKeys.add("GAME_EXPIRATION_TIME_DAYS");
           applicationKeys.add("GAME_MIN_RUNNING_TIME_MINUTES");
           applicationKeys.add("MIN_USERNAME_LENGTH"); 
           applicationKeys.add("MAX_USERNAME_LENGTH");
           applicationKeys.add("MIN_PASSWORD_LENGTH");
           applicationKeys.add("MAX_PASSWORD_LENGTH"); 
           applicationKeys.add("MAX_GAME_PLAYERS");
           applicationKeys.add("MAX_GAMES");
           applicationKeys.add("MAX_GAMES_PER_OPPONENT");
           applicationKeys.add("RATING_MESSAGE_DAYS");
           applicationKeys.add("MAX_SEARCH_RESULTS");
           
           loadProperties(APPLICATION_PROPERTIES_PATH, applicationKeys);
    }
    
    private static void loadProperties(String filePath, List<String> keys)
    {
    	Properties props = new Properties();
    	try{
    		props.load(new FileInputStream(filePath));
    	}
    	catch (Exception e){
    		LogManager.logException("Could not load "+filePath, e);
    	}
    	
    	Boolean hasNewField = false;
    	
	  	for (String key : keys)
	  	{
	  		try 
	  		{
	  			Field field = Constants.class.getField(key);
		  		Class<?> type = field.getType();
		  		
		  		if (props.containsKey(key))
		  		{
		  			//If the config file contains a value with this item
	  				if (type.equals(Integer.class)){
	  					field.set(null, new Integer(props.getProperty(key)));
	  				}
	  				else if (type.equals(String.class)){
	  					field.set(null, props.getProperty(key));
	  				}
	  				else if (type.equals(Boolean.class)){
	  					field.set(null, props.getProperty(key).equalsIgnoreCase("true"));
	  				}
	  					  				
	  				
		  		}
		  		else{
		  			//If not save this value to the file
		  			props.setProperty(key, field.get(null).toString()); 
					hasNewField = true; 
		  		}
	  		}
	  		catch (Exception e){
	  			LogManager.logException("Error loading config property: "+key, e);
	  		}
	  		
	  	}
	      	
	  	//If has new changes write to the file
	  	if (hasNewField)
	  	{
	  		try{
	  			props.store(new FileOutputStream(filePath), null);
		  	}
		  	catch (Exception e){
		  		LogManager.logException("Error saving to "+filePath , e);
		  	}
	  	}
    }
            
    public static enum WriteAccess{
    	FULL("full"), 
    	PARTIAL("partial"), 
    	NONE("none"),
    	ADMIN("admin");
    	
    	private final String value;
    	
    	WriteAccess(String v){
    		value = v; 
    	}
    	
        public String value() {
    	    return value;
    	}
    }
    
    public static enum ChatMessageType{
    	USER("user"), 
    	OPPONENT("opponent"), 
    	SYSTEM("system");
    	
    	private final String value;
    	
    	ChatMessageType(String v){
    		value = v; 
    	}
    	
        public String value() {
    	    return value;
    	}
    }
    
    public static enum GameStatus{
    	INITIALIZING("initializing"), 
    	RUNNING("running"), 
    	FINISHED("finished");

    	private final String value;
    	
    	GameStatus(String v){
    		value = v;
    	}
    	
        public String value() {
    	    return value;
    	}
        
        public Boolean equals(String otherValue){
        	return value.equalsIgnoreCase(otherValue);
        }
        
        public static GameStatus generate(String v){
        	return GameStatus.valueOf(v.toUpperCase());
        }
    }
    

    public static enum PlayerStatus{
    	INVITED("invited"), 
    	PLAYING("playing"),
    	WON("won"), 
    	LOST("lost"), 
    	TIED("tied");
    	
    	private final String value;
    	
    	PlayerStatus(String v){
    		value = v;
    	}
    	
        public String value() {
    	    return value;
    	}
        
        public Boolean equals(String otherValue){
        	return value.equalsIgnoreCase(otherValue);
        }
        
        public static PlayerStatus generate(String v){
        	return PlayerStatus.valueOf(v.toUpperCase());
        }
    }
    
    public static enum DeviceType{
    	ANDROID("android"), 
    	IOS("ios"),
    	OTHER("other"),
    	ALL("all");

    	private final String value;
    	
    	DeviceType(String v){
    		value = v;
    	}
    	
        public String value() {
    	    return value;
    	}
        
        public Boolean equals(String otherValue){
        	return value.equalsIgnoreCase(otherValue);
        }
        
        public static DeviceType generate(String v){
        	return DeviceType.valueOf(v.toUpperCase());
        }        
    }
    
    public static enum MessageType{
    	REGISTRATION("registration"), 
    	RATING("rating"),
    	CHAT("chat"),
    	CUSTOM("custom");
    	
    	private final String value;
    	
    	MessageType(String v){
    		value = v;
    	}
    	
        public String value() {
    	    return value;
    	}
        
        public Boolean equals(String otherValue){
        	return value.equalsIgnoreCase(otherValue);
        }
        
        public static MessageType generate(String v){
        	return MessageType.valueOf(v.toUpperCase());
        }        
    }
    
    
    public static enum QueueJDNI{
    	MAIL("jms/mailQueue", EmailMessage.class),
    	PUSH_NOTIFICATION("jms/pushNotificationQueue", PushNotification.class),
    	ADMIN("jms/adminQueue", AdminTask.class);

    	private final String jdniName;
    	private final Class<?> dataClass;
    	
    	QueueJDNI(String jdniName, Class<?> dataClass){
    		this.jdniName = jdniName;
    		this.dataClass =  dataClass;
    	}
    	
        public String getJdniName() {
    	    return jdniName;
    	}
        
        public Class<?> getDataClass() {
    	    return dataClass;
    	}

    }
    
    
}
