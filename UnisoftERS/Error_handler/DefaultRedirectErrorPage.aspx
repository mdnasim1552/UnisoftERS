<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="DefaultRedirectErrorPage.aspx.vb" Inherits="UnisoftERS.DefaultRedirectErrorPage" %>

<%@ Import Namespace="UnisoftERS" %>
<script runat="server">
  Dim ex As HttpException

  Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)
    ' Log the exception and notify system operators
        ex = New HttpException("defaultRedirect")
        LogManager.LogManagerInstance.LogError("Generic Error Page: Unexpected error occured and has been caught in the Application Error event. ", ex)
    End Sub

</script>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head id="Head1" runat="server">
  <title>DefaultRedirect Error Page</title>
    <link href="../Styles/Site.css" rel="stylesheet" type="text/css" />
</head>
<body>
  <form id="form1" runat="server">
    <div id="ErrorDetails">
    <div><img src="../Images/NewLogo_198_83.png" alt="ERS" /></div>      
        <hr />
    <h2 class="hidden">Page NOT found!</h2>
        <h2>Unexpected Error!</h2>
      <br />500: That&#39;s an Error!&nbsp;
      <h3>We are sorry for the inconvenience!</h3>
      <p>
          An unexpected error has occoured! Solus Endoscopy has logged the details and we will contact you soon.<br/>
          Click here to go back to <a href="../Products/Default.aspx">Home Page</a> 
      </p>
&nbsp;</p>

    <br />
      
  </div>      
  </form>
</body>
</html>