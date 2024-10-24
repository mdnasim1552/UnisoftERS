<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Templates/Unisoft.master" CodeBehind="ExtentManagement.aspx.vb" Inherits="UnisoftERS.ExtentManagement" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContentPlaceHolder" runat="server">
     <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        thead th { position: sticky; top: 0; }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="LeftPaneContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
     <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
    <div style="height:750px; overflow:auto">
        <asp:Repeater ID="rptExtentConfig" runat="server" OnItemCommand="rptExtentConfig_ItemCommand">
            <HeaderTemplate>
                <table cellpadding="5" cellspacing="5">
                    <thead>
                        <tr>
                             <th>Description</th>
                            <th>National Data Set</th>
                            <th>Colon</th>
                            <th>OGD</th>
                            <th>Flexi</th>
                            <th>ERCP</th>
                            <th>EUS OGD</th>
                            <th>EUS HPB</th>
                            <th>ENT ANT</th>
                            <th>ENT Retro</th>
                            <th>Proct</th>
                        </tr>
                    </thead>
                    <tbody>
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td><asp:HiddenField ID="ExtentIdHiddenField" runat="server" Value='<%#Eval("UniqueId") %>' /><telerik:RadTextBox ID="DescriptionRadTextBox" runat="server" Text='<%# Eval("Description") %>' /></td>
                    <td class="ned_term_td"><telerik:RadTextBox ID="NEDTermRadTextBox" runat="server" Enabled="false" Text='<%# Eval("NEDTerm") %>' /></td>
                    <td>
                        <asp:CheckBox ID="chkColon" runat="server" /></td>
                    <td>
                        <asp:CheckBox ID="chkOGD" runat="server" /></td>
                    <td>
                        <asp:CheckBox ID="chkFlexi" runat="server" /></td>
                    <td>
                        <asp:CheckBox ID="chkERCP" runat="server" /></td>
                    <td>
                        <asp:CheckBox ID="chkEUSOGD" runat="server" /></td>
                    <td>
                        <asp:CheckBox ID="chkEUSHPB" runat="server" /></td>
                    <td>
                        <asp:CheckBox ID="chkENTANT" runat="server" /></td>
                    <td>
                        <asp:CheckBox ID="chkENTRetro" runat="server" /></td>
                    <td>
                        <asp:CheckBox ID="chkProct" runat="server" /></td>
                    <td><telerik:RadButton ID="SaveExtentRadButton" runat="server" Text="Save" CommandName="Save" CommandArgument='<%#Eval("UniqueId") %>' />
                        </td>
                </tr>
            </ItemTemplate>
            <FooterTemplate>
                </tbody>
            </table>
            </FooterTemplate>
        </asp:Repeater>
    </div>
</asp:Content>
