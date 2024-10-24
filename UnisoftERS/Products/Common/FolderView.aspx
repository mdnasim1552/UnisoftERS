<%@ Page Title="" Language="vb" AutoEventWireup="false" CodeBehind="FolderView.aspx.vb" Inherits="UnisoftERS.FolderView" %>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head runat="server">
        <meta http-equiv="refresh" content="5">
        <title>Live File Viewer</title>
        <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
        <script>
            function resizeImage(imgToResize) {
                if (imgToResize.height = 100) {
                    
                    imgToResize.style.height = (imgToResize.naturalHeight / 2) + "px";
                    imgToResize.style.width = (imgToResize.naturalWidth / 2) + "px";
                }
            }
        </script>
    </head>
    <body>
        <div id="fileview" runat="server">
            <p><asp:Label style="font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif" ID="fileLocation" runat="server" /></p>
            <asp:Repeater ID="FileRepeater" runat="server">
                <ItemTemplate>
                    <asp:Image  style="height:100px; width:100px" ImageUrl="<%#Container.DataItem.ToString() %>" runat="server" onclick="resizeImage(this);" />
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <div id="Azureimage" runat="server">
            <p><asp:Label style="font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif" ID="Label1" runat="server" /></p>
            <asp:Repeater ID="Repeater1" runat="server">
                <ItemTemplate>
                    <img  style="height:100px; width:100px" src="<%#Container.DataItem.ToString() %>" runat="server" onclick="resizeImage(this);" />
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </body>
</html>
