<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.findawalk.DogOwner" %>
<%@ page import="com.findawalk.Dog" %>
<%@ page import="com.findawalk.OfyService" %>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
  <head>
  	<link type="text/css" rel="stylesheet" href="/stylesheets/bootstrap.css" />
  	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
  	<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js"></script>
  	<script src="http://ajax.aspnetcdn.com/ajax/jquery.validate/1.11.1/jquery.validate.min.js"></script>
  	<title>View Profile | Find A Walk</title>
  </head>
  
  <body>
	<%
	if (session.getAttribute("email") == null) {
		if (request.getParameter("profileId") == null) {
			response.sendRedirect("/login.jsp");
		}
		else {
			// parameters: profileId
			String profileId = request.getParameter("profileId");
			response.sendRedirect("/login.jsp?redirect=profile&profileId=" + profileId);
		}
		return;
		
	} else if (session.getAttribute("account") == null) {
		response.sendRedirect("/create-account.jsp");
		return;
	}
	if (request.getParameter("profileId") == null) {
		response.sendRedirect("/home.jsp");
		return;
	}
	OfyService.ofy().clear();
	Long profileId = new Long(request.getParameter("profileId"));
	DogOwner ownerProfile = OfyService.ofy().load().type(DogOwner.class).id(profileId).get();
	if (ownerProfile == null) {
		response.sendRedirect("/home.jsp");
		return;
	}
	Long userId = (Long)session.getAttribute("account");
	String whoseDogs;
	String name;
	String capName;
	%>
  	<jsp:include page="nav.jsp?highlight=profile"/>
  	<div class="container">
  		<%
  		if (profileId.equals(userId)) {
  			whoseDogs = "your";
  			name = "you";
  			capName = "You have";
  			%>
  			<h1>Your Profile:</h1>
  			<p><a href="/profile-edit.jsp?profileId=<%=userId%>">Edit your profile &gt&gt</a>
  			<%
  		} else {
  			whoseDogs = ownerProfile.name + "'s";
  			name = ownerProfile.name;
  			capName = ownerProfile.name + " has";
	  		%>
  			<h1><%= ownerProfile.name %>'s Profile:</h1>
  			<%
  		} 
  		%>
  		<div class="row">
  			<div class="col-md-12">
		  		<div class="pull-right">
					<img class="img-rounded" src="<%= ownerProfile.profilePicUrl %>" alt="profile picture" height="300dp">
					<%
					if (profileId.equals(userId)) {
						%>
						<p><a href="#" onclick="openNew()">Change your profile picture &gt&gt</a>
						<%
					}
					%>
				</div>
				<%
				if (ownerProfile.numDogs == 1) {
					%>
					<h3><%= capName %>&nbsp;1 dog:</h3>
					<%
				} else {
					%>
					<h3><%= capName %>&nbsp;<%= ownerProfile.numDogs %>&nbsp;dogs:</h3>
					<%
				}
				for (Long dogId : ownerProfile.dogIds) {
					Dog dog = OfyService.ofy().load().type(Dog.class).id(dogId).get();
					%>
					<p><%=dog.name %> is a <%=dog.age %>-year-old <%=dog.gender%> <%=dog.kind %> who weighs about <%=dog.weight %> pounds.
					<%
				}
				if (ownerProfile.ownerBio.length() > 0) {
					%>
					<h3>About <%=name%>:</h3>
					<p><%=ownerProfile.ownerBio %></p>
					<%
				}
				if (ownerProfile.dogBio.length() > 0) {
					if (ownerProfile.numDogs == 1) {
						%>
						<h3>About <%=whoseDogs%> dog:</h3>
						<p><%=ownerProfile.dogBio %></p>
						<%
					} else {
						%>
						<h3>About <%=whoseDogs%> dogs:</h3>
						<p><%=ownerProfile.dogBio %></p>
						<%	
					}
				}
				if (ownerProfile.dogLikes.length() > 0) {
					if (ownerProfile.numDogs == 1) {
						%>
						<p>Kinds of dogs <%=whoseDogs%> dog loves: <%=ownerProfile.dogLikes %></p>
						<%
					} else {
						%>
						<p>Kinds of dogs <%=whoseDogs%> dogs love: <%=ownerProfile.dogLikes %></p>
						<%	
					}
				}
				if (ownerProfile.dogDislikes.length() > 0) {
					if (ownerProfile.numDogs == 1) {
						%>
						<p>Kinds of dogs <%=whoseDogs%> dog doesn't love: <%=ownerProfile.dogDislikes %></p>
						<%
					} else {
						%>
						<p>Kinds of dogs <%=whoseDogs%> dogs don't love: <%=ownerProfile.dogDislikes %></p>
						<%	
					}
				}
				if (ownerProfile.places.length() > 0) {
					%>
					<p>Favorite places to walk: <%=ownerProfile.places %></p>
					<%
				}
			%>
			</div>
		</div>
  	</div>
  	<script>
		function openNew() {
			window.open("/change-pic.jsp",null, "height=200,width=300,status=yes,toolbar=no,menubar=no,location=no");
		}
	</script>
  </body>
 </html>