<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Oops404.aspx.vb" Inherits="UnisoftERS.Http404ErrorPage" %>

<%@ Import Namespace="UnisoftERS" %>
<script runat="server">


</script>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head id="Head1" runat="server">
  <title>HTTP 404 Error Page</title>
    <link href="../Styles/Site.css" rel="stylesheet" type="text/css" />
</head>
<body>
  <form id="form1" runat="server">
    <div id="ErrorDetails">
    <h2 class="hidden">Page NOT found!</h2>
        <img src="../Images/404_page_not_found_1x.png" alt="Page not Found!"  /><br />&nbsp;
      <br />&nbsp;
      <h2>The page you have requested cannot be found!</h2>
      <p>
         <span class="hidden"> The page either has moved to a new location or does not exist in the Site. <br /></span>
          
          We might need an Endoscopy appointent to locate the Page on the Server!<br />
          Click here to go back to <a href="../Products/Default.aspx">Home Page</a> 
      </p>

    <br />
      <div><img src="../Images/logo.png" alt="ERS" /></div>      
  </div>
  </form>
</body>
</html>