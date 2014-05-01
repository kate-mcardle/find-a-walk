package com.findawalk.server;
import com.findawalk.Dog;
import com.findawalk.DogOwner;
import com.findawalk.OfyService;
import com.findawalk.Walk;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Locale;
import java.util.logging.Logger;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@SuppressWarnings("serial")
public class EditWalkServlet extends HttpServlet {

	public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		doPost(req, res);
	}
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		OfyService.ofy().clear();
		Logger log = Logger.getLogger(EditWalkServlet.class.getName());
		Long walkId = new Long(req.getParameter("walkId"));
		Walk walk = OfyService.ofy().load().type(Walk.class).id(walkId).get();
		log.warning("walkId=" + walk.id);
		String dateString = req.getParameter("date"); //2013-01-01
		log.warning("date=" + dateString);
		// 13%3A01
		String pattern = "A";
		String startString = dateString + ", " + req.getParameter("startTime").replaceAll(pattern,  "");
		log.warning("startString=" + startString);
		String endString = dateString + ", " + req.getParameter("endTime").replaceAll(pattern,  "");
		log.warning("endString=" + endString);
		try {
			walk.startTime = new SimpleDateFormat("yyyy-MM-dd, HH:mm", Locale.ENGLISH).parse(startString);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		try {
			walk.endTime = new SimpleDateFormat("yyyy-MM-dd, HH:mm", Locale.ENGLISH).parse(endString);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		if (req.getParameter("latitude") != null && req.getParameter("latitude").length() > 0 
				&& req.getParameter("longitude") != null && req.getParameter("longitude").length() > 0) {
//		if (!walk.location.equals(req.getParameter("location"))) {
			if (req.getParameter("google_location") != null && req.getParameter("google_location").length() > 0) {
				walk.location = req.getParameter("google_location");
				walk.location = walk.location.substring(0, walk.location.length()-5);
				log.warning("google location found: " + walk.location);
			}
			else {
				walk.location = req.getParameter("location");
			}
			walk.latitude = Double.parseDouble(req.getParameter("latitude"));
			log.warning("latitude = " + walk.latitude);
			walk.longitude = Double.parseDouble(req.getParameter("longitude"));
			log.warning("longitude = " + walk.longitude);
			walk.length = Integer.parseInt(req.getParameter("length"));
		}

		DogOwner owner = OfyService.ofy().load().type(DogOwner.class).id(walk.ownerId).get();
		int j = 0;
		for (int i = 0; i < owner.numDogs; i++) {
			String dogNum = "dog" + i;
			if (req.getParameter(dogNum) != null) { // user wants to bring this dog
				Long id = new Long(req.getParameter(dogNum));
				if (!walk.dogIds.contains(id)) {
					walk.dogIds.add(id);
				}
				j++;
			}
			else { // user doesn't want to bring this dog
				Long id = owner.dogIds.get(i);
				if (walk.dogIds.contains(id)) {
					walk.dogIds.remove(id);
				}
			}
		}
		walk.numDogsRSVPd = walk.numDogsRSVPd - walk.numOwnerDogs + j; 
		walk.numOwnerDogs = j;
		walk.maxNumDogs = walk.numOwnerDogs + Integer.parseInt(req.getParameter("maxNumDogs"));
		if (req.getParameter("comments") != null) {
			walk.comments = req.getParameter("comments");
		}
		
		OfyService.ofy().save().entity(walk).now();

		resp.sendRedirect("/manageWalks");
	}
}
