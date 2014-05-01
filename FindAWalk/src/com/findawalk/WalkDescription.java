package com.findawalk;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class WalkDescription {
	
	public String description;
	public Long walkId;
	public Long hostId;
	public String hostName;
	public int nAttendees;
	public Double lat;
	public Double lng;
	
	public WalkDescription() {
		
	}
	
	public WalkDescription(Walk w, Long userId) {
		walkId = w.id;
		hostId = w.ownerId;
		if (hostId.equals(userId)) {
			DogOwner thisUser = OfyService.ofy().load().type(DogOwner.class).id(userId).get();
			hostName = thisUser.name;
		}
		else {
			DogOwner host = OfyService.ofy().load().type(DogOwner.class).id(hostId).get();
			hostName = host.name;
		}
		
		if (w.attendeeIds != null) {
			nAttendees = w.attendeeIds.size();
		}
		else { nAttendees = 0; }
		
	 	Calendar c = Calendar.getInstance();
	 	c.setTime(new Date());
	 	c.add(Calendar.HOUR, -6);
	 	Date today = c.getTime();
	 	c.setTime(new Date());
	 	c.add(Calendar.HOUR, -6);
	 	c.add(Calendar.DATE, 1);
	 	Date tomorrow = c.getTime();
	 	c.setTime(new Date());
	 	c.add(Calendar.HOUR, -6);
	 	c.add(Calendar.DATE, -1);
	 	Date yesterday = c.getTime();
	 	SimpleDateFormat fDate = new SimpleDateFormat("MMMM dd");
	 	
		String day = "";
		if ((today.getYear() == w.startTime.getYear()) && (today.getMonth() == w.startTime.getMonth()) && (today.getDate() == w.startTime.getDate())) {
			if (w.startTime.getHours() >= 17) {
				day = "Tonight";
			}
			else if (w.startTime.getHours() < 12) {
				day = "This morning";
			}
			else {
				day = "Today";
			}
		}
		else if ((tomorrow.getYear() == w.startTime.getYear()) && (tomorrow.getMonth() == w.startTime.getMonth()) && (tomorrow.getDate() == w.startTime.getDate())) {
			day = "Tomorrow";
		}
		else if ((yesterday.getYear() == w.startTime.getYear()) && (yesterday.getMonth() == w.startTime.getMonth()) && (yesterday.getDate() == w.startTime.getDate())) {
			day = "Yesterday";
		}
		else {
			day = fDate.format(w.startTime);
		}
		
		String location = w.location;
		description = day + " at " + location;	
		
	}
}
