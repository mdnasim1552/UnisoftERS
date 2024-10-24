<%@ Page Language="VB" MasterPageFile="~/Templates/Scheduler.master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Scheduler" CodeBehind="Scheduler.aspx.vb" %>

<%--<%@ Register Src="~/UserControls/PatientsList.ascx" TagPrefix="unisoft" TagName="patientslist"  %>--%>
<%@ Register Src="~/UserControls/AppScheduler.ascx" TagPrefix="unisoft" TagName="scheduler" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">
    <title></title>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
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
                <asp:Label class="divWelcomeMessage" ID="lblWelcomeMessage" runat="server" Text="List schedules " Style="margin-left: 15px;" />
                
                <unisoft:scheduler runat="server" ID="scheduler" />
            </telerik:RadPageView>
        </telerik:RadMultiPage>
    </div>


    <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
        <script type="text/javascript">


            $(window).on('load', function () {
                 window.setInterval(function () {
                    $.ajax(
                        {
                            type: "POST",
                            url: "Scheduler.aspx/ReleaseReservedSlots",
                            dataType: "json",
                            contentType: "application/json; charset=utf-8"
                        })  
                }, 60000 );
            });


        </script>
    </telerik:RadCodeBlock>


</asp:Content>

