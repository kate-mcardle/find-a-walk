package com.findawalk;

import java.util.ArrayList;
import java.util.Date;
import java.util.Locale;
import java.util.logging.Logger;
import java.text.SimpleDateFormat;
import java.text.ParseException;

import javax.servlet.http.HttpServletRequest;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;

@Entity
public class Walk implements Comparable<Walk> {
	@Id
	public Long id;
	public Date startTime;
	public Date endTime;
	public String location;
	public Double latitude;
	public Double longitude;
	public int length; // in minutes
	public int numOwnerDogs;
	public ArrayList<Long> dogIds; // ids of dogs attending walk
	public int maxNumDogs; // including owner's dogs
	public int numDogsRSVPd; // including owner's dogs
	public String comments;
	public Long ownerId;
	public ArrayList<Long> attendeeIds; // ids of users
	public ArrayList<Long> requestorIds; // ids of those who have requested to join walk but not been responded to yet
	
	public Walk() {
	}
	
	public Walk(HttpServletRequest req, DogOwner host) {		
		Logger log = Logger.getLogger("Walk Class");
		String dateString = req.getParameter("date"); //2013-01-01
		// 13%3A01
		String pattern = "A";
		String startString = dateString + ", " + req.getParameter("startTime").replaceAll(pattern,  "");
		String endString = dateString + ", " + req.getParameter("endTime").replaceAll(pattern,  "");
		try {
			startTime = new SimpleDateFormat("yyyy-MM-dd, HH:mm", Locale.ENGLISH).parse(startString);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		try {
			endTime = new SimpleDateFormat("yyyy-MM-dd, HH:mm", Locale.ENGLISH).parse(endString);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		if (req.getParameter("google_location") != null && req.getParameter("google_location").length() > 0) {
			location = req.getParameter("google_location");
			location = location.substring(0, location.length()-5);
			log.warning("google location found: " + location);
		}
		else {
			location = req.getParameter("location");
		}
		latitude = Double.parseDouble(req.getParameter("latitude"));
		log.warning("latitude = " + latitude);
		longitude = Double.parseDouble(req.getParameter("longitude"));
		log.warning("longitude = " + longitude);
		
		length = Integer.parseInt(req.getParameter("length"));
		
		ownerId = host.id;
		dogIds = new ArrayList<Long>();
		for (int i = 0; i < host.numDogs; i++) {
			String dogNum = "dog" + i;
			if (req.getParameter(dogNum) != null) {
				Long id = new Long(req.getParameter(dogNum));
				dogIds.add(id);
			}
		}
		
		numOwnerDogs = dogIds.size();
		maxNumDogs = numOwnerDogs + Integer.parseInt(req.getParameter("maxNumDogs"));
		numDogsRSVPd = numOwnerDogs;
		if (req.getParameter("comments") != null) {
			comments = req.getParameter("comments");
		}
		else { comments = ""; }
	}

	public void addAttendee(Long attendeeId, ArrayList<Long> dogIds) {
		if (attendeeIds == null) {
			attendeeIds = new ArrayList<Long>();
		}
		attendeeIds.add(attendeeId);
		for (Long dogId : dogIds) {
			this.dogIds.add(dogId);
		}
	}

	public boolean equals(Walk other) {
		if (id.equals(other.id)){
			return true;
		}
		return false;
	}
	
	@Override
	public int compareTo(Walk other) { // earliest first
		if (startTime.after(other.startTime)) {
			return 1;
		} else if (startTime.before(other.startTime)) {
			return -1;
		}
		return 0;
	}
}
