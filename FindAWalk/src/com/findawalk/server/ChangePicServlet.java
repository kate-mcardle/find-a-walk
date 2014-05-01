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
public class ChangePicServlet extends HttpServlet {
	private BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();

	public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		doPost(req, res);
	}
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		OfyService.ofy().clear();
		HttpSession session = req.getSession();
		Long userId = (Long)session.getAttribute("account");
		
		Map<String, BlobKey> blobs = blobstoreService.getUploadedBlobs(req);
		BlobKey blobKey = blobs.get("profilePicture");
		ImagesService imagesService = ImagesServiceFactory.getImagesService();
		String bkUrl = imagesService.getServingUrl(blobKey);
		
		DogOwner thisUser = OfyService.ofy().load().type(DogOwner.class).id(userId).get();
		thisUser.profilePicUrl = bkUrl;
		OfyService.ofy().save().entity(thisUser).now();

		resp.sendRedirect("/change-pic.jsp?done=done");
	}
}
