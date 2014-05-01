package com.findawalk.server;

import com.findawalk.DogOwner;
import com.findawalk.OfyService;
import com.findawalk.Walk;
import com.findawalk.WalkDescription;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.logging.Logger;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@SuppressWarnings("serial")
public class SendMessageServlet extends HttpServlet {

	public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		doPost(req, res);
	}
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		OfyService.ofy().clear();
		Logger log = Logger.getLogger("SendMessageServlet");
		
		Long walkId = new Long(req.getParameter("walkId"));
		Walk walk = OfyService.ofy().load().type(Walk.class).id(walkId).get();
		
		String recip = req.getParameter("recip");
		List<String> emails = new ArrayList<String>();
		
		if (recip.equals("all")) { // user owns the walk
			if (walk.attendeeIds != null) {
				for (Long attendeeId : walk.attendeeIds) {
					DogOwner attendee = OfyService.ofy().load().type(DogOwner.class).id(attendeeId).get();
					emails.add(attendee.email);
				}
			}
			else {
				log.warning("Attempted to send message to all attendees on a walk that has no attendees!");
				resp.sendRedirect("/manageWalks");
				return;
			}
		}
		else if (recip.equals("host")) { // user is attending the walk
			DogOwner walkOwner = OfyService.ofy().load().type(DogOwner.class).id(walk.ownerId).get();
			emails.add(walkOwner.email);
		}
		else {
			log.warning("Attempted to send message without giving a valid parameter for 'recip'!");
			resp.sendRedirect("/manageWalks");
			return;
		}
		
		HttpSession httpSession = req.getSession();
		Long userId = (Long)httpSession.getAttribute("account");
		DogOwner thisUser = OfyService.ofy().load().type(DogOwner.class).id(userId).get();
		
		WalkDescription wd = new WalkDescription(walk, userId);
		String description = "";
		if (wd.description.substring(0,1).equals("T")) {
			description = wd.description;
			description = description.replaceFirst("T", "t");
		}
		else {
			description = "on " + wd.description;
		}
		
		String htmlBody;
		String msgIntro = "<p>Hello!</p><p>" + thisUser.name + " has sent you this message about your upcoming walk " + description + ":</p>";
		String msgBody = "<p>" + req.getParameter("msg") + "</p>";
		String msgProfile = "<p><a href=\"http://findawalk.appspot.com/profile.jsp?profileId=" + thisUser.id + "\">View " + thisUser.name + "'s profile</a>.</p>";
		String msgEnd = "<p>Cheers,</p><p>The Find A Walk team</p>";
		htmlBody = msgIntro + msgBody + msgProfile + msgEnd;
		log.warning(htmlBody);
		for (String recipient : emails) {
			Properties props = new Properties();
			Session session = Session.getDefaultInstance(props, null);
			try {
				Message msg = new MimeMessage(session);
				msg.setFrom(new InternetAddress("kate.mca@gmail.com", "Find A Walk"));
				msg.addRecipient(Message.RecipientType.TO,  new InternetAddress(recipient));
				msg.setSubject("Find A Walk: You have been sent a message!");
				Multipart mp = new MimeMultipart();
				MimeBodyPart htmlPart = new MimeBodyPart();
				htmlPart.setContent(htmlBody, "text/html");
				mp.addBodyPart(htmlPart);
				msg.setContent(mp);
				Transport.send(msg);
			} catch (AddressException e) {
				System.out.println("Address Exception = " + e);
			} catch (MessagingException e) {
				System.out.println("Messaging Exception = " + e);
			}
		}
		resp.sendRedirect("/manageWalks");
	}
}
