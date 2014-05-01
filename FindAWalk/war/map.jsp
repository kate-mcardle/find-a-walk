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
<%@page import="org.json.simple.JSONArray"%>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
  <head>
  	<link type="text/css" rel="stylesheet" href="/stylesheets/bootstrap.css" />
  	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
  	<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js"></script>
  	<script src="http://ajax.aspnetcdn.com/ajax/jquery.validate/1.11.1/jquery.validate.min.js"></script>
  	<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?v=3.exp&key=AIzaSyAw8zM-LssLj2C1NqJug4qYVicm9dPoh9Q&sensor=false"></script>
  	<style type="text/css">
  		#map-canvas { height: 50% }
  		#map-canvas { width: 100% }
  	</style>
  	<title>Map Results | Find A Walk</title>
   	<%
	if (session.getAttribute("email") == null) {
		response.sendRedirect("/login.jsp");
		return;
		
	} else if (session.getAttribute("account") == null) {
		response.sendRedirect("/create-account.jsp");
		return;
	}
	if (request.getParameter("zipcode") == null) {
		response.sendRedirect("/home.jsp");
		return;
	}
	String zip = request.getParameter("zipcode");
	if (zip.equals("none")) {
		response.sendRedirect("/home.jsp");
		return;
	}
	Long userId = (Long)session.getAttribute("account");
	OfyService.ofy().clear();
   	Double centerLat = Double.parseDouble(request.getParameter("centerLat"));
	Double centerLng = Double.parseDouble(request.getParameter("centerLng"));
	ArrayList<Walk> searchResults = new ArrayList<Walk>();
	if (request.getAttribute("walkResults") != null){
	    Gson gson = new Gson();
	    Type t = new TypeToken<ArrayList<Walk>>(){}.getType();
	    searchResults = gson.fromJson((String)request.getAttribute("walkResults"), t);
	}
	
	%>
	<script type="text/javascript">
	var map;
	var mapOptions;
	var markers = new Array();
    function initialize() {
       	mapOptions = {
          center: new google.maps.LatLng(<%=centerLat%>, <%=centerLng%>),
          zoom: 13
        };
        map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
        var contentString = 'See highlighted row in results list for details';
        var infowindow = new google.maps.InfoWindow({
        	content: contentString
        });

        <%
        for (int i = 0; i < searchResults.size(); i++) {
        %>
        	markers[<%=i%>] = new google.maps.Marker({ 
            	position: new google.maps.LatLng(<%=searchResults.get(i).latitude%>, <%=searchResults.get(i).longitude%>),
            	map: map
            });
        	<%
        	if (searchResults.get(i).maxNumDogs > searchResults.get(i).numDogsRSVPd) {
        		if (searchResults.get(i).numDogsRSVPd == searchResults.get(i).numOwnerDogs) {
        			%>
        			markers[<%=i%>].setIcon('http://maps.google.com/mapfiles/ms/icons/green-dot.png'); 
        			<%
        		} else {
        			%>
        			markers[<%=i%>].setIcon('http://maps.google.com/mapfiles/ms/icons/yellow-dot.png'); 
        			<%
        		}
        	} else {
    			%>
    			markers[<%=i%>].setIcon('http://maps.google.com/mapfiles/ms/icons/red-dot.png'); 
    			<%
        	}
        	%>
         	google.maps.event.addListener(markers[<%=i%>], 'click', function() {
          		$("#walkNum" + <%=i%>).find('td').effect("highlight", {}, 4000);
          		infowindow.open(map,markers[<%=i%>]);
         	});
        <%
        }
        %>
    }
    </script>
  </head>

  <body onload="initialize()">
  	<jsp:include page="nav.jsp"/>
  	<div class="container">
		<%
		if (request.getParameter("noresults") != null) {
			%>
			<h1>Results for Walks today in zip code <%=zip%>:</h1>
			<p>Sorry, no walks were found. You can return to the <a href="/home.jsp">home page</a> to post a new walk.</p>
			<%
		} else if (request.getAttribute("walkResults") != null){
			SimpleDateFormat fDate = new SimpleDateFormat("MMMM dd");
			SimpleDateFormat fTime = new SimpleDateFormat("hh:mm a");
	   		%>
	   		<h2>Map of results for today's walks in zip code <%=zip%></h2>
	   		<div class="row">
	   			<div class="col-sm-6">
	   				<div id="map-canvas"></div>
	   			</div>
	   			<div class="col-sm-6">
	   				<h4>Key:</h4>
	   				<p><img src="http://maps.google.com/mapfiles/ms/icons/green-dot.png"> = Available, no RSVPs (besides the owner)</p>
	   				<p><img src="http://maps.google.com/mapfiles/ms/icons/yellow-dot.png"> = Available, with at least one RSVP already</p>
	   				<p><img src="http://maps.google.com/mapfiles/ms/icons/red-dot.png"> = Full</p>
	   			</div>
	   		</div>
	   		
	   		<h2>List of Results:</h2>
 			<table class="table table-hover">
				<tbody>
					<tr><th>Date</th><th>Earliest Start Time</th><th>Latest End Time</th><th>Length (minutes)</th><th>Location</th><th>Max Number of Dogs</th>
					<th>Number of Dogs Attending</th><th>Types of Dogs Attending</th><th>Host</th><th>Other Attendees</th><th>RSVP</th>
 				<%
 				int j = 0;
 				for (Walk w : searchResults) {
 					%>
 					<tr id="walkNum<%=j%>">
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
 	 						%><td><a href="/profile.jsp?profileId=<%=w.ownerId%>"><%= host.name %></a></td><%
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
 					j++;
 				}
 				%>
				</tbody>
			</table>
			<%
		}
		%>
  		
  	</div>
  </body>
 </html>