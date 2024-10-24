<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="PrintOrderCommPDF.aspx.vb" Inherits="UnisoftERS.PrintOrderCommPDF" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
     <title>OrderComms Report</title>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <link href="../../Styles/Scheduler.css" rel="stylesheet" type="text/css" />
    <link href="../../Styles/Site.css" rel="stylesheet" type="text/css" />
    <link rel="icon" type="image/png" href="../images/icons/favicon.png" />

    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-ui.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <h3>OrderComms Report</h3>
            <asp:Label ID="lblStatus" runat="server"></asp:Label>
        </div>
    </form>
</body>
</html>
