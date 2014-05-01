package com.findawalk.server;
import com.findawalk.Dog;
import com.findawalk.DogOwner;
import com.findawalk.OfyService;
import com.findawalk.Walk;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@SuppressWarnings("serial")
public class CreateWalkServlet extends HttpServlet {

	public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		doPost(req, res);
	}
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		OfyService.ofy().clear();
		HttpSession session = req.getSession();
		Long hostId = (Long)session.getAttribute("account");
		DogOwner host = OfyService.ofy().load().type(DogOwner.class).id(hostId).get();
		
		Walk walk = new Walk(req, host);
		OfyService.ofy().save().entity(walk).now();

		host.addWalkHosting(walk.id);
		OfyService.ofy().save().entity(host).now();

		resp.sendRedirect("/manageWalks");
	}
}
