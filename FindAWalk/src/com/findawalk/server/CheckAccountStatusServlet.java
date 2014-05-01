package com.findawalk.server;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.findawalk.DogOwner;
import com.findawalk.OfyService;

@SuppressWarnings("serial")
public class CheckAccountStatusServlet extends HttpServlet {
	
	public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		doPost(req, res);
	}
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		OfyService.ofy().clear();
		HttpSession session = req.getSession();
		if (session.getAttribute("email") == null) {
			resp.sendRedirect("/login.jsp");
		} else {
			String email = (String)session.getAttribute("email");
			List<DogOwner> owners = OfyService.ofy().load().type(DogOwner.class).list();
			if (owners != null && owners.size() > 0) {
				for ( DogOwner owner : owners) {
					if (email.equals(owner.email)) {
						session.setAttribute("account", owner.id);
						if (session.getAttribute("redirect") != null) {
							String redirect = (String)session.getAttribute("redirect");
							session.removeAttribute("redirect");
							String url = "/" + redirect + ".jsp";
							if (redirect.equals("edit-walk")) {
								if (session.getAttribute("walkId") != null) {
									String walkId = (String)session.getAttribute("walkId");
									session.removeAttribute("walkId");
									url += "?walkId=" + walkId;
								}
							}
							else if (redirect.equals("profile")) {
								if (session.getAttribute("profileId") != null) {
									String profileId = (String)session.getAttribute("profileId");
									session.removeAttribute("profileId");
									url += "?profileId=" + profileId;
								}
							}
							else if (redirect.equals("respond")) {
								if (session.getAttribute("walkId") != null && session.getAttribute("requestorId") != null) {
									String walkId = (String)session.getAttribute("walkId");
									session.removeAttribute("walkId");
									String requestorId = (String)session.getAttribute("requestorId");
									session.removeAttribute("requestorId");
									url += "?walkId=" + walkId + "&requestorId=" + requestorId;
								}
							}
							resp.sendRedirect(url);
							return;
						}
						resp.sendRedirect("/home.jsp");
						return;
					}
				}
			}
			resp.sendRedirect("/create-account.jsp");
		}
	}
	
}
