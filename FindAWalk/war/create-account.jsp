<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.google.appengine.api.blobstore.BlobstoreService" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
if (session.getAttribute("email") == null) {
	response.sendRedirect("/login.jsp");
} else if (session.getAttribute("account") != null) {
	response.sendRedirect("/home.jsp");
} else {
	BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
	UserService userService = UserServiceFactory.getUserService();
%>
<html>
  <head>
  	<link type="text/css" rel="stylesheet" href="/stylesheets/bootstrap.css" />
  	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
  	<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js"></script>
  	<script src="http://ajax.aspnetcdn.com/ajax/jquery.validate/1.11.1/jquery.validate.min.js"></script>
  	<title>Create an Account | Find A Walk</title>
  </head>
  
  <body>
  	<div class="container">
  		<div class="starter-template">
  			<h1 style="text-align:center;">Create an Account</h1>		
			<p class="lead"><br>All users must create an account to access Find A Walk's services. Your Google account will be used for authentication
			and administrative emails, and it will never be displayed to or shared with others. The information you provide below will be displayed on
			your profile (visible to other Find A Walk users) and in search results for searches that match Walks you create.</p>
			<p>(To sign out of this Google account and sign in with a different one, <a href="<%= userService.createLogoutURL("/logout")%>">click here</a>.)</p>
			<h2>The Basics (required fields):</h2>
			<form class="form-horizontal form-validate" role="form" name="createAccount" method="post" action="<%= blobstoreService.createUploadUrl("/createAccount") %>" enctype="multipart/form-data">
				<div class="form-group">
					<label for="name" class="col-sm-2 control-label">Your name:</label>
					<div class="col-sm-3">
						<input type="text" class="form-control" id="name" name="ownerName" required/>
					</div>
					<label for="numDogs" class="col-sm-3 control-label">Number of dogs you have:</label>
					<div class="col-sm-1">
						<input type="number" class="form-control" id="numDogs" name="numDogs" min="1" required></input>
					</div>
					<div class="col-sm-3"></div>
				</div>					
				<h4>Your dogs:</h4>
				<div id="dogFields" class="form-group">
					<div id="rowNum0" class="form-group">
						<label for="dogName0" class="col-sm-1 control-label">Name:</label>
						<div class="col-sm-1">
							<input type="text" class="form-control" id="dogName0" name="dogName0" required>
						</div>
						<label for="dogKind0" class="col-sm-1 control-label">Kind:</label>
						<div class="col-sm-2">
							<input type="text" class="form-control" id="dogKind0" name="dogKind0" required>
						</div>
						<label for="dogAge0" class="col-sm-1 control-label">Age (years):</label>
						<div class="col-sm-1">
							<input type="number" class="form-control" id="dogAge0" name="dogAge0" min="0" required></input>
						</div>
						<label for="dogGender0" class="col-sm-1 control-label">Gender:</label>
						<div class="col-sm-2">
							<select class="form-control" id="dogGender0" name="dogGender0" required>
								<option value="male">Male</option>
								<option value="female">Female</option>
							</select>
						</div>
						<label for="dogWeight0" class="col-sm-1 control-label">Weight (pounds):</label>
						<div class="col-sm-1">
							<input type="number" class="form-control" id="dogWeight0" name="dogWeight0" min="0" required></input>
						</div>
					</div>
				</div>
				<br>
				<div class="form-group">
					<label for="profilePicture" class="col-sm-4 control-label">Profile picture: Upload a picture of your dog(s)</label>
					<div class="col-sm-3">
						<input type="file" class="form-control" id="profilePicture" name="profilePicture" accept="image/*" required></input>
					</div>
					<div class="col-sm-5"></div>
				</div>
				<h2>Share more about yourself:</h2>
				<div class="form-group">
					<label for="aboutOwner" class="col-sm-4 control-label">Who are you? Tell us what you do, what you love, and what you like to talk about on walks:</label>
					<div class="col-sm-8">
						<textarea class="form-control" id="aboutOwner" name="aboutOwner" rows="2"></textarea>
					</div>
				</div>
				<div class="form-group">
					<label for="aboutDogs" class="col-sm-4 control-label">Who is your dog? Tell us about your dog's personality:</label>
					<div class="col-sm-8">
						<textarea class="form-control" id="aboutDogs" name="aboutDogs" rows="2"></textarea>
					</div>
				</div>
				<div class="form-group">
					<label for="dogLikes" class="col-sm-4 control-label">Kinds of dogs your dog loves:</label>
					<div class="col-sm-8">
						<textarea class="form-control" id="dogLikes" name="dogLikes" rows="1"></textarea>
					</div>
				</div>
				<div class="form-group">
					<label for="dogDislikes" class="col-sm-4 control-label">Kinds of dogs your dog doesn't love:</label>
					<div class="col-sm-8">
						<textarea class="form-control" id="dogDislikes" name="dogDislikes" rows="1"></textarea>
					</div>
				</div>
				<div class="form-group">
					<label for="favePlaces" class="col-sm-4 control-label">Favorite places to walk:</label>
					<div class="col-sm-8">
						<textarea class="form-control" id="favePlaces" name="favePlaces" rows="1"></textarea>
					</div>
				</div>
				<div class="form-group">
					<div class="col-sm-offset-4 col-sm-8">
						<button type="submit" class="btn btn-primary">Create Account</button>
					</div>
				</div>
			</form>
<!-- 			<script>
			$(".form-validate").validate();
			</script> -->
  		</div>
	</div>
	<script>
	$("#numDogs").click(function() {
		var numRows = document.getElementById("numDogs").value;
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
<%
}
%>