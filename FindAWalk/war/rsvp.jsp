<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.findawalk.DogOwner" %>
<%@ page import="com.findawalk.Dog" %>
<%@ page import="com.findawalk.Walk" %>
<%@ page import="com.findawalk.OfyService" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
  <head>
  	<link type="text/css" rel="stylesheet" href="/stylesheets/bootstrap.css" />
  	<title>RSVP | Find A Walk</title>
  </head>
  
  <body>
	<%
	if (session.getAttribute("email") == null) {
		response.sendRedirect("/login.jsp");
		return;
		
	} else if (session.getAttribute("account") == null) {
		response.sendRedirect("/create-account.jsp");
		return;
	}
	if (request.getParameter("status") == null || request.getParameter("walkId") == null) {
		response.sendRedirect("/home.jsp");
		return;
	}
	OfyService.ofy().clear();
	Long walkId = new Long(request.getParameter("walkId"));
	Walk walk = OfyService.ofy().load().type(Walk.class).id(walkId).get();
	DogOwner host = OfyService.ofy().load().type(DogOwner.class).id(walk.ownerId).get();
	String status = request.getParameter("status");
	String message = "";
	if (status.equals("sent")) {
		message = "Your request to join " + host.name + "'s walk has been sent. If you are accepted, you will be notified by email and the walk will appear on your Manage Walks page.";
	} else if (status.equals("owner")) {
		message = "You are the host of this walk, so you do not need to RSVP.";
	} else if (status.equals("alreadyAttending")) {
		message = "You are already attending this walk.";
	} else if (status.equals("alreadyRequested")) {
		message = "You have already requested to join this walk. If you are accepted, you will be notified by email and the walk will appear on your Manage Walks page.";
	} else {
		message = "There was an error processing your request. Please try again.";
	}
	%>
  	<jsp:include page="nav.jsp?highlight=profile"/>
  	<div class="container">
  		<p><%=message%></p>
  	</div>
  </body>
 </html>