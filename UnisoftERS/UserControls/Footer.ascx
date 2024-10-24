<%@ Control Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.UserControls_Footer" Codebehind="Footer.ascx.vb" %>

<div>
    <table class="UniTableFooter" border="0" cellpadding="1" cellspacing="0" style="width: 100%; height: 20px; margin-left: 5px">
<%--        <tr align="center">
            <td>
                <asp:Label ID="lblUserID" runat="server" Text="" />
                &nbsp;|&nbsp;
                <asp:Label ID="lblPageID" runat="server" Text="" />
                &nbsp;|&nbsp;
                <asp:Label ID="LoggedOnAtLabel" runat="server" />
            </td>
        </tr>--%>
        <tr align="center">
            <td>
<%--                <asp:HyperLink ID="HomeHyperLink" runat="server" Text="Home" NavigateUrl="~/Products/Default.aspx"></asp:HyperLink>
                &nbsp;|&nbsp;
                <asp:HyperLink ID="HelpHyperLink" runat="server" Text="Help" NavigateUrl="~/Products/Default.aspx"></asp:HyperLink>
                &nbsp;|&nbsp;
                <asp:HyperLink ID="DisclaimerHyperLink" runat="server" Text="Disclaimer" NavigateUrl="~/Products/Default.aspx"></asp:HyperLink>
                &nbsp;|&nbsp;--%>
                <asp:Label ID="lblCompany" runat="server" Text="" />
            </td>
        </tr>
    </table>
</div>
