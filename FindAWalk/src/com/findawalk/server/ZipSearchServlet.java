package com.findawalk.server;

import com.findawalk.OfyService;
import com.findawalk.Walk;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.IOException;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.logging.Logger;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@SuppressWarnings("serial")
public class ZipSearchServlet extends HttpServlet {

	public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		doPost(req, res);
	}
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		OfyService.ofy().clear();
		Logger log = Logger.getLogger("ZipSearchServlet");
		
		if (req.getParameter("zipcode") == null || req.getParameter("Nlatitude") == null || req.getParameter("Elongitude") == null
				|| req.getParameter("Slatitude") == null || req.getParameter("Wlongitude") == null
				|| req.getParameter("centerLat") == null || req.getParameter("centerLng") == null
				|| req.getParameter("Nlatitude").length() == 0 || req.getParameter("Elongitude").length() == 0
				|| req.getParameter("Slatitude").length() == 0 || req.getParameter("Wlongitude").length() == 0
				|| req.getParameter("centerLat").length() == 0 || req.getParameter("centerLng").length() == 0) {
			resp.sendRedirect("/map.jsp?zipcode=none");
			return;
		}
		String zip = req.getParameter("zipcode");
		Double Nlatitude = Double.parseDouble(req.getParameter("Nlatitude"));
		Double Elongitude = Double.parseDouble(req.getParameter("Elongitude"));
		Double Slatitude = Double.parseDouble(req.getParameter("Slatitude"));
		Double Wlongitude = Double.parseDouble(req.getParameter("Wlongitude"));
		Double centerLat = Double.parseDouble(req.getParameter("centerLat"));
		Double centerLng = Double.parseDouble(req.getParameter("centerLng"));
		log.warning("Nlatitude = " + Nlatitude);
		log.warning("Slatitude = " + Slatitude);
		log.warning("Elongitude = " + Elongitude);
		log.warning("Wlongitude = " + Wlongitude);
		
		String url = "/map.jsp?zipcode=" + zip + "&Nlatitude=" + Nlatitude + "&Elongitude=" + Elongitude + "&Slatitude=" + Slatitude 
				+ "&Wlongitude=" + Wlongitude + "&centerLat=" + centerLat + "&centerLng=" + centerLng;
		String noResultsUrl = url + "&noresults=true";
		
		List<Walk> walkResults = OfyService.ofy().load().type(Walk.class).list();
		
		// filter to only walks today
	 	Calendar c = Calendar.getInstance();
	 	c.setTime(new Date());
	 	c.add(Calendar.HOUR, -6);
	 	Date today = c.getTime();
	 	log.warning("today = " + today.toString());
	 	c.set(Calendar.HOUR_OF_DAY, 23);
	 	c.set(Calendar.MINUTE, 59);
	 	Date midnight = c.getTime();
	 	log.warning("midnight = " + midnight.toString());
	 	List<Walk> walksToRemove = new ArrayList<Walk>();
 		for (Walk w : walkResults) {
 			log.warning("for walkId " + w.id + ":");
 			if (w.startTime.before(today) || w.startTime.after(midnight)) {
 				log.warning("removed this walk based on startTime: " + w.startTime.toString());
 				walksToRemove.add(w);
 			}
 		}
 		for (Walk w : walksToRemove) {
 			walkResults.remove(w);
 		}
		if (walkResults.isEmpty()) {
			resp.sendRedirect(noResultsUrl);
			return;
		}
		
		// filter to only walks within the bounds of the given zipcode
		walksToRemove = new ArrayList<Walk>();
		for (Walk w : walkResults) {
			log.warning("for walkId " + w.id + ":");
			if (w.latitude > Nlatitude || w.latitude < Slatitude) {
				log.warning("removed this walk based on latitude: " + w.latitude);
				walksToRemove.add(w);
			}
			else if (w.longitude < Wlongitude || w.longitude > Elongitude) {
				log.warning("removed this walk based on longitude: " + w.longitude);
				walksToRemove.add(w);
			}
		}
		for (Walk w : walksToRemove) {
			walkResults.remove(w);
		}
		if (walkResults.isEmpty()) {
			resp.sendRedirect(noResultsUrl);
			return;
		}		
		
	 	Collections.sort(walkResults);
        Type t = new TypeToken<ArrayList<Walk>>(){}.getType();
		Gson gson = new Gson();
		String json = gson.toJson(walkResults, t);
		req.setAttribute("walkResults", json);
		try {
			req.getRequestDispatcher(url).forward(req, resp);
		} catch (ServletException e) {
			log.warning("problem forwarding request");
			e.printStackTrace();
		}
	}
}
