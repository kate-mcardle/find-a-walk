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
  	<title>Respond to RSVP | Find A Walk</title>
  </head>
  
  <body>
	<%
	if (session.getAttribute("email") == null) {
		if (request.getParameter("requestorId") == null || request.getParameter("walkId") == null) {
			response.sendRedirect("/login.jsp");
		}
		else {
			// parameters: walkId, requestorId
			String walkId = request.getParameter("walkId");
			String requestorId = request.getParameter("requestorId");
			response.sendRedirect("/login.jsp?redirect=respond&walkId=" + walkId + "&requestorId=" + requestorId);
		}
		return;
		
	} else if (session.getAttribute("account") == null) {
		response.sendRedirect("/create-account.jsp");
		return;
	}
	if (request.getParameter("walkId") == null || request.getParameter("requestorId") == null) {
		response.sendRedirect("/home.jsp");
		return;
	}
	OfyService.ofy().clear();
	Long walkId = new Long(request.getParameter("walkId"));
	Walk walk = OfyService.ofy().load().type(Walk.class).id(walkId).get();
	Long userId = (Long)session.getAttribute("account");
	if (!walk.ownerId.equals(userId)) {
		response.sendRedirect("/home.jsp");
		return;
	}
	Long requestorId = new Long(request.getParameter("requestorId"));
	DogOwner requestor = OfyService.ofy().load().type(DogOwner.class).id(requestorId).get();
	if (walk.requestorIds == null) {
		response.sendRedirect("/home.jsp");
		return;
	}
	if (!walk.requestorIds.contains(requestorId)) {
		response.sendRedirect("/home.jsp");
		return;
	}
	SimpleDateFormat fDate = new SimpleDateFormat("MMMM dd");
	%>
  	<jsp:include page="nav.jsp?highlight=profile"/>
  	<div class="container">
  		<h1>Join Walk Request</h1>
  		<p><a href="/profile.jsp?profileId=<%=requestorId%>"><%= requestor.name %></a> would like to join your walk on <%= fDate.format(walk.startTime) %>. (<a href="/edit-walk.jsp?walkId=<%=walkId%>">View or edit this walk.</a>)</p>
  		<form class="form" role="form" name="acceptRSVP" method="post" action="/acceptRSVP">
		<input type="hidden" name="walkId" value="<%= walkId %>">
		<input type="hidden" name="requestorId" value="<%= requestorId %>">
		<button type="submit" class="btn btn-primary">Accept RSVP Request</button>	
	</form>  
  	
  	</div>
  </body>
 </html>