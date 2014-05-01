<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.findawalk.OfyService" %>
<%@ page import="com.findawalk.DogOwner" %>

<%@ page import="com.google.appengine.api.blobstore.BlobstoreService" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
	String highlight = "";
	if (request.getParameter("highlight") != null) {
		highlight = request.getParameter("highlight");
	}
	
	BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
	UserService userService = UserServiceFactory.getUserService();

	Long userId = (Long)session.getAttribute("account");
	DogOwner owner = OfyService.ofy().load().type(DogOwner.class).id(userId).get();
	
%>
<div class="navbar navbar-default navbar-fixed-top" role="navigation">
	<div class="container">
		<div class="navbar-header">
			<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
          			<span class="icon-bar"></span>
          			<span class="icon-bar"></span>
          			<span class="icon-bar"></span>
        	</button>
			<a class="navbar-brand" href="/home.jsp">Find A Walk</a>
		</div>
		<div class="navbar-collapse collapse">
			<ul class="nav navbar-nav navbar-right">
				<% if (highlight.equals("search")) { %> <li class="active"> <% }
				else { %> <li> <% } %>						
				<a href="/search.jsp">Search Walks</a><li>
				
				<% if (highlight.equals("manage-walks")) { %> <li class="active"> <% }
				else { %> <li> <% } %>						
				<a href="/manageWalks">Manage Walks</a><li>
				
				<% if (highlight.equals("profile")) { %> <li class="active"> <% }
				else { %> <li> <% } %>						
				<a href="/profile.jsp?profileId=<%= owner.id%>">Profile</a></li>
				
				<li><a href="<%= userService.createLogoutURL("/logout")%>">Log Out</a></li>
				
				<li><img class="img-rounded" src="<%= owner.profilePicUrl %>" alt="profile picture" height="50dp"></li>
			</ul>
		</div>
	</div>
</div>