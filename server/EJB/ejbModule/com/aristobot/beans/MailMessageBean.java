package com.aristobot.beans;

import javax.annotation.Resource;
import javax.ejb.ActivationConfigProperty;
import javax.ejb.MessageDriven;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.ObjectMessage;
import javax.mail.Message.RecipientType;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import com.aristobot.data.EmailMessage;
import com.aristobot.managers.LogManager;

/**
 * Message-Driven Bean implementation class for: MailMessageBean
 *
 */
@MessageDriven(mappedName="jms/mailQueue",
		activationConfig = { @ActivationConfigProperty(
				propertyName = "destinationType", propertyValue = "javax.jms.Queue"
		) })
public class MailMessageBean implements MessageListener {

	@Resource(name="mailSession", mappedName="mail/Session")
	private Session mailSession;

    public void onMessage(Message message) {
    	
    	try{
    		EmailMessage emailMessage = (EmailMessage)((ObjectMessage)message).getObject();
    		sendEmailMessage(emailMessage);
    	}
        catch (Exception e){
        	LogManager.logException("Error parsing Email Message",e);
        }
        
    }
    
    public void sendEmailMessage(final EmailMessage emailMessage)
    {
    	try{
			 MimeMessage mimeMessage = new MimeMessage(mailSession);
			 
			 mimeMessage.setFrom(new InternetAddress(emailMessage.from));
			 
		     mimeMessage.addRecipient(RecipientType.TO,
		                               new InternetAddress(emailMessage.to));
		     
		      
		     mimeMessage.setSubject(emailMessage.subject);
		      
		     mimeMessage.setContent(emailMessage.body,emailMessage.bodyMimeType);
		
		     Transport.send(mimeMessage);
		}
		catch (MessagingException e){
			LogManager.logException("Error emailing message "+emailMessage.toString(), e);
		}
    }

}
