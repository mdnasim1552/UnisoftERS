<%@ Page Language="VB" MasterPageFile="~/Templates/Unisoft.master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Default" ClassName="DefaultPage" CodeBehind="Default.aspx.vb" %>

<%@ Register TagPrefix="unisoft" TagName="Diagram" Src="~/UserControls/diagram.ascx" %>
<%@ Register Src="~/UserControls/landingpage.ascx" TagPrefix="unisoft" TagName="landingpage" %>
<%@ Register Src="~/UserControls/patientview.ascx" TagPrefix="unisoft" TagName="patientview" %>
<%@ Register Src="~/UserControls/dashboard.ascx" TagPrefix="unisoft" TagName="dashboard" %>
<%@ Register Src="~/UserControls/PatientsList.ascx" TagPrefix="unisoft" TagName="patientslist" %>
<%@ Register Src="~/UserControls/PatientSearchResults.ascx" TagPrefix="unisoft" TagName="patientresults" %>
<%@ Register Src="~/UserControls/StartupConfiguration.ascx" TagPrefix="unisoft" TagName="startupconfiguration" %>
<%@ Register Src="~/UserControls/Worklist.ascx" TagPrefix="unisoft" TagName="worklist" %>


<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">
    <title></title>

    <link href="../Styles/contextmenu.css" rel="stylesheet" />
    <link href="../Scripts/qTip/jquery.qtip.css" rel="stylesheet" />

    <style type="text/css">
        .homeview > div {
            padding-top: 15px;
        }

        .rgRow td {
            border-bottom: 1px solid #ededed !important;
        }

        .rtileIconImage {
            margin-top: 10px !important;
            height: 80px !important;
            width: 90px !important;
        }

        .rtileTitle {
            font-size: 11px !important;
            width: 100% !important;
        }

        .rigThumbnailsList {
            /*border: 2px solid red;*/
            background-color: white !important;
        }

            .rigThumbnailsList li {
                /*border: 2px solid blue;*/
                background-color: white !important;
            }

            .rigThumbnailsList img {
                opacity: 0.9 !important;
            }

            .rigThumbnailsList a:hover img {
                opacity: 1 !important;
            }

            .rigThumbnailsList .rigThumbnailActive a img {
                opacity: 0.9 !important;
            }

        .rigThumbnailActive {
            width: 150px;
            height: 120px;
        }

        .selected-tab-style {
            cursor: default !important;
        }

        .unselected-tab-style {
            cursor: pointer !important;
        }

        .RadNotificationError {
            padding-right: 150px;
            margin-left: 100px;
            padding-bottom: 200px;
            border-bottom-width: 20px;
            font-size: 24px;
            color: blue;
            width: 500px;
        }



        .diagram-buttons {
            color: #050;
            font: bold 84% 'trebuchet ms',helvetica,sans-serif;
            font-size: 8pt;
            background-color: #fed;
            border: 1px solid;
            border-color: #696 #363 #363 #696;
        }

        a.sitesummary {
            color: inherit;
        }

            a.sitesummary:link {
                text-decoration: none;
                color: inherit;
            }

            a.sitesummary:hover {
                text-decoration: underline;
                color: blue;
            }

        .tooltip-myStyle {
            background-color: #505050;
            border-color: #303030;
            color: #f3f3f3;
            font-size: 13px;
            padding: 3px;
            font-family: "Helvetica Neue", "Lucida Grande", "Segoe UI", Arial, Helvetica, Verdana, sans-serif;
        }

        .helpTipStyle {
            /*background:#CAED9E; 
	        border-color: #90D93F;*/
            border-color: #e6e600;
            background: linear-gradient(white, #ffffcc); /*#E4E5F0*/
            color: black;
            padding: 3px;
            font: 1em/1.4 "Helvetica Neue", "Lucida Grande", "Segoe UI", Arial, Helvetica, Verdana, sans-serif;
            margin-top: .5em;
            border-radius: 10px;
            box-shadow: 2px 2px 13px 2px #808080;
        }

        .RadGrid .rgHoveredRow {
            background: #e0ebeb !important;
        }

        .RadFirstPage .rgPageFirst, .RadFirstPage .rgPagePrev {
            opacity: 0.4;
        }

        .RadLastPage .rgPageNext, .RadLastPage .rgPageLast {
            opacity: 0.4;
        }

        .MasterClass {
            font: 0.9em 'Segoe UI', Arial, sans-serif !important;
        }

            .MasterClass .rgCaption {
                /*color: #026BB9;*/
                background-color: #f9f9f9;
                border-bottom: 1px solid #c2d2e2;
                font: 1.3em 'Segoe UI', Arial, sans-serif;
                text-align: left;
                color: #4888a2;
                padding: 3px 0px 3px 8px;
            }

        .rgHeaderDiv {
            margin-right: 0 !important;
            padding-right: 0px !important;
            background-color: #f9fafb !important;
        }

        div.RadGrid .rgRow,
        div.RadGrid .rgAltRow,
        div.RadGrid th.rgResizeCol,
        div.RadGrid .rgRow td,
        div.RadGrid .rgAltRow td,
        div.RadGrid .rgFilterRow td,
        div.RadGrid .rgEditRow td,
        div.RadGrid .rgFooter td {
            border-left-width: 1px !important;
            border-bottom-width: 0 !important;
            border-top-width: 0 !important;
        }

        div.RadGrid .rgHoveredRow {
            color: teal !important;
            background: #e8eef4 !important;
        }

        th.rgHeader {
            background-color: #ecf2f7 !important;
        }

        .rmpView {
            height: 100% !important;
        }

        .RadFormDecorator {
            height: 100% !important;
        }
    </style>


</asp:Content>

<asp:Content ID="LeftPaneContent" runat="server" ContentPlaceHolderID="LeftPaneContentPlaceHolder">
    <telerik:RadCodeBlock ID="RadCodeBlock2" runat="server">
        <script type="text/javascript">
   

            function closeDialog() {
                $find("<%=MessageRadWindow.ClientID%>").close();
            };
        </script>
    </telerik:RadCodeBlock>

    <asp:ScriptManagerProxy ID="ScriptManagerProxy1" runat="server">
        <Scripts>
            <%--<asp:ScriptReference Path="../Scripts/jquery-3.6.3.min.js" />--%>
            <asp:ScriptReference Path="../Scripts/jquery-ui.min.js" />
            <asp:ScriptReference Path="../Scripts/raphael-min.js" />
            <asp:ScriptReference Path="../Scripts/diagramReport.js" />
            <asp:ScriptReference Path="../Scripts/contextmenu.js" />
            <asp:ScriptReference Path="../Scripts/raphael.export.js" />
            <asp:ScriptReference Path="../Scripts/rgbcolor.js" />
            <asp:ScriptReference Path="../Scripts/canvg.js" />
            <asp:ScriptReference Path="../Scripts/qTip/jquery.qtip.js" />
        </Scripts>
    </asp:ScriptManagerProxy>
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

    <telerik:RadWindowManager ID="LoginRadWindowManager" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move, Resize" Skin="Metro" EnableShadow="true" Modal="true">
        <Windows>
            <telerik:RadWindow ID="radWindow" runat="server" />
        </Windows>
        <Windows>
            <telerik:RadWindow ID="MessageRadWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" Width="700px" Height="250px" VisibleStatusbar="false" VisibleOnPageLoad="false" Visible="false" Title="Account Inactive" BackColor="#ffffcc">
                <ContentTemplate>
                    <table width="100%">
                        <tr>
                            <td style="text-align: center; padding: 20px;">
                                <asp:Label ID="lblMessageText" runat="server" Font-Size="Large" />
                            </td>
                        </tr>
                        <tr>
                            <td style="padding: 10px; text-align: center;">
                                <telerik:RadButton ID="OkRadButton" runat="server" Text="OK" Skin="Windows7" ButtonType="SkinnedButton" AutoPostBack="false" OnClientClicked="closeDialog" Width="100" Height="30" Font-Size="Large" />
                            </td>
                        </tr>
                    </table>
                </ContentTemplate>
            </telerik:RadWindow>
        </Windows>
    </telerik:RadWindowManager>

    <unisoft:patientslist runat="server" ID="patientslist" />
    <div style="margin: -3px -2px; display: none;">
        <div class="text12">
            Filter options
        </div>
        <div id="filterOptions" style="margin-left: 12px; color: #000000;">
            <div>
                <asp:RadioButton ID="optShowLast" GroupName="optFilter" runat="server" Text="Last" Checked="true" AutoPostBack="true" />
                <telerik:RadNumericTextBox ID="txtRecordLimit" CssClass="spinAlign" runat="server" Skin="Windows7" Width="45" MinValue="10" MaxValue="100" Value="10" NumberFormat-DecimalDigits="0" />
                <asp:Label ID="Label1" runat="server" Text="patients" />
            </div>
            <div style="margin-top: 2px;">
                <asp:RadioButton ID="optShowToday" GroupName="optFilter" runat="server" Text="Todays patients" AutoPostBack="true" />
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="frameNewProc" Skin="Web20" />
    <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="divPrintInitiate" Skin="Web20" />
    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" IsSticky="true" Style="position: absolute; top: 0; left: 0; height: 100%; width: 100%;">
    </telerik:RadAjaxLoadingPanel>
    <%--<telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" />--%>
    <div id="divMultiPageSystem" runat="server">
        <telerik:RadMultiPage runat="server" ID="MainPage">
            <telerik:RadPageView runat="server" ID="LandingPageView" Selected="true" Style="padding-left: 15px;">
                <asp:Label class="divWelcomeMessage" ID="lblWelcomeMessage" runat="server" Text="Welcome " />


                <telerik:RadTabStrip ID="MainRadTabStrip" runat="server" MultiPageID="RadMultiPage1" ReorderTabsOnSelect="true" Skin="Metro" RenderMode="Lightweight"
                    Orientation="HorizontalTop">
                    <Tabs>
                        <telerik:RadTab Text="Dashboard" Value="1" Font-Bold="false" Selected="true" PageViewID="RadPageView0" />
                        <telerik:RadTab Text="Patient Results" Value="2" Font-Bold="false" PageViewID="RadPageView1" Visible="false" />
                        <telerik:RadTab Text="Worklist" Value="3" Font-Bold="false" PageViewID="RadPageView2" />
                        <telerik:RadTab Text="My Preferences" Value="4" Font-Bold="false" PageViewID="RadPageView3" />
                    </Tabs>
                </telerik:RadTabStrip>
                <telerik:RadMultiPage ID="RadMultiPage1" runat="server" CssClass="homeview">
                    <telerik:RadPageView ID="RadPageView0" runat="server" Selected="true">
                        <div id="LandingDiv" runat="server">
                            <unisoft:dashboard runat="server" ID="dashboard" Visible="false" />
                            <unisoft:landingpage runat="server" ID="landingpage" />
                        </div>
                    </telerik:RadPageView>
                    <telerik:RadPageView ID="RadPageView1" runat="server">
                        <unisoft:patientresults ID="PatientResultsControl" runat="server" />
                    </telerik:RadPageView>
                    <telerik:RadPageView ID="RadPageView2" runat="server">
                        <unisoft:worklist ID="WorklistControl" runat="server" />
                    </telerik:RadPageView>
                    <telerik:RadPageView ID="RadPageView3" runat="server">
                        <unisoft:startupconfiguration ID="StartupConfigurationControl" runat="server" />
                    </telerik:RadPageView>
                </telerik:RadMultiPage>
            </telerik:RadPageView>
            <telerik:RadPageView runat="server" ID="PatientPageView">

                <unisoft:patientview runat="server" ID="patientview" />
            </telerik:RadPageView>
        </telerik:RadMultiPage>


    </div>


    <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
        <script type="text/javascript">
            //var documentUrl = document.URL;

            $(window).on('load', function () {
                // SearchTabSelected();
                var refreshTime = 10 * 60 * 1000; // in milliseconds, so 10 minutes
                window.setInterval(function () {
                    $.ajax(
                        {
                            type: "POST",
                            url: "Default.aspx/KeepAlive",
                            dataType: "json",
                            contentType: "application/json; charset=utf-8"
                        })
                }, refreshTime);

            });

            function openWindow() {
                var wnd = window.radopen("default2.aspx", null);
                wnd.setSize(400, 400);
                return false;
            }

            function ApplyTooltip(descr) {
                $(".rigThumbnailsBox img[alt='" + descr + "']").qtip({
                    content:
                        descr
                    ,
                    style: {
                        classes: 'tooltip-myStyle'
                    }
                })
            }

            function OnClientTabUnSelected(sender, args) {
                //accessing the last selected tab and giving the default styling
                args.get_tab().set_cssClass("unselected-tab-style");
            }

            function showContentForIE(wnd) {
                if ($telerik.isIE)
                    wnd.view.onUrlChanged();
            }

            function replaceAll(find, replace, str) {
                return str.replace(new RegExp(find, 'g'), replace);
            }

            function CallPrint() {
                var prtContent = '<table style="width:780px;font: 1.0em \'Segoe UI\', Arial, sans-serif;"><tr><td>';
                prtContent += '<div style="text-align:center; border-bottom:1px solid gray;">General Hospital<br/>Report subheading<br/>GASTROSCOPY REPORT</div>';
                prtContent += '</td></tr><tr><td style="width:780px;">';
                prtContent += replaceAll('class="reportHeader"', 'style="color: #0072c6;"', document.getElementById('divReport').innerHTML);
                prtContent += '</td></tr><tr><td>';
                prtContent += document.getElementById('divReportImages').innerHTML;
                prtContent += '</td></tr></table>'
                //alert(prtContent);
                var WinPrint = window.open('', '', 'left=0,top=0,toolbar=0,scrollbars=0,status=0,');
                WinPrint.document.write(prtContent);
                WinPrint.document.close();
                WinPrint.focus();
                WinPrint.print();
                WinPrint.close();
                //prtContent.innerHTML = strOldOne;
            }

        </script>
    </telerik:RadCodeBlock>


</asp:Content>

