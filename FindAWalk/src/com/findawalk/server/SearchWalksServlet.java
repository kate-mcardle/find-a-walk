package com.findawalk.server;

import com.findawalk.OfyService;
import com.findawalk.Walk;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.IOException;
import java.lang.reflect.Type;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.logging.Logger;

@SuppressWarnings("serial")
public class SearchWalksServlet extends HttpServlet {

	public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		doPost(req, res);
	}

	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		OfyService.ofy().clear();

		Logger log = Logger.getLogger("SearchWalksServlet");

		List<Walk> walkResults = OfyService.ofy().load().type(Walk.class).list();

		// get parameters as Strings:
		String url = "/search.jsp?";
		if (req.getParameter("date") != null && (req.getParameter("date").length() > 0)) {
			String dateS = req.getParameter("date");
			url += "date=" + dateS + "&";
		}
		if (req.getParameter("startTime") != null && (req.getParameter("startTime").length() > 0)) {
			String startTimeS = req.getParameter("startTime");
			url += "startTime=" + startTimeS + "&";
		}
		if (req.getParameter("endTime") != null && (req.getParameter("endTime").length() > 0)) {
			String endTimeS = req.getParameter("endTime");
			url += "endTime=" + endTimeS + "&";
		}
		if (req.getParameter("minLength") != null && (req.getParameter("minLength").length() > 0)) {
			String minLengthS = req.getParameter("minLength");
			url += "minLength=" + minLengthS + "&";
		}
		if (req.getParameter("maxLength") != null && (req.getParameter("maxLength").length() > 0)) {
			String maxLengthS = req.getParameter("maxLength");
			url += "maxLength=" + maxLengthS + "&";
		}
		if (req.getParameter("location") != null && (req.getParameter("location").length() > 0)) {
			String locationS = req.getParameter("location");
			url += "location=" + locationS + "&";
		}
		if (req.getParameter("maxNumDogs") != null && (req.getParameter("maxNumDogs").length() > 0)) {
			String maxNumDogsS = req.getParameter("maxNumDogs");
			url += "maxNumDogs=" + maxNumDogsS + "&";
		}
		String noResultsUrl = url + "noresults=true";

		if (req.getParameter("minLength") != null && (req.getParameter("minLength").length() > 0)) {
			int minLength = Integer.parseInt(req.getParameter("minLength"));
			List<Walk> walksToRemove = new ArrayList<Walk>();
			for (Walk w : walkResults) {
				if (w.length < minLength) {
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
		}

		if ((req.getParameter("maxLength") != null) && (req.getParameter("maxLength").length() > 0)) {
			int maxLength = Integer.parseInt(req.getParameter("maxLength"));
			List<Walk> walksToRemove = new ArrayList<Walk>();
			for (Walk w : walkResults) {
				if (w.length > maxLength) {
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
		}

		if ((req.getParameter("latitude") != null) && (req.getParameter("latitude").length() > 0)
				&& req.getParameter("longitude") != null && req.getParameter("longitude").length() > 0) {
			Double latitude = Double.parseDouble(req.getParameter("latitude"));
			Double longitude = Double.parseDouble(req.getParameter("longitude"));
			List<Walk> walksToRemove = new ArrayList<Walk>();
			for (Walk w : walkResults) {
				if (Math.abs((w.latitude - latitude)) > (3.0/60.0)) {
					walksToRemove.add(w);
				}
				else if (Math.abs((w.longitude - longitude)) > (3.0/60.0)) {
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
		}

		if ((req.getParameter("maxNumDogs") != null) && (req.getParameter("maxNumDogs").length() > 0)) {
			int maxNumDogs = Integer.parseInt(req.getParameter("maxNumDogs"));
			List<Walk> walksToRemove = new ArrayList<Walk>();
			for (Walk w : walkResults) {
				if (w.maxNumDogs > maxNumDogs) {
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
		}

		if ((req.getParameter("date") != null) && (req.getParameter("date").length() > 0)) {
			Calendar c = Calendar.getInstance();
			c.setTime(new Date());
			c.add(Calendar.HOUR, -6);
			Date today = c.getTime(); // first remove all walks before right now
			List<Walk> walksToRemove = new ArrayList<Walk>();
			for (Walk w : walkResults) {
				if (w.startTime.before(today)) {
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
			
			String dateString = req.getParameter("date"); //2013-01-01
			// 13%3A01
			String pattern = "A";
			Date startTime;
			String startString = "";
			if (req.getParameter("startTime") != null && (req.getParameter("startTime").length() > 0)) {
				startString = dateString + ", " + req.getParameter("startTime").replaceAll(pattern,  "");
			}
			else {
				startString = dateString + ", 00:00";
			}
			try {
				startTime = new SimpleDateFormat("yyyy-MM-dd, HH:mm", Locale.ENGLISH).parse(startString);	 		
				walksToRemove = new ArrayList<Walk>();
				for (Walk w : walkResults) {
					if (w.startTime.before(startTime)) {
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
			} catch (ParseException e) {
				e.printStackTrace();
			}
			String endString = "";
			if (req.getParameter("endTime") != null && (req.getParameter("endTime").length() > 0)) {
				endString = dateString + ", " + req.getParameter("endString").replaceAll(pattern,  "");
			}
			else {
				endString = dateString + ", 23:59";
			}
			Date endTime;
			try {
				endTime = new SimpleDateFormat("yyyy-MM-dd, HH:mm", Locale.ENGLISH).parse(endString);
				walksToRemove = new ArrayList<Walk>();
				for (Walk w : walkResults) {
					if (w.endTime.after(endTime)) {
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
			} catch (ParseException e) {
				e.printStackTrace();
			}
		}
		else { // no date given
			Calendar c = Calendar.getInstance();
			c.setTime(new Date());
			c.add(Calendar.HOUR, -6);
			Date today = c.getTime(); // first remove all walks before right now
			List<Walk> walksToRemove = new ArrayList<Walk>();
			for (Walk w : walkResults) {
				if (w.startTime.before(today)) {
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
			if (req.getParameter("startTime") != null && req.getParameter("startTime").length() > 0) {
				String startTime = req.getParameter("startTime");
				log.warning("startTime = " + startTime);
				int startHour = Integer.parseInt(startTime.substring(0, 2));
				int startMinutes = Integer.parseInt(startTime.substring(3));
				walksToRemove = new ArrayList<Walk>();
				for (Walk w : walkResults) {
					if (w.startTime.getHours() < startHour) {
						walksToRemove.add(w);
					} else if (w.startTime.getHours() == startHour) {
						if (w.startTime.getMinutes() < startMinutes) {
							walksToRemove.add(w);
						}
					}
				}
				for (Walk w : walksToRemove) {
					walkResults.remove(w);
				}
				if (walkResults.isEmpty()) {
					resp.sendRedirect(noResultsUrl);
					return;
				}
			}
			if (req.getParameter("endTime") != null && req.getParameter("endTime").length() > 0) {
				String endTime = req.getParameter("endTime");
				int endHour = Integer.parseInt(endTime.substring(0, 2));
				int endMinutes = Integer.parseInt(endTime.substring(3));
				walksToRemove = new ArrayList<Walk>();
				for (Walk w : walkResults) {
					if (w.endTime.getHours() > endHour) {
						walksToRemove.add(w);
					} else if (w.endTime.getHours() == endHour) {
						if (w.endTime.getMinutes() > endMinutes) {
							walksToRemove.add(w);
						}
					}
				}
				for (Walk w : walksToRemove) {
					walkResults.remove(w);
				}
				if (walkResults.isEmpty()) {
					resp.sendRedirect(noResultsUrl);
					return;
				}
			}
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
