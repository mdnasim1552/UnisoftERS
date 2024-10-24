
<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="GRSA04.aspx.vb" Inherits="UnisoftERS.GRSA04" %>
<%@ Register assembly="Microsoft.ReportViewer.WebForms" namespace="Microsoft.Reporting.WebForms" tagprefix="rsweb" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <!-- #include virtual="_RVHeading.aspx"-->

    <style type="text/css">
        @page {
            size: auto; /* auto is the initial value */
            margin: 0mm; /* this affects the margin in the printer settings */
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div id="ReportContainer">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <rsweb:ReportViewer ID="RV" runat="server" Font-Names="Verdana" Font-Size="8pt" WaitMessageFont-Names="Verdana" WaitMessageFont-Size="14pt" SizeToReportContent="true" CssClass="RVcss" >
            <LocalReport ReportEmbeddedResource="UnisoftERS.GRSA04.rdlc">
            </LocalReport>
        </rsweb:ReportViewer>
        <div id="PrintBtn"><img alt="Print report" src="../../../Images/icons/Print.png" /></div>
    </div>
    </form>
</body>
</html>
