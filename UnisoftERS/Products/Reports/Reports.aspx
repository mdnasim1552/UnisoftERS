<%@ Page Title="" Language="VB" MasterPageFile="~/Templates/Unisoft.Master" AutoEventWireup="true" Inherits="UnisoftERS.Products_Reports_Report" Codebehind="Reports.aspx.vb" Debug="true" ViewStateMode="Disabled" %>
<%@ MasterType VirtualPath="~/Templates/Unisoft.Master" %>
<%@ Register Src="~/UserControls/landingpage.ascx" TagPrefix="uc1" TagName="landingpage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContentPlaceHolder" runat="server">
    <link href="../../Styles/Reporting.css" rel="stylesheet" />
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/Reports.js"></script>
<telerik:RadScriptBlock runat="server">

<script type="text/javascript" id="telerikClientEvents1">
    var multipage;
    var globalSelectedIndex;

    function ValidatingDates(sender, args) {
        alert('function ValidatingDates(sender, args) {');
        var dFrom = $find("#RDPFrom_dateInput").get_dateInput().get_selectedDate().format("yyyy/MM/dd");
        var dTo = $find("#RDPTo_dateInput").get_dateInput().get_selectedDate().format("yyyy/MM/dd");
        var dateFrom = new Date(dFrom);
        var dateTo = new Date(dTo);
        //if (dateFrom <= dateTo) {
        //    for (var i = 0; i < GRSArray.length; i++) {
        //        changeTabStatus(i);
        //    }
        //} else {
        //    args.set_cancel(true);
        //}
    }

    function ResolveUrl(url) {
        if (url.indexOf("~/") == 0) {
            url = baseUrl + url.substring(2);
        }
        return url;
    }

    function SetUrl(node) {
        //### who am i?
    }


    //### This will show the Report in the Right side Main Div.. <div id="ReportPreviewContainerDiv">
    function ClientNodeClickedR(sender, eventArgs) {
        var node = eventArgs.get_node();
        var selectedReportUrl = node.get_value();
        console.log("Selected report:  " + selectedReportUrl);
        loadDoc(selectedReportUrl);
        //document.getElementsByClassName("ReportPreviewContainerDiv")
        var element = document.getElementsByClassName("aspNetHidden");
        element.remove();
        //element.parentNode.removeChild("");

        $('.aspNetHidden', this).remove();
        $('.aspNetHidden').remove();
        console.log(".aspNetHidden).remove()");

/*
        if (node.get_nodes().get_count() == 0) {
            SetUrl(node);
            if (node.check() == true) {
                node.uncheck();
            } else {
                node.check();
            }
            console.log(node.get_value());
        }
        else {
            node.expand();
            SetUrl(node.get_allNodes()[0]);
            node.get_allNodes()[0].select();
        }
        */
    }

    //##### This will load the ASPX webpage in the Div->'ReportPreviewContainerDiv', and user can use it like a UC!
    function loadDoc(filename) {
        var xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = function () {
            if (xhttp.readyState == 4 && xhttp.status == 200) {
                document.getElementById("ReportPreviewContainerDiv").innerHTML = xhttp.responseText;
            }
        };
        xhttp.open("GET", filename, true);
        xhttp.send();
    }

</script>
</telerik:RadScriptBlock> 

</asp:Content>
<asp:Content ID="LeftPaneContent" ContentPlaceHolderID="LeftPaneContentPlaceHolder" runat="server">
<%--    <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="LeftTreePane" Skin="Web20" />--%>
    <div id="LeftTreePane" class="treeListBorder" style="margin-top: -5px;">
        <telerik:RadTreeView ID="LeftMenuTreeView" runat="server" CheckChildNodes="True" TriStateCheckBoxes="False" CheckBoxes="True"  Skin="Default" BackColor="#f2f9fc"  width="280px"  height="595px" CssClass="OptionsBackgroundPane" >
            <DataBindings>
                <telerik:RadTreeNodeBinding DataMember="Node" CssClass="class" ImageUrlField="ImageUrl" ToolTip="ToolTip" CssClassField="cssAttrib" CheckableField="enablecheckbox" Checked="False" Checkable="False" />
            </DataBindings>
        </telerik:RadTreeView>
    </div>
</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
    <telerik:RadSkinManager ID="RadSkinManager1" runat="server">
    </telerik:RadSkinManager>
    <telerik:RadFormDecorator ID="MultiPageSystemDecorator" runat="server" DecoratedControls="All" DecorationZoneID="ReportPreviewContainerDiv" Skin="Web20" />
    <div id="ReportPreviewContainerDiv" style="padding:0; margin:0;">
        <asp:Label class="divWelcomeMessage" ID="lblWelcomeMessage" runat="server" Text="Reports " style="margin-left: 15px;" /> 
        <%--<uc1:landingpage runat="server" ID="landingpage" />--%>
        <asp:PlaceHolder ID="UC_Container_Placeholder" runat="server" EnableViewState="False" ViewStateMode="Disabled" />
    </div>
    <%--<div id="rside" runat="server">
        <telerik:RadMultiPage ID="MainMultiPage" Runat="server" Height="650px">
            <telerik:RadPageView runat="server" ID="JAGGRS" Height="700px" Selected="true">
                <div class="" id="DeploySite" runat="server">
                    <div class="" id="ReportURL" runat="server">
                        <iframe src="JAGGRS.aspx" runat="server" class="if"></iframe>
                    </div>
                </div>
            </telerik:RadPageView>
            <telerik:RadPageView runat="server" ID="GRS" Height="700px" Selected="true">
                <div class="" id="Div1" runat="server">
                    <div class="" id="Div2" runat="server">
                        <iframe src="GRS.aspx" runat="server" class="if"></iframe>
                    </div>
                </div>
            </telerik:RadPageView>
            <telerik:RadPageView ID="BlankReports" runat="server" Height="700px">
                <div class="" runat="server">
                    <div class="" runat="server">
                        <iframe src="GRS1.aspx" runat="server" class="if"></iframe>
                        <iframe src="BlankReports.aspx" runat="server" class="if"></iframe>
                    </div>
                </div>
            </telerik:RadPageView>
            <telerik:RadPageView ID="ListAnalysis" runat="server" Height="700px">
                <div class="" runat="server">
                    <div class="" runat="server">
                        <iframe src="ListAnalysis.aspx" runat="server" class="if"></iframe>
                    </div>
                </div>
            </telerik:RadPageView>
        </telerik:RadMultiPage>
    </div>--%>

    <telerik:RadAjaxLoadingPanel ID="MyRadAjaxLoadingPanel1" runat="server" Skin="Metro">
    </telerik:RadAjaxLoadingPanel>
</asp:Content>

