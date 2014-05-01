<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
	UserService userService = UserServiceFactory.getUserService();
	User user = userService.getCurrentUser();
	session.removeAttribute("accessId");
	if (user != null) {
		session.setAttribute("email", user.getEmail());
		response.sendRedirect("/checkAccountStatus");
	} else {
%>
<html>
  <head>
  	<link type="text/css" rel="stylesheet" href="/stylesheets/bootstrap.min.css" />
  	<title>Welcome to Find A Walk</title>
  </head>
  
  <body>
  	<div class="container">
  		<div class="starter-template">
  			<h1>Welcome to Find a Walk!</h1>
			<h3>Find a Walk is a service that allows dog owners to connect with each other and make dog walking a social event - for both the owners and the dogs!</h3>			
			<%
			if (request.getParameter("redirect") != null) {
				String redirect = request.getParameter("redirect");
				session.setAttribute("redirect", redirect);
				if (redirect.equals("edit-walk")) {
					String walkId = request.getParameter("walkId");
					session.setAttribute("walkId", walkId);
				}
				else if (redirect.equals("profile")) {
					String profileId = request.getParameter("profileId");
					session.setAttribute("profileId", profileId);
				}
				else if (redirect.equals("respond")) {
					String walkId = request.getParameter("walkId");
					String requestorId = request.getParameter("requestorId");
					session.setAttribute("walkId", walkId);
					session.setAttribute("requestorId", requestorId);
				}
			}
			%>
			<p class="lead"><br>Please <a href="<%= userService.createLoginURL("/checkAccountStatus") %>">sign in with your Google account</a> to proceed.</p>		
  		</div>
	</div>
  </body>
</html>
<%
}
%> 