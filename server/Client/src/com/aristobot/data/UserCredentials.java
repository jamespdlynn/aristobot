package com.aristobot.data;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * Simple wrapper value object containing user information sent up during login or registration.
 * Sent from the client to the server.
 * @author James
 *
 */
@XmlRootElement(name = "com.aristobot.data.UserCredentials")
public class UserCredentials 
{
	public String deviceId;
	
    public String username;
    
    public String password;

    public String emailAddress;

    public String iconKey;
    
    @XmlElement(name = "com.aristobot.data.PushNotificationToken")
    public PushNotificationToken pushNotificationToken;

}
