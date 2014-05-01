<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.findawalk.DogOwner" %>
<%@ page import="com.findawalk.Dog" %>
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
  	<title>Edit Your Profile | Find A Walk</title>
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
	if (request.getParameter("profileId") == null) {
		response.sendRedirect("/home.jsp");
		return;
	}
	OfyService.ofy().clear();
	Long profileId = new Long(request.getParameter("profileId"));
	Long userId = (Long)session.getAttribute("account");
 	if (!userId.equals(profileId)) {
		response.sendRedirect("/profile.jsp");
		return;
	}
	DogOwner user = OfyService.ofy().load().type(DogOwner.class).id(userId).get();	
	%>
  	<jsp:include page="nav.jsp?highlight=profile"/>
  	<div class="container">
  		<h1>Edit Your Profile</h1>
  		<h2>The Basics (required fields):</h2>
		<form class="form-horizontal form-validate" role="form" name="editProfile" method="post" action="/editProfile">
			<div class="form-group">
				<label for="name" class="col-sm-1 control-label">Your name:</label>
				<div class="col-sm-3">
					<input type="text" class="form-control" id="name" name="ownerName" value="<%= user.name %>" required/>
				</div>
				<div class="col-sm-8"></div>
			</div>
			<h4>Your dogs:</h4>
			<%
			for (int i = 0; i < user.numDogs; i++) {
				Long dogId = user.dogIds.get(i);
				Dog dog = OfyService.ofy().load().type(Dog.class).id(dogId).get();
				String rowA = "eRowNum" + i + "A";
				String rowB = "eRowNum" + i + "B";
				String name = "eDogName" + i;
				String kind = "eDogKind" + i;
				String age = "eDogAge" + i;
				String gender = "eDogGender" + i;
				String weight = "eDogWeight" + i;
				String remove = "eRemoveDog" + i;
				%>
				<div id="<%= rowA %>" class="form-group">
					<label for="<%= name %>" class="col-sm-1 control-label">Name:</label>
					<div class="col-sm-3">
						<input type="text" class="form-control" id="<%= name %>" name="<%= name %>" value="<%= dog.name %>" required>
					</div>
					<label for="<%= kind %>" class="col-sm-1 control-label">Kind:</label>
					<div class="col-sm-4">
						<input type="text" class="form-control" id="<%= kind %>" name="<%= kind %>" value="<%= dog.kind %>" required>
					</div>
					<label for="<%= age %>" class="col-sm-2 control-label">Age (years):</label>
					<div class="col-sm-1">
						<input type="number" class="form-control" id="<%= age %>" name="<%= age %>" min="0" value="<%= dog.age %>" required></input>
					</div>
				</div>
				<div id="<%= rowB %>" class="form-group">
					<div class="col-sm-4"></div>
					<label for="<%= gender %>" class="col-sm-1 control-label">Gender:</label>
					<div class="col-sm-2">
						<select class="form-control" id="<%= gender %>" name="<%= gender %>" required>
							<%
							if (dog.gender.equals("male")) {
								%>
								<option value="male" selected="selected">Male</option>
								<option value="female">Female</option>
								<%
							} else {
								%>
								<option value="male">Male</option>
								<option value="female" selected="selected">Female</option>
								<%
							}
							%>
						</select>
					</div>
					<label for="<%= weight %>" class="col-sm-2 control-label">Weight (pounds):</label>
					<div class="col-sm-1">
						<input type="number" class="form-control" id="<%= weight %>" name="<%= weight %>" min="0" value="<%= dog.weight %>"required></input>
					</div>
					<div class="checkbox col-sm-2">
						<label class="text-danger">
							<input type="checkbox" id="<%= remove %>" name="<%= remove %>" value="remove">Remove this dog
						</label>
					</div>
				</div>
			<%
			}
			%>
			<h4>New dogs you would like to add:</h4>
			<div class="form-group">
				<label for="numNewDogs" class="col-sm-2 control-label">Number of dogs to add:</label>
				<div class="col-sm-1">
					<input type="number" class="form-control" id="numNewDogs" name="numNewDogs" min="0" value="0" required></input>
				</div>
				<div class="col-sm-9"></div>
			</div>
			<div id="dogFields" class="form-group">
			</div>
			<br>
			<h2>Share more about yourself:</h2>
			<div class="form-group">
				<label for="aboutOwner" class="col-sm-4 control-label">Who are you? Tell us what you do, what you love, and what you like to talk about on walks:</label>
				<div class="col-sm-8">
					<textarea class="form-control" id="aboutOwner" name="aboutOwner" rows="2" ><%= user.ownerBio %></textarea>
				</div>
			</div>
			<div class="form-group">
				<%
				String aboutDogs = "";
				String dogLikes = "";
				String dogDislikes = "";
				if (user.numDogs > 1) {
					aboutDogs = "Who are your dogs? Tell us about your dogs' personalities:";
					dogLikes = "Kinds of dogs your dogs love:";
					dogDislikes = "Kinds of dogs your dogs don't love:";
				}
				else {
					aboutDogs = "Who is your dog? Tell us about your dog's personality:";
					dogLikes = "Kinds of dogs your dog loves:";
					dogDislikes = "Kinds of dogs your dog doesn't love:";
				}
				%>
				<label for="aboutDogs" class="col-sm-4 control-label"><%= aboutDogs %></label>
				<div class="col-sm-8">
					<textarea class="form-control" id="aboutDogs" name="aboutDogs" rows="2"><%= user.dogBio %></textarea>
				</div>
			</div>
			<div class="form-group">
				<label for="dogLikes" class="col-sm-4 control-label"><%= dogLikes %></label>
				<div class="col-sm-8">
					<textarea class="form-control" id="dogLikes" name="dogLikes" rows="1"><%= user.dogLikes %></textarea>
				</div>
			</div>
			<div class="form-group">
				<label for="dogDislikes" class="col-sm-4 control-label"><%= dogDislikes %></label>
				<div class="col-sm-8">
					<textarea class="form-control" id="dogDislikes" name="dogDislikes" rows="1"><%= user.dogDislikes %></textarea>
				</div>
			</div>
			<div class="form-group">
				<label for="favePlaces" class="col-sm-4 control-label">Favorite places to walk:</label>
				<div class="col-sm-8">
					<textarea class="form-control" id="favePlaces" name="favePlaces" rows="1"><%= user.places %></textarea>
				</div>
			</div>
			<div class="form-group">
				<div class="col-sm-offset-4 col-sm-8">
					<button type="submit" class="btn btn-primary">Submit Changes</button>
				</div>
			</div>
		</form>
 	</div>
<!--  	<script>
		$(".form-validate").validate();
	</script> -->
	<script>
	function onSubmit() {
		var numEdogs = <%=user.numDogs%>;
		for (var i=0; i< <%=user.numDogs%>; i++) {
			var checkboxName = "eRemoveDog" + i;
			var checkbox = document.getElementById(checkboxName);
			if (checkbox.checked) {
				numEdogs = numEdogs - 1;
			}
		}
		var numNewDogs = $("#numNewDogs").val();
		var numTotalDogs = parseInt(numEdogs) + parseInt(numNewDogs);
		if (numTotalDogs <= 0) {
			alert("You must have at least one dog associated with your account.");
			return false;
		}
		return true;
	}
	$(".form-validate").submit(onSubmit);
	</script>
	
	<script>
	$("#numNewDogs").click(function() {
		var numRows = document.getElementById("numNewDogs").value;
		$("#dogFields").empty();
		for(var rowNum = 0; rowNum < numRows; rowNum++) {
			var row = '<div id="rowNum'+rowNum+'" class="form-group"><label for="dogName'+rowNum+'" class="col-sm-1 control-label">Name:</label><div class="col-sm-1"><input type="text" class="form-control" id="dogName'+rowNum+'" name="dogName'+rowNum+'" required></div><label for="dogKind'+rowNum+'" class="col-sm-1 control-label">Kind:</label><div class="col-sm-2"><input type="text" class="form-control" id="dogKind'+rowNum+'" name="dogKind'+rowNum+'" required></div><label for="dogAge'+rowNum+'" class="col-sm-1 control-label">Age (years):</label><div class="col-sm-1"><input type="number" class="form-control" id="dogAge'+rowNum+'" name="dogAge'+rowNum+'" min="0" required></input></div><label for="dogGender'+rowNum+'" class="col-sm-1 control-label">Gender:</label><div class="col-sm-2"><select class="form-control" id="dogGender'+rowNum+'" name="dogGender'+rowNum+'" required><option value="male">Male</option><option value="female">Female</option></select></div><label for="dogWeight'+rowNum+'" class="col-sm-1 control-label">Weight (pounds):</label><div class="col-sm-1"><input type="number" class="form-control" id="dogWeight'+rowNum+'" name="dogWeight'+rowNum+'" min="0" required></input></div></div>';
			//$('#dogFields').append('<p>Blah</p>');
			$('#dogFields').append(row);
		}
	});
	</script>
  </body>
 </html>