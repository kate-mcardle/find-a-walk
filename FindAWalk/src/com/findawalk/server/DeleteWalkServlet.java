package com.findawalk.server;
import com.findawalk.Dog;
import com.findawalk.DogOwner;
import com.findawalk.OfyService;
import com.findawalk.Walk;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@SuppressWarnings("serial")
public class DeleteWalkServlet extends HttpServlet {

	public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		doPost(req, res);
	}
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		OfyService.ofy().clear();
		
		Long id = new Long(req.getParameter("walkId"));
		HttpSession session = req.getSession();
		Long userId = (Long)session.getAttribute("account");
		DogOwner thisUser = OfyService.ofy().load().type(DogOwner.class).id(userId).get();
		if (thisUser.walkIdsAttending != null) {
			thisUser.walkIdsAttending.remove(id);
		}
		if (thisUser.walkIdsHosting != null) {
			thisUser.walkIdsHosting.remove(id);	
		}
		OfyService.ofy().save().entity(thisUser).now();
	
		Walk walkToDelete = OfyService.ofy().load().type(Walk.class).id(id).get();
		if (walkToDelete.attendeeIds != null) {
			for (Long attendeeId : walkToDelete.attendeeIds) {
				DogOwner attendee = OfyService.ofy().load().type(DogOwner.class).id(attendeeId).get();
				if (attendee.walkIdsAttending != null) {
					attendee.walkIdsAttending.remove(id);
				}
				OfyService.ofy().save().entity(attendee).now();
			}			
		}
		OfyService.ofy().save().entity(walkToDelete).now();
		
		OfyService.ofy().delete().type(Walk.class).id(id).now();
		resp.sendRedirect("/manageWalks");
	}
}
