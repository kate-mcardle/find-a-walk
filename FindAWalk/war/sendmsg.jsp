<html>
  <head>
  	<link type="text/css" rel="stylesheet" href="/stylesheets/bootstrap.css" />
  	<title>Send Message | Find A Walk</title>
  </head>
  <body> 
  <div class="container">
 	<form class="form" role="form" name="sendMessage" method="post" action="/sendMessage">
 		<div class="form-group">
			<label for="msg" class="control-label">Write your message:</label>
			<textarea class="form-control" id="msg" name="msg" rows="5"></textarea>
		</div>
		<input type="hidden" name="walkId" value="<%= request.getParameter("walkId") %>">
		<input type="hidden" name="recip" value="<%= request.getParameter("recip") %>">
		<button type="submit" class="btn btn-primary">Send Message</button>	
	</form>  
	</div>
  </body>
</html>