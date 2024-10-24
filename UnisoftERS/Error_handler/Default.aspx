<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Default.aspx.vb" Inherits="UnisoftERS.TestError" %>
<%@ Import Namespace="UnisoftERS" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head id="Head1" runat="server">
  <title>Exception Handler Page</title>
</head>
<body>
  <form id="form1" runat="server">
  <div>
    <h2>
      Default Page</h2>
    <p>
      Click this button to create an InvalidOperationException.<br />
      Page_Error will catch this and redirect to 
        GenericErrorPage.aspx.<br />
      <asp:Button ID="Submit1" runat="server" 
        CommandArgument="1"
        Text="Button 1" />
    </p>
    <p>
      Click this button to create an ArgumentOutOfRangeException.<br />
      Page_Error will catch this and handle the error.<br />
      <asp:Button ID="Submit2" runat="server" 
        CommandArgument="2"
        Text="Button 2" />
    </p>
    <p>
      Click this button to create a generic Exception.<br />
      Application_Error will catch this and handle the error.<br />
      <asp:Button ID="Submit3" runat="server" 
        CommandArgument="3"
        Text="Button 3" />
    </p>
    <p>
      Click this button to create an HTTP 404 (not found) error.<br />
      Application_Error will catch this 
      and redirect to HttpErrorPage.aspx.<br />
      <asp:Button ID="Submit4" runat="server" 
        CommandArgument="4"
        Text="Button 4" />
    </p>
    <p>
      Click this button to create an HTTP 404 (not found) error.<br />
      Application_Error will catch this but will not take any action on it, 
      and ASP.NET will redirect to Http404ErrorPage.aspx. 
      The original exception object will not be available.<br />
      <asp:Button ID="Submit5" runat="server" 
        CommandArgument="5"
        Text="Button 5" />
    </p>
    <p>
      Click this button to create an HTTP 400 (invalid url) error.<br />
      Application_Error will catch this but will not take any action on it,
      and ASP.NET will redirect to DefaultRedirectErrorPage.aspx. 
      The original exception object will not be available.<br />
      <asp:Button ID="Button1" runat="server" 
        CommandArgument="6"
        Text="Button 6" />
    </p>
  </div>
  </form>
</body>
</html>