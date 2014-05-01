<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.findawalk.Walk" %>
<%@ page import="com.findawalk.DogOwner" %>
<%@ page import="com.findawalk.Dog" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="com.google.gson.reflect.TypeToken" %>
<%@ page import="java.lang.reflect.Type" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.findawalk.OfyService" %>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
  <head>
  	<link type="text/css" rel="stylesheet" href="/stylesheets/bootstrap.css" />
  	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
  	<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js"></script>
  	<script src="http://ajax.aspnetcdn.com/ajax/jquery.validate/1.11.1/jquery.validate.min.js"></script>
  	<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?v=3.exp&key=AIzaSyAw8zM-LssLj2C1NqJug4qYVicm9dPoh9Q&sensor=false"></script>
  	<title>Search | Find A Walk</title>
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
	Long userId = (Long)session.getAttribute("account");
	OfyService.ofy().clear();
	%>
  	<jsp:include page="nav.jsp?highlight=search"/>
  	<div class="container">
  		<h1>Search Walks</h1>
  		<h3>Enter as much or as little information as you would like:</h3>
 		<form class="form" role="form" name="searchWalks" method="post" action="/searchWalks">
			<div class="row">
				<div class="col-md-3">
					<div class="form-group">
						<label for="date" class="control-label">Date of walk:</label>
						<input type="date" class="form-control" id="date" name="date" value="<%=request.getParameter("date")%>"/>
						<span class="help-block">Only future walks will be returned</span>
					</div>
					<div class="form-group">
						<label for="startTime" class="control-label">Earliest start time:</label>
						<input type="time" class="form-control" id="startTime" name="startTime" value="<%=request.getParameter("startTime")%>"></input>
						<span class="help-block">Format: HH:mm AM/PM</span>
					</div>
					<div class="form-group">
						<label for="endTime" class="control-label">Latest end time:</label>
						<input type="time" class="form-control" id="endTime" name="endTime" value="<%=request.getParameter("endTime")%>"></input>
						<span class="help-block">Format: HH:mm AM/PM</span>
					</div>
				</div>
				<div class="col-md-3">
					<div class="form-group">
						<label for="minLength" class="control-label">Minimum walk length:</label>
						<input type="number" class="form-control" id="minLength" name="minLength" min="1" value="<%=request.getParameter("minLength")%>"></input>
						<span class="help-block">In minutes</span>
					</div>
					<div class="form-group">
						<label for="maxLength" class="control-label">Maximum walk length:</label>
						<input type="number" class="form-control" id="maxLength" name="maxLength" min="1" value="<%=request.getParameter("maxLength")%>"></input>
						<span class="help-block">In minutes</span>
					</div>
					<div class="form-group">
						<label for="location" class="control-label">Approximate location:</label>
						<%
						if (request.getParameter("location") == null) {
							%>
							<input type="text" class="form-control" id="location" name="location" onchange="getLatLng();"></input>
							<%
						} else {
							%>
							<input type="text" class="form-control" id="location" name="location" onchange="getLatLng();" value="<%=request.getParameter("location")%>"></input>
						<% } %>
						<span class="help-block">Address or landmark</span>
					</div>
				</div>
				<div class="col-md-3">
					<div class="form-group">
						<label for="maxNumDogs" class="control-label">Maximum number of dogs permitted:</label>
						<input type="number" class="form-control" id="maxNumDogs" name="maxNumDogs" min="1" value="<%=request.getParameter("maxNumDogs")%>"></input>
					</div>
					<input type="hidden" name="latitude" id="latitude" value="">
					<input type="hidden" name="longitude" id="longitude" value="">
					<button type="submit" class="btn btn-primary" id="searchBtn">Search Walks</button>	
				</div>		
			</div>
		</form>
		<%
		if (request.getParameter("noresults") != null) {
			%>
			<h1>Search Results:</h1>
			<p>Sorry, no results were found. Please try a new search, or return to the <a href="/home.jsp">home page</a> to post a new walk.</p>
			<%
		} else if (request.getAttribute("walkResults") != null){
		    Gson gson = new Gson();
		    Type t = new TypeToken<ArrayList<Walk>>(){}.getType();
		    ArrayList<Walk> searchResults = gson.fromJson((String)request.getAttribute("walkResults"), t);
			SimpleDateFormat fDate = new SimpleDateFormat("MMMM dd");
			SimpleDateFormat fTime = new SimpleDateFormat("hh:mm a");
	   		%>
	   		<h1>Search Results:</h1>
	   		<%
	   		if (request.getParameter("location") != null && request.getParameter("location").length() > 0) {
	   			%>
	   			<p>Displaying results within 3 miles of <%=request.getParameter("location")%></p>
	   			<%
	   		}
	   		%>
 			<table class="table table-hover">
				<tbody>
					<tr><th>Date</th><th>Earliest Start Time</th><th>Latest End Time</th><th>Length (minutes)</th><th>Location</th><th>Max Number of Dogs</th>
					<th>Number of Dogs RSVP'd</th><th>Types of Dogs Attending</th><th>Host</th><th>Other Attendees</th><th>RSVP</th>
 				<%
 				for (Walk w : searchResults) {
 					%>
 					<tr>
 						<td><%= fDate.format(w.startTime) %></td>
 						<td><%= fTime.format(w.startTime) %></td>
 						<td><%= fTime.format(w.endTime) %></td>
 						<td><%= w.length %></td>
 						<td><%= w.location %></td>
 						<td><%= w.maxNumDogs %>
 						<td><%= w.numDogsRSVPd %></td>
 						<%
 						String types = "";
 						if (w.dogIds != null) {
 	 						for (Long dogId : w.dogIds) {
 	 							if (types.length() > 0) {
 	 								types+= ", ";
 	 							}
 	 							Dog dog = OfyService.ofy().load().type(Dog.class).id(dogId).get();
 	 							types += dog.kind;
 	 						}
 						}
 						%><td><%= types %></td><%
 						DogOwner host = OfyService.ofy().load().type(DogOwner.class).id(w.ownerId).get();
 						if (w.ownerId.equals(userId)) {
 							%><td>You</td><%
 						} else {
 	 						%><td><a href="/profile.jsp?profileId=<%=w.ownerId%>"><%= host.name %></td><%
 						}
 						%><td><%
 						if (w.attendeeIds != null) {
 							List<String> people = new ArrayList<String>();
 	 						int i = 0;
 	 						for (Long attendeeId : w.attendeeIds) {
 	 							if (i > 0) {
 	 								if(attendeeId.equals(userId)) {
 	 									continue;
 	 								}
 	 								%>
 	 								<br>
 	 								<%
 	 							}
 	 							i++;
 	 							DogOwner attendee = OfyService.ofy().load().type(DogOwner.class).id(attendeeId).get();
 	 							%>
 	 							<a href="/profile.jsp?profileId=<%=attendeeId%>"><%=attendee.name%></a>
 	 							<%
 	 						}
 						} else {
 							%>None yet<%
 						}
 						%></td><%
 						if (w.ownerId.equals(userId) || (w.attendeeIds != null && w.attendeeIds.contains(userId))) {
 							%><td>--</td><%
 						} else if (w.requestorIds != null && w.requestorIds.contains(userId)) {
 							%><td>Request already sent</td><%
 						} else {
 							%><td><a href="/rsvp?walkId=<%=w.id%>" onclick="return confirm('Are you sure?')">RSVP</a></td><%
 						}
 					%></tr>
 					<%
 				}
 				%>
				</tbody>
			</table>
			<%
		}
		%>
		<script>
		var geocoder;
		function initialize() {
			geocoder = new google.maps.Geocoder();
		}
		
		function getLatLng() {
			var address = $("#location").val();
			if(address.length == 0) {
				$('#searchBtn').prop('disabled',false);
				return;
			}
			$('#searchBtn').prop('disabled',true);
			$('#latitude').val("");
			$('#longitude').val("");			
			geocoder.geocode( { 'address' : address }, function(results, status) {
				if (status == google.maps.GeocoderStatus.OK) {
					if (results.length > 1) {
						alert("The location you entered is too vague. Please refine it and and try again.");
					}
					else {
						var latlng = results[0].geometry.location;
						$('#latitude').val(latlng.lat());
						$('#longitude').val(latlng.lng());
						$('#searchBtn').prop('disabled',false);
					}
				}
				else {
					alert("There was an error processing the location of your walk. Please check your location and try again.");
				}
			});
		}
		
		google.maps.event.addDomListener(window, 'load', initialize);
		</script>	
  	</div>
  </body>
 </html>