<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.findawalk.DogOwner" %>
<%@ page import="com.findawalk.Dog" %>
<%@ page import="com.findawalk.Walk" %>
<%@ page import="com.findawalk.OfyService" %>

<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
  <head>
  	<link type="text/css" rel="stylesheet" href="/stylesheets/bootstrap.css" />
  	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
  	<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js"></script>
  	<script src="http://ajax.aspnetcdn.com/ajax/jquery.validate/1.11.1/jquery.validate.min.js"></script>
   	<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?v=3.exp&key=AIzaSyAw8zM-LssLj2C1NqJug4qYVicm9dPoh9Q&sensor=false"></script>
  	<title>Edit a Walk | Find A Walk</title>
  </head>
  
  <body>
	<%
	if (session.getAttribute("email") == null) {
		if (request.getParameter("walkId") == null) {
			response.sendRedirect("/login.jsp");
		}
		else {
			// parameters: walkId
			String walkId = request.getParameter("walkId");
			response.sendRedirect("/login.jsp?redirect=edit-walk&walkId=" + walkId);
		}
		return;
		
	} else if (session.getAttribute("account") == null) {
		response.sendRedirect("/create-account.jsp");
		return;
	}
	if (request.getParameter("walkId") == null) {
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
	DogOwner thisUser = OfyService.ofy().load().type(DogOwner.class).id(userId).get();
	SimpleDateFormat fDate = new SimpleDateFormat("yyyy-MM-dd");
	SimpleDateFormat fTime = new SimpleDateFormat("HH:mm");
	
	%>
  	<jsp:include page="nav.jsp"/>
  	<div class="container">
  		<h1>Edit Your Walk:</h1>
  		<form class="form form-validate" role="form" name="editWalk" method="post" action="/editWalk">
			<div class="row">
				<div class="col-md-4">
					<div class="form-group">
						<label for="date" class="control-label">Date of walk:</label>
						<input type="date" class="form-control" id="date" name="date" value="<%= fDate.format(walk.startTime) %>" required/>
					</div>
					<div class="form-group">
						<label for="location" class="control-label">Location:</label>
						<input type="text" class="form-control" id="location" name="location" value="<%= walk.location %>" onchange="getLatLng();" required></input>
						<span class="help-block">Address or landmark</span>
					</div>
					<div class="form-group">
						<label for="length" class="control-label">Length of the walk (in minutes):</label>
						<input type="number" class="form-control" id="length" name="length" min="1" value="<%= walk.length %>" required></input>
					</div>
					<div class="form-group">
						<label for="maxNumDogs" class="control-label">Maximum number of other dogs you want to join:</label>
						<%
						int maxDogs = walk.maxNumDogs - walk.numOwnerDogs;
						%>
						<input type="number" class="form-control" id="maxNumDogs" name="maxNumDogs" min="1" value="<%= maxDogs %>" required></input>
					</div>
				</div>
				<div class="col-md-4">
					<div class="form-group">
						<label for="startTime" class="control-label">Earliest time you want to start the walk:</label>
						<input type="time" class="form-control" id="startTime" name="startTime" value="<%= fTime.format(walk.startTime) %>" required></input>
					</div>
					<div class="form-group">
						<label for="endTime" class="control-label">Latest time you want to end the walk:</label>
						<input type="time" class="form-control" id="endTime" name="endTime" value="<%= fTime.format(walk.endTime) %>" required></input>
					</div>
					<div class="form-group">
						<label for="comments" class="col-sm-4 control-label">Comments:</label>
						<textarea class="form-control" id="comments" name="comments" rows="1"><%= walk.comments %></textarea>
					</div>
				</div>
				<div class="col-md-4">
					<h4>Select the dog(s) you will bring:</h4>	
					<% 
					int i = 0;
					for (Long dogId : thisUser.dogIds) {
						Dog dog = OfyService.ofy().load().type(Dog.class).id(dogId).get();
						String dogNum = "dog" + i;
						boolean check = false;
						if (walk.dogIds.contains(dogId)) {
							check = true;
						}
						%>
						<div class="checkbox">
						<label>
							<input type="checkbox" class="list" name="<%= dogNum %>" value="<%= dog.id %>" <% if(check) { %>checked<% } %>><%= dog.name %>
						</label>
						</div>
						<%
						i++;
					}
					%>
					<input type="hidden" name="walkId" value="<%= walkId %>">
					<input type="hidden" name="latitude" id="latitude" value="">
					<input type="hidden" name="longitude" id="longitude" value="">
					<input type="hidden" name="google_location" id="google_location" value="">
					<button type="submit" class="btn btn-primary" id="editBtn">Edit This Walk</button>			
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
			$('#editBtn').prop('disabled',true);
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
						$('#editBtn').prop('disabled',false);
					}
				}
				else {
					alert("There was an error processing the location of your walk. Please check your location and try again.");
				}
			});
		}
		
		function onSubmit() {
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
			var errors = "";
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
			
			var fields = $("input[class='list']").serializeArray();
			if(fields.length==0) {
				errors = errors + '- You must select at least one of your dogs';
				flag = 1;
			}
			if (flag == 1) {
				alert('Please fix the following:\n' + errors);
				return false;
			}
			else { return true; }
		}
		$(".form-validate").submit(onSubmit);
		google.maps.event.addDomListener(window, 'load', initialize);
		</script>
  	</div>
  </body>
 </html>