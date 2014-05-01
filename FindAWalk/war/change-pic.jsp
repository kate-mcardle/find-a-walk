<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreService" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
if (session.getAttribute("email") == null) {
	response.sendRedirect("/login.jsp");
	return;
}
if (session.getAttribute("account") == null) {
	response.sendRedirect("/create-account.jsp");
	return;
}
BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
%>
<html>
  <head>
  	<link type="text/css" rel="stylesheet" href="/stylesheets/bootstrap.css" />
  	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
  	<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js"></script>
  	<script src="http://ajax.aspnetcdn.com/ajax/jquery.validate/1.11.1/jquery.validate.min.js"></script>
  	<title>Change Profile Picture | Find A Walk</title>
  </head>  
  <body>
  	<div class="container">
  	<%
  	if (request.getParameter("done") != null) {
  		%>
  		<p>Profile picture changed. Refresh profile page to see your new picture.</p>
  		<%
  	} else {
  	%>
 		<form class="form form-validate" role="form" name="changePic" method="post" action="<%= blobstoreService.createUploadUrl("/changePic") %>" enctype="multipart/form-data">
			<div class="form-group">
				<label for="profilePicture" class="control-label">Upload a picture of your dog(s)</label>
				<input type="file" class="form-control" id="profilePicture" name="profilePicture" accept="image/*" required></input>
			</div>
			<button type="submit" class="btn btn-primary">Change Picture</button>
		</form>
		<script>
		$(".form-validate").validate();
		</script>
	<%
	}
	%>
	</div>
  </body>
</html>