<%@ Page Language="vb" AutoEventWireup="false"   MasterPageFile="~/Templates/Scheduler.master" CodeBehind="WaitingList.aspx.vb" Inherits="UnisoftERS.WaitingList" %>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">

    <title>Waiting List</title>
    <script type="text/javascript" src="../../Scripts/global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
    </style>
</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="frameNewProc" Skin="Metro" />
    <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="divPrintInitiate" Skin="Metro" />
    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />
    <div id="divMultiPageSystem">
        <telerik:RadMultiPage runat="server" ID="MainPage">
            <telerik:RadPageView runat="server" ID="LandingPageView" Selected="true">
                <asp:Label class="divWelcomeMessage" ID="lblWelcomeMessage" runat="server" Text="Waiting List" Style="margin-left: 14px;" />
                
            </telerik:RadPageView>
        </telerik:RadMultiPage>
    </div>
</asp:Content>