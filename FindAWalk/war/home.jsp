<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.findawalk.DogOwner" %>
<%@ page import="com.findawalk.Dog" %>
<%@ page import="com.findawalk.Walk" %>
<%@ page import="com.findawalk.OfyService" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.logging.Logger" %>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
  <head>
  	<link type="text/css" rel="stylesheet" href="/stylesheets/bootstrap.css" />
  	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
  	<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js"></script>
  	<script src="http://ajax.aspnetcdn.com/ajax/jquery.validate/1.11.1/jquery.validate.min.js"></script>
  	<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?v=3.exp&key=AIzaSyAw8zM-LssLj2C1NqJug4qYVicm9dPoh9Q&sensor=false"></script>
  	<title>Home | Find A Walk</title>
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
	OfyService.ofy().clear();
	Long userId = (Long)session.getAttribute("account");
	DogOwner thisUser = OfyService.ofy().load().type(DogOwner.class).id(userId).get();
 	List<Walk> walks = new ArrayList<Walk>();
 	Calendar c = Calendar.getInstance();
 	c.setTime(new Date());
 	c.add(Calendar.HOUR, -6);
 	Date d = c.getTime();
 	//Logger log = Logger.getLogger("home.jsp");
 	//log.warning("today = " + d.toString());
 	Walk nextWalk = new Walk();
 	if (thisUser.walkIdsAttending != null) {
 		for (Long walkId : thisUser.walkIdsAttending) {
 			Walk w = OfyService.ofy().load().type(Walk.class).id(walkId).get();
 			//log.warning("walk start time = " + w.startTime.toString());
 			if (w.startTime.after(d)) {
 				walks.add(w);
 				//log.warning("added walk");
 			}
 			//else { log.warning("didn't add walk"); }
 		}
 		Collections.sort(walks);
 	}

	%>
  	<jsp:include page="nav.jsp"/>
  	<div class="container">
  		<div class="page-header">
  			<h1>Welcome to Find A Walk!</h1>
  		</div>
		<h2>Your Next Walk:</h2>
		<%
		if (walks.isEmpty()) {
			%>
			<p>You don't have any upcoming walks! <a href="/manageWalks">Manage your walks &gt&gt</a></p>
			<%
		}
		else {
			nextWalk = walks.get(0);
			SimpleDateFormat fDate = new SimpleDateFormat("MMMM dd");
			SimpleDateFormat fTime = new SimpleDateFormat("hh:mm a");
		%>
			<p>Your next walk is <b><%= fDate.format(nextWalk.startTime) %></b>
			between <b><%= fTime.format(nextWalk.startTime) %></b> and 
			<b><%= fTime.format(nextWalk.endTime) %></b>, at <b><%= nextWalk.location %></b>. 
			<%
			if (thisUser.walkIdsHosting != null && thisUser.walkIdsHosting.contains(nextWalk.id)) {
				%>
				You are hosting this walk. <a href="/edit-walk.jsp?walkId=<%=nextWalk.id%>">Edit this walk &gt&gt</a>
				<%
			}
			else {
				DogOwner host = OfyService.ofy().load().type(DogOwner.class).id(nextWalk.ownerId).get();
				%>
				You are joining <a href="/profile.jsp?profileId=<%=host.id%>"><%= host.name %>'s</a> walk. <a href="/manageWalks">Manage your walks &gt&gt</a>
				<%
			}
			%>
		<%
		}
		%>
  		<br>
  		<h2>Post a New Walk Listing:</h2>
  		<br>
		<form class="form form-validate" role="form" name="createWalk" method="post" action="/createWalk">
			<div class="row">
				<div class="col-md-4">
					<div class="form-group">
						<label for="date" class="control-label">Date of walk:</label>
						<input type="date" class="form-control" id="date" name="date" required/>
					</div>
					<div class="form-group">
						<label for="location" class="control-label">Location:</label>
						<input type="text" class="form-control" id="location" name="location" onchange="getLatLng();" required></input>
						<span class="help-block">Address or landmark</span>
					</div>
					<div class="form-group">
						<label for="length" class="control-label">Length of the walk (in minutes):</label>
						<input type="number" class="form-control" id="length" name="length" min="1" required></input>
					</div>
					<div class="form-group">
						<label for="maxNumDogs" class="control-label">Maximum number of other dogs you want to join:</label>
						<input type="number" class="form-control" id="maxNumDogs" name="maxNumDogs" min="1" required></input>
					</div>
				</div>
				<div class="col-md-4">
					<div class="form-group">
						<label for="startTime" class="control-label">Earliest time you want to start the walk:</label>
						<input type="time" class="form-control" id="startTime" name="startTime" required></input>
						<span class="help-block">Format: HH:mm AM/PM</span>
					</div>
					<div class="form-group">
						<label for="endTime" class="control-label">Latest time you want to end the walk:</label>
						<input type="time" class="form-control" id="endTime" name="endTime" required></input>
						<span class="help-block">Format: HH:mm AM/PM</span>
					</div>
					<div class="form-group">
						<label for="comments" class="col-sm-4 control-label">Comments:</label>
						<textarea class="form-control" id="comments" name="comments" rows="1"></textarea>
					</div>
				</div>
				<div class="col-md-4">
					<h4>Select the dog(s) you will bring:</h4>	
					<% 
					int i = 0;
					for (Long dogId : thisUser.dogIds) {
						Dog dog = OfyService.ofy().load().type(Dog.class).id(dogId).get();
						String dogNum = "dog" + i;
						%>
						<div class="checkbox">
						<label>
							<input type="checkbox" class="list" name="<%= dogNum %>" value="<%= dog.id %>"><%= dog.name %>
						</label>
						</div>
						<%
						i++;
					}
					%>
					<input type="hidden" name="latitude" id="latitude" value="">
					<input type="hidden" name="longitude" id="longitude" value="">
					<input type="hidden" name="google_location" id="google_location" value="">
					<button type="submit" class="btn btn-primary" id="postBtn" disabled="disabled">Post This Walk</button>			
				</div>
			</div>
		</form>
<!-- 		<script>
		$(".form-validate").validate();
		</script> -->
		
		<script>
		var geocoder;
		function initialize() {
			geocoder = new google.maps.Geocoder();
		}
		
		function getLatLng() {
			var address = $("#location").val();
			$('#postBtn').prop('disabled',true);
			if(address.length == 0) {
				return;
			}
			$('#latitude').val("");
			$('#longitude').val("");
			$('#google_location').val("");
			geocoder.geocode( { 'address' : address }, function(results, status) {
				if (status == google.maps.GeocoderStatus.OK) {
					if (results.length > 1) {
						alert("The location you entered is too vague. Please refine it and and try again.");
					}
					else {
						var latlng = results[0].geometry.location;
						var loc = results[0].formatted_address;
						$('#latitude').val(latlng.lat());
						$('#longitude').val(latlng.lng());
						$('#google_location').val(loc);
						$('#postBtn').prop('disabled',false);
					}
				}
				else {
					alert("There was an error processing the location of your walk. Please check your location and try again.");
				}
			});
		}
		
		function getBounds() {
			var zipcode = $('#zipcode').val();
			$('#zipBtn').prop('disabled',true);
			if(zipcode.length == 0) {
				return;
			}
			$('#Nlatitude').val("");
			$('#Elongitude').val("");
			$('#Slatitude').val("");
			$('#Wlongitude').val("");
			$('#centerLat').val("");
			$('#centerLng').val("");
			geocoder.geocode( { 'address' : zipcode }, function(results, status) {
				if (status == google.maps.GeocoderStatus.OK) {
					if (results.length > 1) {
						alert("The location you entered is too vague. Please refine it and and try again.");
					}
					else {
	 					var bounds = results[0].geometry.bounds;
	 					if (typeof bounds === 'undefined') {
	 						alert("Please enter a zip code.");
	 						return;
	 					}
						$('#Nlatitude').val(bounds.getNorthEast().lat());
						$('#Elongitude').val(bounds.getNorthEast().lng());
						$('#Slatitude').val(bounds.getSouthWest().lat());
						$('#Wlongitude').val(bounds.getSouthWest().lng());
						var latlng = results[0].geometry.location;
						$('#centerLat').val(latlng.lat());
						$('#centerLng').val(latlng.lng());
						$('#zipBtn').prop('disabled', false);
					}
				}
				else {
					alert("There was an error processing the zip code you entered. Please check the zip code and try again.");
				}
			});
		}
		
		function onSubmit() {
			var errors = "";
			var walkDate = $("#date").val();
			var dateParts = walkDate.split('-');
			var walkYear = dateParts[0];
			var walkMonth = dateParts[1];
			var walkDay = dateParts[2];
			var today = new Date();
			var start = $("#startTime").val();
			var startParts = start.split(':');
			var startHour = startParts[0];
			var startMin = startParts[1];
			var end = $("#endTime").val();
			var endParts = end.split(':');
			var endHour = endParts[0];
			var endMin = endParts[1];
			var length = $("#length").val();
			var diff = 0;
			var flag = 0;
			if (today.getFullYear() > walkYear) {
				errors = errors + '- The walk must be in the future\n';
				flag = 1;
			}
			else if (today.getFullYear() == walkYear) {
				if (today.getMonth() > (walkMonth-1)) {
					errors = errors + '- The walk must be in the future\n';
					flag = 1;
				}
				else if (today.getMonth() == (walkMonth-1)) {
					if (today.getDate() > walkDay) {
						errors = errors + '- The walk must be in the future\n';
						flag = 1;					
					}
					else if (today.getDate() == walkDay) {
						if (today.getHours() > startHour) {
							errors = errors + '- The walk must be in the future\n';
							flag = 1;	
						}
						else if (today.getHours() == startHour) {
							if (today.getMinutes() > startMin) {
							errors = errors + '- The walk must be in the future\n';
							flag = 1;
							}
						}
					}
				}
			}
			
			if (endHour < startHour) {
				errors = errors + '- The end time must be after the start time\n';
				flag = 1;
			}
			else if ((endHour == startHour) && (endMin < startMin)) {
				errors = errors + '- The end time must be after the start time\n';
				flag = 1;			
			}
			else {
				if (endMin >= startMin) {
					a = (endHour-startHour)*60;
					b = endMin-startMin
					diff = (endHour-startHour)*60+(endMin-startMin);
				} else {
					a = (endHour-startHour-1)*60;
					b = (endMin)*(-1);
					c = 60-startMin;
					diff = a-b+c;
				}
				extra = diff-length;
				if (diff-length < 0) {
					errors = errors + '- The difference between the start time and the end time must be greater than the length of the walk\n';
					flag = 1;				
				}				
			}
			if ((length+"").match(/^\d+$/)) { }
			else {
				errors = errors + '- The length of the walk must be a whole number\n';
			}
			
			var fields = $("input[class='list']").serializeArray();
			if(fields.length==0) {
				errors = errors + '- You must select at least one of your dogs';
				flag = 1;
			}
			if (flag == 1) {
				alert('Please fix the following:\n' + errors);
				return false;
			}
			else { 
				return true;
			}
		}
		$(".form-validate").submit(onSubmit);
		google.maps.event.addDomListener(window, 'load', initialize);
		</script>
		<br>
		<h2>Find others' walk listings:</h2>
		<br>
		<div class="row">
			<div class="col-sm-4">
				<p><b>Search by date, time, location:</b></p><br>
				<a href="/search.jsp"><button type="button" class="btn btn-primary">Search others' walk listings</button></a>
			</div>
			<div class="col-sm-8">
				<form class="form-horizontal" role="form" name="zipSearch" method="post" action="/zipSearch">
					<div class="form-group">
						<label for="zipcode" class="col-sm-8 control-label">Or, enter your zip code to see a map of all nearby walks later today:</label>
						<div class="col-sm-4">
							<input type="text" class="form-control" id="zipcode" name="zipcode" onchange="getBounds();">
						</div>
					</div>
					<input type="hidden" name="Nlatitude" id="Nlatitude" value="">
					<input type="hidden" name="Elongitude" id="Elongitude" value="">
					<input type="hidden" name="Slatitude" id="Slatitude" value="">
					<input type="hidden" name="Wlongitude" id="Wlongitude" value="">
					<input type="hidden" name="centerLat" id="centerLat" value="">
					<input type="hidden" name="centerLng" id="centerLng" value="">
					<div class="col-md-9 col-md-offset-3">
						<button type="submit" id="zipBtn" class="btn btn-primary" disabled="disabled">Go To Map</button>
					</div>
				</form>
			</div>
		</div>
  	</div>
  </body>
 </html>