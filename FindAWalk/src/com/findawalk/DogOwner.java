package com.findawalk;

import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;


@Entity
public class DogOwner {
	@Id
	public Long id;
	public String email;
	public String name;
	public int numDogs;
	public ArrayList<Long> dogIds;
	public String profilePicUrl;
	public String ownerBio;
	public String dogBio;
	public String dogLikes;
	public String dogDislikes;
	public String places;
	public ArrayList<Long> walkIdsHosting;
	public ArrayList<Long> walkIdsAttending;
	public ArrayList<String> picUrls;
	
	public DogOwner() {
	}
	
	public DogOwner(HttpServletRequest req, ArrayList<Long> dogIds, String profilePicUrl) {
		HttpSession session = req.getSession();
		email = (String)session.getAttribute("email");
		
		name = req.getParameter("ownerName");
		numDogs = Integer.parseInt(req.getParameter("numDogs"));
		this.dogIds = dogIds;
		this.profilePicUrl = profilePicUrl;
		
		if (req.getParameter("aboutOwner") != null) {
			ownerBio = req.getParameter("aboutOwner");
		}
		else { ownerBio = ""; }
		
		if (req.getParameter("aboutDogs") != null) {
			dogBio = req.getParameter("aboutDogs");
		}
		else { dogBio = ""; }
		
		if (req.getParameter("dogLikes") != null) {
			dogLikes = req.getParameter("dogLikes");
		}
		else { dogLikes = ""; }
		
		if (req.getParameter("dogDislikes") != null) {
			dogDislikes = req.getParameter("dogDislikes");
		}
		else { dogDislikes = ""; }
		
		if (req.getParameter("favePlaces") != null) {
			places = req.getParameter("favePlaces");
		}
		else { places = ""; }
		
		picUrls = new ArrayList<String>();
	}
	
	public void addWalkHosting(Long walkId) {
		if (walkIdsHosting == null) {
			walkIdsHosting = new ArrayList<Long>();
		}
		if (walkIdsAttending == null) {
			walkIdsAttending = new ArrayList<Long>();
		}
		walkIdsHosting.add(walkId);
		walkIdsAttending.add(walkId);
	}
	
	public void addWalkAttending(Long walkId) {
		if (walkIdsAttending == null) {
			walkIdsAttending = new ArrayList<Long>();
		}
		walkIdsAttending.add(walkId);
	}
	
	public void addPics(ArrayList<String> pics) {
		if (picUrls == null) {
			picUrls = new ArrayList<String>();
		}
		for (String pic : pics) {
			picUrls.add(pic);
		}
	}

}
