<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.findawalk.Walk" %>
<%@ page import="com.findawalk.DogOwner" %>
<%@ page import="com.findawalk.Dog" %>
<%@ page import="com.findawalk.OfyService" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Date" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="com.google.gson.reflect.TypeToken" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.lang.reflect.Type" %>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
  <head>
  	<link type="text/css" rel="stylesheet" href="/stylesheets/bootstrap.css" />
  	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
  	<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js"></script>
  	<script src="http://ajax.aspnetcdn.com/ajax/jquery.validate/1.11.1/jquery.validate.min.js"></script>
  	<title>Manage Walks | Find A Walk</title>
  </head>
  
  <body>  
	<%
	if (session.getAttribute("email") == null) {
		response.sendRedirect("/login.jsp?redirect=manage-walks");
		return;
		
	} else if (session.getAttribute("account") == null) {
		response.sendRedirect("/create-account.jsp");
		return;
	}
	Long userId = (Long)session.getAttribute("account");
    Gson gson = new Gson();
    Type t = new TypeToken<Map<String, ArrayList<Walk>>>(){}.getType();
    Map<String, ArrayList<Walk>> mapOfWalks = gson.fromJson((String)request.getAttribute("map"), t);
   	if (mapOfWalks == null) {
   		response.sendRedirect("/manageWalks");
   		return;
   	}
	SimpleDateFormat fDate = new SimpleDateFormat("MMMM dd");
	SimpleDateFormat fTime = new SimpleDateFormat("hh:mm a");
 	Calendar c = Calendar.getInstance();
 	c.setTime(new Date());
 	c.add(Calendar.HOUR, -6);
 	Date today = c.getTime();
 	c.setTime(new Date());
 	c.add(Calendar.HOUR, -6);
 	c.add(Calendar.DATE, 1);
 	Date tomorrow = c.getTime();
 	c.setTime(new Date());
 	c.add(Calendar.HOUR, -6);
 	c.add(Calendar.DATE, -1);
 	Date yesterday = c.getTime();
	%>
  	<jsp:include page="nav.jsp?highlight=manage-walks"/>
  	<div class="container">
  		<h2>Manage Walks</h2>
  		<div class="row">
  			<h3>Future Walks You Are Hosting</h3>
  			<%
  			if (!mapOfWalks.containsKey("futureHosting")) {
  				%>
  				<p>You are not hosting any future walks.</p>
  				<%
  			} else {
  				ArrayList<Walk> futureHosting = mapOfWalks.get("futureHosting");
  				%>
  				<table class="table table-hover">
  					<tbody>
  					<tr><th>Date</th><th>Earliest Start Time</th><th>Latest End Time</th><th>Length (minutes)</th><th>Location</th><th>Max # of Dogs</th>
					<th># of Dogs RSVP'd</th><th>Types of Dogs Attending</th><th>Other Attendees</th><th>Edit</th><th>Cancel Walk</th><th>Message All Attendees</th>
	  				<%
	  				for (Walk w : futureHosting) {
	  					String day = "";
	  					if ((today.getYear() == w.startTime.getYear()) && (today.getMonth() == w.startTime.getMonth()) && (today.getDate() == w.startTime.getDate())) {
	  						if (w.startTime.getHours() >= 17) {
	  							day = "Tonight";
	  						}
	  						else if (w.startTime.getHours() < 12) {
	  							day = "This morning";
	  						}
	  						else {
	  							day = "Today";
	  						}
	  					}
	  					else if ((tomorrow.getYear() == w.startTime.getYear()) && (tomorrow.getMonth() == w.startTime.getMonth()) && (tomorrow.getDate() == w.startTime.getDate())) {
	  						day = "Tomorrow";
	  					}
	  					else if ((yesterday.getYear() == w.startTime.getYear()) && (yesterday.getMonth() == w.startTime.getMonth()) && (yesterday.getDate() == w.startTime.getDate())) {
	  						day = "Yesterday";
	  					}
	  					else {
	  						day = fDate.format(w.startTime);
	  					}
	  					%>
	  					<tr>
	  						<td><%= day %></td>
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
 						%><td><%= types %></td>
 						<td><%
 						if (w.attendeeIds != null) {
 							List<String> people = new ArrayList<String>();
 	 						int i = 0;
 	 						for (Long attendeeId : w.attendeeIds) {
 	 							if (i > 0) {
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
 						%></td>
	  						
	  						<td><a href="/edit-walk.jsp?walkId=<%=w.id%>">edit</a></td>
	  						<td><a href="/deleteWalk?walkId=<%=w.id%>" onclick="return confirm('Are you sure?')">cancel walk</a></td>
	  						<%
	  						if (w.attendeeIds == null || w.attendeeIds.size() == 0) {
	  							%>
	  							<td>--</td>
	  							<%
	  						}
	  						else {
		  						%>
								<td><a href="#" onclick="openNew(<%= w.id%>, 'all')">message all attendees</a></td>
								<%
							}
	  						%>
	  					</tr>
	  					<%
	  				}
	  				%>
  					</tbody>
  				</table>
  				<%
  			}
  			%>
  		</div>
		<div class="row">
  			<h3>Future Walks You Are Attending</h3>
  			<%
  			if (!mapOfWalks.containsKey("futureAttending")) {
  				%>
  				<p>You are not attending any future walks.</p>
  				<%
  			} else {
  				ArrayList<Walk> futureAttending = mapOfWalks.get("futureAttending");
  				%>
  				<table class="table table-hover">
  					<tbody>
  					<tr><th>Date</th><th>Earliest Start Time</th><th>Latest End Time</th><th>Length (minutes)</th><th>Location</th><th>Max # of Dogs</th>
					<th># of Dogs RSVP'd</th><th>Types of Dogs Attending</th><th>Host</th><th>Other Attendees</th><th>Cancel Walk</th><th>Message All Attendees</th>
	  				<%
	  				for (Walk w : futureAttending) {
	  					String day = "";
	  					if ((today.getYear() == w.startTime.getYear()) && (today.getMonth() == w.startTime.getMonth()) && (today.getDate() == w.startTime.getDate())) {
	  						if (w.startTime.getHours() >= 17) {
	  							day = "Tonight";
	  						}
	  						else if (w.startTime.getHours() < 12) {
	  							day = "This morning";
	  						}
	  						else {
	  							day = "Today";
	  						}
	  					}
	  					else if ((tomorrow.getYear() == w.startTime.getYear()) && (tomorrow.getMonth() == w.startTime.getMonth()) && (tomorrow.getDate() == w.startTime.getDate())) {
	  						day = "Tomorrow";
	  					}
	  					else if ((yesterday.getYear() == w.startTime.getYear()) && (yesterday.getMonth() == w.startTime.getMonth()) && (yesterday.getDate() == w.startTime.getDate())) {
	  						day = "Yesterday";
	  					}
	  					else {
	  						day = fDate.format(w.startTime);
	  					}
	  					%>
	  					<tr>
	  						<td><%= day %></td>
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
	 	 					%><td><a href="/profile.jsp?profileId=<%=w.ownerId%>"><%= host.name %></td>
	 						<td>
	 						<%
	 						if (w.attendeeIds != null) {
	 							if (w.attendeeIds.size() == 1) {
	 								%>None yet<%
	 							}
	 							else {
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
	 							}
	 						} else {
	 							%>None yet<%
	 						}
	 						%></td>
	  						<%
	  						session.setAttribute("walkId", w.id);
	  						%>
	  						<td><a href="/leaveWalk" onclick="return confirm('Are you sure?')">leave walk</a></td>
	  						<td><a href="#" onclick="openNew(<%= w.id%>, 'host')">message <%= host.name %></a></td>
	  					</tr>
	  					<%
	  				}
	  				%>
  					</tbody>
  				</table>
  				<%
  			}
  			%>
  		</div>
  		<div class="row">
  			<h3>Past Walks You Have Hosted</h3>
  			<%
  			if (!mapOfWalks.containsKey("pastHosted")) {
  				%>
  				<p>You have not hosted any past walks.</p>
  				<%
  			} else {
  				ArrayList<Walk> pastHosted = mapOfWalks.get("pastHosted");
  				%>
  				<table class="table table-hover">
  					<tbody>
  					<tr><th>Date</th><th>Earliest Start Time</th><th>Latest End Time</th><th>Length (minutes)</th><th>Location</th><th>Max # of Dogs</th>
					<th># of Dogs Attended</th><th>Types of Dogs Attended</th><th>Other Attendees</th><th>Clone</th>
	  				<%
	 				for (Walk w : pastHosted) {
	  					String day = "";
	  					if ((today.getYear() == w.startTime.getYear()) && (today.getMonth() == w.startTime.getMonth()) && (today.getDate() == w.startTime.getDate())) {
	  						if (w.startTime.getHours() >= 17) {
	  							day = "Tonight";
	  						}
	  						else if (w.startTime.getHours() < 12) {
	  							day = "This morning";
	  						}
	  						else {
	  							day = "Today";
	  						}
	  					}
	  					else if ((tomorrow.getYear() == w.startTime.getYear()) && (tomorrow.getMonth() == w.startTime.getMonth()) && (tomorrow.getDate() == w.startTime.getDate())) {
	  						day = "Tomorrow";
	  					}
	  					else if ((yesterday.getYear() == w.startTime.getYear()) && (yesterday.getMonth() == w.startTime.getMonth()) && (yesterday.getDate() == w.startTime.getDate())) {
	  						day = "Yesterday";
	  					}
	  					else {
	  						day = fDate.format(w.startTime);
	  					}
	  					%>
	  					<tr>
	  						<td><%= day %></td>
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
	 							%>None<%
	 						}
	 						%></td>
	  						<td><a href="/clone-walk.jsp?walkId=<%=w.id%>">clone</a></td>
	  					</tr>
	  					<%
	  				}
	  				%>
  					</tbody>
  				</table>
  				<%
  			}
  			%>
  		</div>
  		<div class="row">
  			<h3>Past Walks You Have Attended</h3>
  			  			<%
  			if (!mapOfWalks.containsKey("pastAttended")) {
  				%>
  				<p>You have not attended any past walks.</p>
  				<%
  			} else {
  				ArrayList<Walk> pastAttended = mapOfWalks.get("pastAttended");
  				%>
  				<table class="table table-hover">
  					<tbody>
  					<tr><th>Date</th><th>Earliest Start Time</th><th>Latest End Time</th><th>Length (minutes)</th><th>Location</th><th>Max # of Dogs</th>
					<th># of Dogs Attended</th><th>Types of Dogs Attended</th><th>Host</th><th>Other Attendees</th><th>Message Host</th>
	  				<%
	  				for (Walk w : pastAttended) {
	  					String day = "";
	  					if ((today.getYear() == w.startTime.getYear()) && (today.getMonth() == w.startTime.getMonth()) && (today.getDate() == w.startTime.getDate())) {
	  						if (w.startTime.getHours() >= 17) {
	  							day = "Tonight";
	  						}
	  						else if (w.startTime.getHours() < 12) {
	  							day = "This morning";
	  						}
	  						else {
	  							day = "Today";
	  						}
	  					}
	  					else if ((tomorrow.getYear() == w.startTime.getYear()) && (tomorrow.getMonth() == w.startTime.getMonth()) && (tomorrow.getDate() == w.startTime.getDate())) {
	  						day = "Tomorrow";
	  					}
	  					else if ((yesterday.getYear() == w.startTime.getYear()) && (yesterday.getMonth() == w.startTime.getMonth()) && (yesterday.getDate() == w.startTime.getDate())) {
	  						day = "Yesterday";
	  					}
	  					else {
	  						day = fDate.format(w.startTime);
	  					}
	  					%>
	  					<tr>
	  						<td><%= day %></td>
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
 	 						%><td><a href="/profile.jsp?profileId=<%=w.ownerId%>"><%= host.name %></td>
	 						<td><%
	 						if (w.attendeeIds != null) {
	 							if (w.attendeeIds.size() == 1) {
	 								%>None<%
	 							}
	 							else {
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
	 							}
	 						} else {
	 							%>None<%
	 						}
	 						%></td>
	  						<td><a href="#" onclick="openNew(<%= w.id%>, 'host')">message <%= host.name %></a></td>
	  					</tr>
	  					<%
	  				}
	  				%>
  					</tbody>
  				</table>
  				<%
  			}
  			%>
  		</div>
  	</div>
  	
  	<script>
		function openNew(walkId, recip) {
			window.open("/sendmsg.jsp?walkId="+walkId+"&recip="+recip,null, "height=300,width=400,status=yes,toolbar=no,menubar=no,location=no");
		}
	</script>
  </body>
 </html>