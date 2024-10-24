<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="EmailSettings.aspx.vb" Inherits="UnisoftERS.Products_Options_EmailSettings" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Configure Print Reports</title>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/raphael-min.js"></script>
    <script type="text/javascript" src="../../Scripts/raphael.export.js"></script>
    <script type="text/javascript" src="../../Scripts/diagramReport.js"></script>
    <script type="text/javascript" src="../../Scripts/canvg.js"></script>

    <style type="text/css">
        .PanelContentDiv {
            max-height: 320px;
            overflow-y: auto;
            overflow-x: hidden;
        }

        .PanelItemHeading {
            margin-left: 5px;
            padding-left: 5px;
            padding-right: 5px;
            color: #4888a2 !important;
            font-weight: bold;
        }

        .PatientFriendlyTextBoxCell {
            padding-left: 20px;
        }

        .sysFieldset {
            width: 80%;
        }

        /*.rtsLevel span {
    background-color: red;

    background:url(../../Images/bg_blue.png) repeat-x 0 100%  !important;
}

 /*.rtsLevel {
    background-color: #9ab5c1;
    width: 80px;
    height: 70px;
    border-right: 1px solid #FFF;
    text-align: center;
    vertical-align: middle;
}*/
        /*.rtsSelected, .rtsSelected span
        {
           background:url(../../Images/bgHeader.png) repeat-x 0 100%  !important;
           background-color: red !important;
           text-align: center;
        }*/
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
            <script type="text/javascript">
                //var documentUrl = document.URL;

                $(window).on('load', function () {
                    //TogglePrintButton();
                    ToggleOtherTextBox();
                    $("#HeadingComboBox").change(function () {
                        ToggleOtherTextBox();
                    });
                });

                <%--function PrintReports() {
                    GetDiagramScript();
                }

                function GetDiagramScript() {
                    $.ajax({
                        type: "POST",
                        url: documentUrl.slice(0, docURL.indexOf("/Products/")) + "/Products/Common/PrintReport.aspx/GenerateDiagram",
                        data: "{}",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: GetDiagramScriptSuccess,
                        error: function (jqXHR, textStatus, data) {
                            //var vars = jqXHR.responseText.split("&"); 
                            //alert(vars[0]); 
                            alert("Unknown error occured while generating report. Please contact Unisoft helpdesk.");
                        }
                    });
                }

                function GetDiagramScriptSuccess(responseText) {
                    $("#mydiagramDiv").html(responseText.d);

                    $("#mydiagramDiv").find("script").each(function (i) {
                        var svgXml = eval($(this).text());

                        if (svgXml == undefined) {
                            svgXml = "No diagram";
                        }
                        canvg('myCanvas', svgXml, { renderCallback: GetImgDataUri, ignoreMouse: true, ignoreAnimation: true });
                    });
                }

                function GetImgDataUri() {
                    var diaguri = document.getElementById('myCanvas').toDataURL("image/png");

                    var jsondata =
                    {
                        base64String: diaguri
                    };

                    $.ajax({
                        type: "POST",
                        url: documentUrl.slice(0, docURL.indexOf("/Products/")) + "/Products/Common/PrintReport.aspx/SaveImgBase64",
                        data: JSON.stringify(jsondata),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (result) {
                            OpenPrintWindow();
                        },
                        error: function (jqXHR, textStatus, data) {
                            //var vars = jqXHR.responseText.split("&");
                            //alert(vars[0]);
                            alert("Unknown error occured while generating report. Please contact Unisoft helpdesk.");
                        }
                    });
                }

                function OpenPrintWindow() {
                    url = "<%= ResolveUrl("~/Products/Common/PrintReport.aspx") %>";
                    parent.ShowPrintWindow(url);
                    return false;
                }

                function TogglePrintButton() {
                    var btn = $find("<%= PrintButton.ClientID%>");
                    if ($("#<%= PrintGPReportCheckBox.ClientID%>").is(":checked") == true
                        || $("#<%= PrintPhotosCheckBox.ClientID%>").is(":checked") == true
                        || $("#<%= PrintPatientCopyCheckBox.ClientID%>").is(":checked") == true
                        || $("#<%= PrintLabRequestCheckBox.ClientID%>").is(":checked") == true) {
                        btn.set_enabled(true);
                    }
                    if ($("#<%= PrintGPReportCheckBox.ClientID%>").is(":checked") == false
                        && $("#<%= PrintPhotosCheckBox.ClientID%>").is(":checked") == false
                        && $("#<%= PrintPatientCopyCheckBox.ClientID%>").is(":checked") == false
                        && $("#<%= PrintLabRequestCheckBox.ClientID%>").is(":checked") == false) {
                        btn.set_enabled(false);
                    }
                }--%>

               <%-- function collapseItem(text) {
                    var panelBar = $find("<%= RadPanelBar1.ClientID %>");
                    var item = panelBar._findItemByText(text);
                    if (item) {
                        item.collapse();
                    }
                    else {
                        alert("Item with text '" + text + "' not found.");
                    }
                }--%>

                function OnClientItemClicking(sender, args) {
                    //if (args.get_domEvent().target.type == "checkbox") {
                    //    args.set_cancel(true);
                    //}
                    //if (args.get_item().get_text() == "Item1") {
                    //    args.get_item().set_expanded(false);
                    //}
                    if (args.get_domEvent().target.id.indexOf('CheckBox') >= 0) {
                        //TogglePrintButton();
                        //args.set_cancel(true);
                        args.get_item().set_expanded(false);
                    }
                }

                function ToggleOtherTextBox() {
                    var selectedval = combo.get_selectedItem().get_value();
                    txtbox.set_visible(selectedval == 5);
                }

                window.StopPropagation = function (e) {
                    e.cancelBubble = true;
                    if (e.stopPropagation) {
                        e.stopPropagation();
                    }
                };

                function ToggleTRs(sender, args) {
                    alert(1);
                }
            </script>
        </telerik:RadCodeBlock>
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ControlsRadPane" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />
    
        <telerik:RadAjaxManager ID="PrintOptionsAjaxManager" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="AddEntryButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="AdditionalListView" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="OperatingHospitalsRadComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadMultiPage1" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <div class="optionsHeading" id="PrintOptionsHeading" runat="server">Edit Email Settings</div>

        <%--<div id="HospitalFilterDiv" runat="server" class="optionsBodyText" style="margin: 10px;">
            Operating Hospital:&nbsp;<telerik:RadComboBox ID="OperatingHospitalsRadComboBox" CssClass="filterDDL" runat="server" Width="270px" AutoPostBack="true" OnSelectedIndexChanged="OperatingHospitalsRadComboBox_SelectedIndexChanged" />
        </div>--%>

        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="900px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="550px">
                <div style="margin: 0px 10px;">
                    <div style="margin-top: 10px;"></div>
                    <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" ReorderTabsOnSelect="true" Skin="MetroTouch" RenderMode="Lightweight"
                        Orientation="HorizontalTop">
                        <Tabs>
                            <telerik:RadTab Text="Email Settings" Value="1" Font-Bold="false" Selected="true" PageViewID="EmailSettingsRadPageView" />
                            <telerik:RadTab Text="Email Builder" Value="2" Font-Bold="false" PageViewID="EmailBuilderRadPageView" Visible="True"/>
                        </Tabs>
                    </telerik:RadTabStrip>
                    <telerik:RadMultiPage ID="RadMultiPage1" runat="server">
                        <telerik:RadPageView ID="EmailSettingsRadPageView" runat="server" Selected="true">
                            <div style="padding-bottom: 10px; padding-top: 10px;" class="ConfigureBg">
                                <table id="ControlsTable" runat="server" class="optionsBodyText" style="margin-top: 5px; margin-left: 5px;" width="95%" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td valign="top" style="border-right: 1px dashed #c2d2e2; width: 350px;">
                                            <table>
                                                <tr>
                                                    <td>Delivery Method:</td>
                                                    <td>
                                                        <asp:TextBox ID="EmailSettingsDeliveryMethodTextBox" runat="server"/>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Use Default Credentials:</td>
                                                    <td>
                                                        <asp:CheckBox ID="EmailSettingsUseDefaultCredentialsCheckBox" runat="server"/>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Port No:</td>
                                                    <td>
                                                        <asp:TextBox ID="EmailSettingsPortNoTextBox" runat="server"/>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td valign="top">Enable SSL:</td>
                                                    <td>
                                                        <asp:CheckBox ID="EmailSettingsEnableSslCheckBox" runat="server"/>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td valign="top">Host:</td>
                                                    <td>
                                                        <asp:TextBox ID="EmailSettingsHostTextBox" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td valign="top">From Address:</td>
                                                    <td>
                                                        <asp:TextBox ID="EmailSettingsFromAddress" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td valign="top">From Name:</td>
                                                    <td>
                                                        <asp:TextBox ID="EmailSettingsFromName" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td valign="top">From Password:</td>
                                                    <td>
                                                        <asp:TextBox ID="EmailSettingsFromPassword" runat="server" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td style="width: 20px;"></td>
                                        
                                    </tr>
                                </table>
                            </div>
                            <%--</fieldset>--%>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="EmailBuilderRadPageView" runat="server">
                            <div style="padding-bottom: 10px; padding-top: 10px;" class="ConfigureBg">
                                <table id="Table1" runat="server" class="optionsBodyText" style="margin-top: 5px; margin-left: 5px;" width="95%" cellpadding="0" cellspacing="0">
                                    <%--<tr>
                                        <td>From:</td>
                                        <td>
                                            <asp:TextBox ID="SendFromTextBox" runat="server"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>To:</td>
                                        <td>
                                            <asp:TextBox ID="SendToTextBox" runat="server"/>
                                        </td>
                                    </tr>--%>
                                    <tr>
                                        <td>Subject:</td>
                                        <td>
                                            <asp:TextBox ID="SendSubjectTextBox" runat="server" Width="400"/>
                                        </td>
                                    </tr>
                                    <br />
                                    <tr>
                                        <td>Body:</td>
                                        <td>
                                            <asp:TextBox ID="SendMessageTextBox" runat="server" TextMode="MultiLine" Height="150" Width="400"/>
                                        </td>
                                    </tr>
                                    <%--<tr>
                                        <td></td>
                                        <td>
                                            <asp:Button ID="SendEmailButton" Text="Send" runat="server" OnClick="SendEmail"/>
                                        </td>
                                    </tr>--%>
                                </table>
                            </div>
                        </telerik:RadPageView>
                    </telerik:RadMultiPage>
                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="43px">
                <div id="cmdButtons" style="height: 10px; margin-top: 10px; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="EmailSettingsSaveButton" runat="server" Text="Save" Skin="Web20" Visible="True" Icon-PrimaryIconCssClass="telerikSaveButton" OnClick="SaveEmailSettings_Click"/>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" Visible="True" Icon-PrimaryIconCssClass="telerikCancelButton" />
                    <%--<telerik:RadButton ID="CloseButton" runat="server" Text="Close" Skin="Web20" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />--%>
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
    </form>
</body>
</html>
