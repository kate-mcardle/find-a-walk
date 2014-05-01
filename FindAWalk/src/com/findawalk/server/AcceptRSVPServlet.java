package com.findawalk.server;

import com.findawalk.DogOwner;
import com.findawalk.OfyService;
import com.findawalk.Walk;
import com.findawalk.WalkDescription;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Properties;
//import java.util.logging.Logger;

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
public class AcceptRSVPServlet extends HttpServlet {

	public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		doPost(req, res);
	}
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		OfyService.ofy().clear();
//		Logger log = Logger.getLogger("SendMessageServlet");
		
		Long walkId = new Long(req.getParameter("walkId"));
		Walk walk = OfyService.ofy().load().type(Walk.class).id(walkId).get();
		
		Long requestorId = new Long(req.getParameter("requestorId"));
		DogOwner requestor = OfyService.ofy().load().type(DogOwner.class).id(requestorId).get();
		
		if (walk.requestorIds == null || !walk.requestorIds.contains(requestorId)) {
			resp.sendRedirect("/manageWalks");
			return;
		}
		
		walk.requestorIds.remove(requestorId);
		if (walk.attendeeIds == null) {
			walk.attendeeIds = new ArrayList<Long>();
		}
		walk.attendeeIds.add(requestorId);
		walk.numDogsRSVPd += requestor.numDogs;
		for (Long dogId : requestor.dogIds) {
			walk.dogIds.add(dogId);
		}
		OfyService.ofy().save().entity(walk).now();
		
		if(requestor.walkIdsAttending == null) {
			requestor.walkIdsAttending = new ArrayList<Long>();
		}
		
		if (!requestor.walkIdsAttending.contains(walkId)) {
			requestor.walkIdsAttending.add(walkId);
			OfyService.ofy().save().entity(requestor).now();
			DogOwner host = OfyService.ofy().load().type(DogOwner.class).id(walk.ownerId).get();
			WalkDescription wd = new WalkDescription(walk, requestorId);
			String description = "";
			if (wd.description.substring(0,1).equals("T")) {
				description = wd.description;
				description = description.replaceFirst("T", "t");
			}
			else {
				description = "on " + wd.description;
			}
			
			String htmlBody;
			String msgIntro = "<p>Hello!</p><p>" + host.name + " has approved your request to join the walk " + description + ". "
					+ "You can view this walk on your <a href=\"http://findawalk.appspot.com/manageWalks\">Manage Walks page</a>.</p>";
			String msgEnd = "<p>Cheers,</p><p>The Find A Walk team</p>";
			htmlBody = msgIntro + msgEnd;
//			log.warning(htmlBody);
			Properties props = new Properties();
			Session session = Session.getDefaultInstance(props, null);
			try {
				Message msg = new MimeMessage(session);
				msg.setFrom(new InternetAddress("kate.mca@gmail.com", "Find A Walk"));
				msg.addRecipient(Message.RecipientType.TO,  new InternetAddress(requestor.email));
				msg.setSubject("Find A Walk: Your request to join a walk has been approved!");
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
