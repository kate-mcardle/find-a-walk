package com.findawalk.server;
import com.findawalk.Dog;
import com.findawalk.DogOwner;
import com.findawalk.OfyService;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.images.ImagesService;
import com.google.appengine.api.images.ImagesServiceFactory;

@SuppressWarnings("serial")
public class CreateAccountServlet extends HttpServlet {
	private BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();

	public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		doPost(req, res);
	}
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		OfyService.ofy().clear();
		int numDogs = Integer.parseInt(req.getParameter("numDogs"));
		
		// Create Dog objects for each dog, save to Objectify, add id to dogIds list
		ArrayList<Long> dogIds = new ArrayList<Long>();
		for(int i = 0; i < numDogs; i++) {
			String name = req.getParameter("dogName" + i);
			String kind = req.getParameter("dogKind" + i);
			int age = Integer.parseInt(req.getParameter("dogAge" + i));
			String gender = req.getParameter("dogGender" + i);
			int weight = Integer.parseInt(req.getParameter("dogWeight" + i));
			Dog dog = new Dog(name, kind, age, gender, weight);
			OfyService.ofy().save().entity(dog).now();
			dogIds.add(dog.id);
		}
		
		Map<String, BlobKey> blobs = blobstoreService.getUploadedBlobs(req);
		BlobKey blobKey = blobs.get("profilePicture");
		ImagesService imagesService = ImagesServiceFactory.getImagesService();
		String bkUrl = imagesService.getServingUrl(blobKey);
		
		DogOwner owner = new DogOwner(req, dogIds, bkUrl);
		OfyService.ofy().save().entity(owner).now();
		
		HttpSession session = req.getSession();
		session.setAttribute("account", owner.id);
		resp.sendRedirect("/home.jsp");
	}
}
