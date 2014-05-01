package com.findawalk.server;
import com.findawalk.Dog;
import com.findawalk.DogOwner;
import com.findawalk.OfyService;
import com.findawalk.Walk;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@SuppressWarnings("serial")
public class EditProfileServlet extends HttpServlet {

	public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		doPost(req, res);
	}
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		OfyService.ofy().clear();
		HttpSession httpSession = req.getSession();
		Long userId = (Long)httpSession.getAttribute("account");
		DogOwner thisUser = OfyService.ofy().load().type(DogOwner.class).id(userId).get();
		thisUser.name = req.getParameter("ownerName");

		for (int i = 0; i < thisUser.numDogs; i++) {
			Long dogId = thisUser.dogIds.get(i);
			String removeDog = "eRemoveDog" + i;
			if (req.getParameter(removeDog) != null) {
				OfyService.ofy().delete().type(Dog.class).id(dogId).now();
				thisUser.dogIds.remove(dogId);
				thisUser.numDogs--;
				if (thisUser.walkIdsAttending != null) {
					for (Long walkId : thisUser.walkIdsAttending) {
						Walk walk = OfyService.ofy().load().type(Walk.class).id(walkId).get();
						boolean removedFromWalk = walk.dogIds.remove(dogId);
						if (removedFromWalk) {
							if (thisUser.walkIdsHosting != null && thisUser.walkIdsHosting.contains(walkId)) {
								walk.numOwnerDogs--;
								walk.maxNumDogs--;
							}
							walk.numDogsRSVPd--;
						}
						OfyService.ofy().save().entity(walk).now();
					}
				}				
			} else {
				Dog dog = OfyService.ofy().load().type(Dog.class).id(dogId).get();
				dog.name = req.getParameter("eDogName" + i);
				dog.kind = req.getParameter("eDogKind" + i);
				dog.age = Integer.parseInt(req.getParameter("eDogAge" + i));
				dog.gender = req.getParameter("eDogGender" + i);
				dog.weight = Integer.parseInt(req.getParameter("eDogWeight" + i));
				OfyService.ofy().save().entity(dog).now();
			}
		}
		
		int numNewDogs = Integer.parseInt(req.getParameter("numNewDogs"));
		
		for(int i = 0; i < numNewDogs; i++) {
			String name = req.getParameter("dogName" + i);
			String kind = req.getParameter("dogKind" + i);
			int age = Integer.parseInt(req.getParameter("dogAge" + i));
			String gender = req.getParameter("dogGender" + i);
			int weight = Integer.parseInt(req.getParameter("dogWeight" + i));
			Dog dog = new Dog(name, kind, age, gender, weight);
			OfyService.ofy().save().entity(dog).now();
			thisUser.dogIds.add(dog.id);
		}
		thisUser.numDogs += numNewDogs;
		
		if (req.getParameter("aboutOwner") != null) {
			thisUser.ownerBio = req.getParameter("aboutOwner");
		}
		else { thisUser.ownerBio = ""; }
		
		if (req.getParameter("aboutDogs") != null) {
			thisUser.dogBio = req.getParameter("aboutDogs");
		}
		else { thisUser.dogBio = ""; }
		
		if (req.getParameter("dogLikes") != null) {
			thisUser.dogLikes = req.getParameter("dogLikes");
		}
		else { thisUser.dogLikes = ""; }
		
		if (req.getParameter("dogDislikes") != null) {
			thisUser.dogDislikes = req.getParameter("dogDislikes");
		}
		else { thisUser.dogDislikes = ""; }
		
		if (req.getParameter("favePlaces") != null) {
			thisUser.places = req.getParameter("favePlaces");
		}
		else { thisUser.places = ""; }
				
		OfyService.ofy().save().entity(thisUser).now();
//		for (Long dogId : dogsToDelete) {
//			OfyService.ofy().delete().type(Dog.class).id(dogId).now();
//		}
		resp.sendRedirect("/profile.jsp?profileId=" + userId);
	}
}
