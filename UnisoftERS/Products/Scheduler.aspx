<%@ Page Language="VB" MasterPageFile="~/Templates/Unisoft.master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Scheduler" Codebehind="Scheduler.aspx.vb" %>

<%--<%@ Register Src="~/UserControls/PatientsList.ascx" TagPrefix="unisoft" TagName="patientslist"  %>--%>
<%@ Register Src="~/UserControls/AppScheduler.ascx" TagPrefix="unisoft" TagName="scheduler"  %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">
    <title></title>

    <style type="text/css">

    </style>

    
</asp:Content>

<%--<asp:Content ID="LeftPaneContent" runat="server" ContentPlaceHolderID="LeftPaneContentPlaceHolder">

    <telerik:RadCodeBlock ID="RadCodeBlock2" runat="server">
    <script type="text/javascript">

    </script>
    </telerik:RadCodeBlock>

    <asp:ScriptManagerProxy ID="ScriptManagerProxy1" runat="server" >
      <Scripts>
      </Scripts>
    </asp:ScriptManagerProxy>

    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
    <unisoft:patientslist runat="server" ID ="patientslist" />

</asp:Content>--%>


<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="frameNewProc" Skin="Web20" />
    <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="divPrintInitiate" Skin="Web20" />

     <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server"  />
    <div id="divMultiPageSystem">
        <telerik:RadMultiPage runat="server" ID="MainPage">           
            <telerik:RadPageView runat="server" ID="LandingPageView" Selected="true"> 
                <asp:Label class="divWelcomeMessage" ID="lblWelcomeMessage" runat="server" Text="List schedules " style="margin-left: 15px;" /> 

                    <unisoft:scheduler runat="server" id="scheduler"  />      
            </telerik:RadPageView>           
        </telerik:RadMultiPage>


    </div>

    
    <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
        <script type="text/javascript">


            $(window).load(function () {

            });

        </script>
    </telerik:RadCodeBlock>
           

</asp:Content>

