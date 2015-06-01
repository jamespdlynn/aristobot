package com.aristobot.managers;

import java.util.List;

import com.aristobot.data.AuthenticationData;
import com.aristobot.data.EmailMessage;
import com.aristobot.data.User;
import com.aristobot.repository.AuthenticationRepositiory;
import com.aristobot.repository.GameRepository;
import com.aristobot.repository.MessageRepository;
import com.aristobot.repository.UserRepository;
import com.aristobot.utils.Constants;
import com.aristobot.utils.Constants.DeviceType;
import com.aristobot.utils.Constants.MessageType;
import com.aristobot.utils.Constants.QueueJDNI;

public class MailManager {
	
	private JDBCManager dbManager;
	private JMSQueueManager queueManager;
	private AuthenticationRepositiory authRepo;
	private UserRepository userRepo;

	
	public MailManager(JDBCManager dbManager, JMSQueueManager queueManager)
	{
		this.dbManager = dbManager;
		this.queueManager = queueManager;
		
		authRepo = new AuthenticationRepositiory(dbManager);
		userRepo = new UserRepository(dbManager);
	}
	
	public Boolean queueInvitationEmail(User inviter, String emailAddress, int applicationId, String applicationName){
    	
		User invitee = userRepo.getUserByEmail(emailAddress);
		Boolean existingUser = invitee != null;

		//Don't send emails if this user already has the application
		if (existingUser && userRepo.getApplicationUser(invitee.username, applicationId) != null){
			return false;
		}
		
		//Don't send emails if an invite is already pending
		List<String> pendingInviters = authRepo.getPendingInviters(emailAddress, applicationId);
		for (String username : pendingInviters){
			if (username.equalsIgnoreCase(inviter.username)){
				return false;
			}
		}
		
		
		String body = "<p><a href='mailto:"+inviter.emailAddress+"'>"+inviter.emailAddress+"</a> has invited you to play <b>"+applicationName +"</b>, an online mutiplayer game by <a href='"+Constants.DOMAIN_NAME+"'>Aristobot Games</a>.</p>";
		body  += "<p>"+applicationName+" is available as an installable mobile application for most modern smartphones or tablets.</p>";
		if (existingUser){
			body += "<p>Once you have downloaded and launched the application, login with your existing AristobotGames account and you both you and your friend will be awarded a new icon! ";
		}
		else{
			body += "<p>Once you have downloaded and launched the application, register a new Aristobot Games account (making sure to use this email address), and both you and your friend will be awarded with a bonus icon to use as your in game avatars! ";
		}
		
		body += "You may then start a new game against your challenger (username: <b>"+inviter.username+"</b>).</p>";
		body  += "<p>Good luck and have fun!</p>";
		
		List<AuthenticationData> sites =authRepo.getAllUpdateSites(applicationId);
		for (AuthenticationData site : sites){
			if (site.deviceType != DeviceType.OTHER && site.deviceType != DeviceType.ALL){
				body += "<p><a href='"+site.updateURL+"'>Download the app from "+site.updateName+"!</a></p>";
			}
		}
		
		//If an existing user send the message in game
		if (existingUser){
			MessageRepository messageRepo = new MessageRepository(dbManager);
			String messageKey = messageRepo.addSystemMessage(inviter.icon.iconKey, inviter.username +" has challenged you to play them in "+applicationName+"!", body, MessageType.CUSTOM);
			messageRepo.addMessageToUser(messageKey, invitee.username);
		}
		
		
		EmailMessage message = new EmailMessage();
		message.from = Constants.OUTBOUND_EMAIL_ADDRESS;
		message.to = emailAddress;
		message.subject = inviter.emailAddress.split("@")[0] +" has challenged you to play them in "+applicationName+"!";
		message.body = body;
		message.bodyMimeType = EmailMessage.BODY_MIME_TYPE_HTML;
		
		queueMessage(message);
		
		authRepo.addPendingInvite(inviter.username, emailAddress, applicationId);
		return true;
	}
	
	public Boolean queueMessage(EmailMessage message){
		
		if (authRepo.isSubscribed(message.to)){
			queueManager.queueItem(QueueJDNI.MAIL, message);
			return true;
		}
		
		return false;
	}
}
