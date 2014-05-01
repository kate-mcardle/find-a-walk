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
public class RSVPServlet extends HttpServlet {

	public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		doPost(req, res);
	}
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		OfyService.ofy().clear();
//		Logger log = Logger.getLogger("SendMessageServlet");
		
		Long walkId = new Long(req.getParameter("walkId"));
		Walk walk = OfyService.ofy().load().type(Walk.class).id(walkId).get();
		Long hostId = walk.ownerId;
		HttpSession httpSession = req.getSession();
		Long requestorId = (Long)httpSession.getAttribute("account");		
		
		if (walk.requestorIds == null) {
			walk.requestorIds = new ArrayList<Long>();
		}
		
		String status = "";
		if (walk.attendeeIds == null) {
			walk.attendeeIds = new ArrayList<Long>();
		}
		if (walk.attendeeIds.contains(requestorId)) {
			status = "alreadyAttending";
		} else if (walk.requestorIds.contains(requestorId)) {
			status = "alreadyRequested";
		} else if (walk.ownerId.equals(requestorId)) {
			status = "owner";
		} else {
			DogOwner requestor = OfyService.ofy().load().type(DogOwner.class).id(requestorId).get();
			DogOwner host = OfyService.ofy().load().type(DogOwner.class).id(hostId).get();
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
			String isAre = "";
			if (walk.numDogsRSVPd == 1) { isAre = " dog is"; }
			else { isAre = " dogs are"; }
			String msgIntro = "<p>Hello!</p><p>" + requestor.name + " has asked to join your upcoming walk " + description + ". So far, " 
					+ walk.numDogsRSVPd + isAre + " joining this walk, and you set a limit of " + walk.maxNumDogs + ". (You can accept more dogs "
							+ "than the limit you set, but if you do, we suggest you also "
							+ "<a href=\"http://findawalk.appspot.com/edit-walk.jsp?walkId=" + walk.id + "\">update the limit</a> to avoid confusion.)</p>";
			String msgBodyProfile = "<p>To view " + requestor.name + "'s profile, click here: "
					+ "<a href=\"http://findawalk.appspot.com/profile.jsp?profileId=" + requestor.id + "\">" + requestor.name + "'s profile</a>.</p>";
			String msgBodyRSVP = "<p>To accept this request, click here: <a href=\"http://findawalk.appspot.com/respond.jsp?walkId=" + walk.id 
					+ "&requestorId=" + requestorId + "\">Accept " + requestor.name + "'s request to join your walk</a>. "
							+ "To reject this request, no action is needed.</p>";
			String msgEnd = "<p>Cheers,</p><p>The Find A Walk team</p>";
			htmlBody = msgIntro + msgBodyProfile + msgBodyRSVP + msgEnd;
//			log.warning(htmlBody);
			Properties props = new Properties();
			Session session = Session.getDefaultInstance(props, null);
			try {
				Message msg = new MimeMessage(session);
				msg.setFrom(new InternetAddress("kate.mca@gmail.com", "Find A Walk"));
				msg.addRecipient(Message.RecipientType.TO,  new InternetAddress(host.email));
				msg.setSubject("Find A Walk: Someone has requested to join your walk!");
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

			status = "sent";
			walk.requestorIds.add(requestorId);
			OfyService.ofy().save().entity(walk).now();
		}

		resp.sendRedirect("/rsvp.jsp?walkId=" + walkId + "&status=" + status);
		
	}
}
