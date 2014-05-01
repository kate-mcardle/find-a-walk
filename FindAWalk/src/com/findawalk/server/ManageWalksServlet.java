package com.findawalk.server;
import com.findawalk.DogOwner;
import com.findawalk.OfyService;
import com.findawalk.Walk;
import com.findawalk.WalkDescription;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.IOException;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.util.logging.Logger;

@SuppressWarnings("serial")
public class ManageWalksServlet extends HttpServlet {

	public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		doPost(req, res);
	}
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		OfyService.ofy().clear();
		
	 	Logger log = Logger.getLogger("ManageWalksServlet");
		HttpSession session = req.getSession();
		if (session.getAttribute("account") == null) {
			resp.sendRedirect("manage-walks.jsp");
			return;
		}
		Long userId = (Long)session.getAttribute("account");
		DogOwner thisUser = OfyService.ofy().load().type(DogOwner.class).id(userId).get();
	 	Calendar c = Calendar.getInstance();
	 	c.setTime(new Date());
	 	c.add(Calendar.HOUR, -6);
	 	Date today = c.getTime();
		
		// get all hosting walks
		ArrayList<Walk> futureWalksHosting = new ArrayList<Walk>(); // earliest first
		ArrayList<Walk> pastWalksHosted = new ArrayList<Walk>(); // most recent first
	 	if (thisUser.walkIdsHosting != null) {
	 		ArrayList<Walk> walks = new ArrayList<Walk>();
	 		for (Long walkId : thisUser.walkIdsHosting) {
	 			Walk w = OfyService.ofy().load().type(Walk.class).id(walkId).get();
	 			walks.add(w);
	 		}
	 		Collections.sort(walks);
	 		for (Walk w : walks) {
	 			if (w.startTime.after(today)) {
	 				futureWalksHosting.add(w);
	 			}
	 			else {
	 				pastWalksHosted.add(w);
	 			}
	 		}
	 	}
		
		// get all attending walks
		ArrayList<Walk> futureWalksAttending = new ArrayList<Walk>(); // earliest first
		ArrayList<Walk> pastWalksAttended = new ArrayList<Walk>(); // most recent first
	 	if (thisUser.walkIdsAttending != null) {
	 		ArrayList<Walk> walks = new ArrayList<Walk>();
	 		for (Long walkId : thisUser.walkIdsAttending) {
	 			Walk w = OfyService.ofy().load().type(Walk.class).id(walkId).get();
	 			if (!w.ownerId.equals(userId)) {
	 				walks.add(w);
	 			}	
	 		}
	 		Collections.sort(walks);
	 		for (Walk w : walks) {
	 			if (w.startTime.after(today)) {
	 				futureWalksAttending.add(w);
	 			}
	 			else {
	 				pastWalksAttended.add(w);
	 			}
	 		}
	 	}
	 	Map<String, ArrayList<Walk>> mapOfWalks = new HashMap<String, ArrayList<Walk>>();
	 	if (futureWalksHosting.size() > 0) {
	 		mapOfWalks.put("futureHosting", futureWalksHosting);
	 	}
	 	if (pastWalksHosted.size() > 0) {
	 		mapOfWalks.put("pastHosted", pastWalksHosted);
	 	}
	 	if (futureWalksAttending.size() > 0) {
	 		mapOfWalks.put("futureAttending", futureWalksAttending);
	 	}
	 	if (pastWalksAttended.size() > 0) {
	 		mapOfWalks.put("pastAttended", pastWalksAttended);
	 	}
        Type t = new TypeToken<Map<String, ArrayList<Walk>>>(){}.getType();
		Gson gson = new Gson();
		String json = gson.toJson(mapOfWalks, t);
		req.setAttribute("map", json);
		try {
			req.getRequestDispatcher("/manage-walks.jsp").forward(req, resp);
		} catch (ServletException e) {
			log.warning("problem forwarding request");
			e.printStackTrace();
		}

	}
}
