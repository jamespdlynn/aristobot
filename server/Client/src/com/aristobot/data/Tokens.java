package com.aristobot.data;

import javax.xml.bind.annotation.XmlRootElement;

import com.aristobot.utils.Constants;


@XmlRootElement(name = "com.aristobot.data.Tokens")
public class Tokens {
   public String accessToken;
   public String refreshToken;
   public int expirationTimeMinutes = Constants.ACCESS_TOKEN_EXPIRATION_TIME_MINUTES;
   
   public ApplicationData appData;
}
