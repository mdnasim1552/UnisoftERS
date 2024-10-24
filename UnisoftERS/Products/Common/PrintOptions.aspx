<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Common_PrintOptions" CodeBehind="PrintOptions.aspx.vb" EnableEventValidation="true" ValidateRequest="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

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
                    var combo = $find('<%=LabRequestHeadingComboBox.ClientID %>');
                    var txtbox = $find("<%= LabRequestOtherTextBox.ClientID %>");
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

                function onTreeLoad(sender, args) {
                    var treeView = sender;
                    var allNodes = treeView.get_allNodes();

                    for (var i = 0; i < allNodes.length; i++) {
                        var node = allNodes[i];
                        if (node.get_nodes().get_count() > 0) {
                            if (areAnyChildrenChecked(node)) {
                                node.expand();
                            } else {
                                node.collapse();
                            }
                        }
                    }
                }

                function NodeChecked(sender, args) {
                    var node = args.get_node();
                    var checked = node.get_checked();

                    if (checked) {
                        node.expand();
                    }

                    if (!areAnyChildrenChecked(node)) {
                        node.collapse();
                    }
                }

                function areAnyChildrenChecked(node) {
                    var children = node.get_nodes();
                    for (var i = 0; i < children.get_count(); i++) {
                        var childNode = children.getNode(i);
                        if (childNode.get_checked() || areAnyChildrenChecked(childNode)) {
                            return true;
                        }
                    }
                    return false;
                }
            </script>
        </telerik:RadCodeBlock>
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ControlsRadPane" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />

        <%--<div style="display: none" id="mydiagramDiv"></div>
        <canvas id="myCanvas" style="display: none;"></canvas>--%>

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

        <div class="optionsHeading" id="PrintOptionsHeading" runat="server">Print Settings</div>

        <div id="HospitalFilterDiv" runat="server" class="optionsBodyText" style="margin: 10px;">
            Operating Hospital:&nbsp;<telerik:RadComboBox ID="OperatingHospitalsRadComboBox" CssClass="filterDDL" runat="server" Width="270px" AutoPostBack="true" OnSelectedIndexChanged="OperatingHospitalsRadComboBox_SelectedIndexChanged" />
        </div>

        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="900px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="550px">
                <div style="margin: 0px 10px;">
                    <div style="margin-top: 10px;"></div>
                    <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" ReorderTabsOnSelect="true" Skin="MetroTouch" RenderMode="Lightweight"
                        Orientation="HorizontalTop">
                        <Tabs>
                            <telerik:RadTab Text="Report" Value="1" Font-Bold="false" Selected="true" PageViewID="RadPageView0" />
                            <telerik:RadTab Text="Photos Report" Value="2" Font-Bold="false" PageViewID="RadPageView1" />
                            <telerik:RadTab Text="Patient Friendly Report" Value="3" Font-Bold="false" PageViewID="RadPageView2" />
                            <telerik:RadTab Text="Lab Request Report" Value="4" Font-Bold="false" PageViewID="RadPageView3" />
                        </Tabs>
                    </telerik:RadTabStrip>
                    <telerik:RadMultiPage ID="RadMultiPage1" runat="server">
                        <telerik:RadPageView ID="RadPageView0" runat="server" Selected="true">
                            <%--<fieldset class="sysFieldset">--%>
                            <div style="padding-bottom: 10px; padding-top: 10px;" class="ConfigureBg">
                                <fieldset class="sysFieldset" style="display: none;">
                                    <legend><b>Print Type</b></legend>
                                    <asp:RadioButtonList ID="PrintTypeButtonList" runat="server"
                                        CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rbl">
                                        <asp:ListItem Value="0" Text="Pdf"></asp:ListItem>
                                        <asp:ListItem Value="1" Text="Web"></asp:ListItem>
                                    </asp:RadioButtonList>
                                </fieldset>
                                <table id="ControlsTable" runat="server" class="optionsBodyText" style="margin-top: 5px; margin-left: 5px;" width="95%" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td style="padding-bottom: 5px;">Default number of copies : 
                                                        <telerik:RadNumericTextBox ID="GPReportDefaultNumberOfCopiesRadNumericTextBox" runat="server"
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="1"
                                                            MaxLength="3"
                                                            MaxValue="50">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding-bottom: 5px;">
                                            <asp:CheckBox ID="PrintDoubleSidedCheckBox" runat="server" Text="Print double sided" Skin="Web20" AutoPostBack="false" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding-bottom: 15px;">
                                            <asp:CheckBox ID="GPReportDiagramCheckBox" runat="server" Text="Diagram" Checked="true" />
                                            &nbsp;&nbsp;&nbsp;
                                            <telerik:RadDropDownList ID="GPReportDiagramDropDownList" runat="server" Skin="Windows7">
                                                <Items>
                                                    <telerik:DropDownListItem Text="Always" Value="1"></telerik:DropDownListItem>
                                                    <telerik:DropDownListItem Text="Only if sites are present" Value="2"></telerik:DropDownListItem>
                                                </Items>
                                            </telerik:RadDropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <table style="border-top: 1px dashed #c2d2e2; width: 100%;">
                                                <tr>
                                                    <td valign="top" style="border-right: 1px dashed #c2d2e2; width: 33%;">
                                                        <telerik:RadTreeView ID="PreProcedureTreeView" runat="server" CheckBoxes="true" Skin="WebBlue" TriStateCheckBoxes="true" OnClientNodeChecked="NodeChecked" OnClientLoad="onTreeLoad">
                                                            <Nodes>
                                                                <telerik:RadTreeNode Text="Pre Procedure" Value="PreProcedure">
                                                                    <Nodes>
                                                                        <telerik:RadTreeNode Text="List Consultant / Endoscopist" Value="GPReportListConsultantCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Nurse 1 / Nurse 2" Value="GPReportNursesCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Instrument" Value="GPReportInstrumentCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Missing Hospital Number" Value="GPReportMissingCaseNoteCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Indications" Value="GPReportIndicationsCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Co-morbidities / ASA" Value="GPReportCoMorbiditiesCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Planned Procedures" Value="GPReportPlannedProceduresCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Previous Gastric Ulcer Findings" Value="GPReportPreviousGastricUlcerCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Premedication" Value="GPReportPremedicationCheckBox" Checked="true" />
                                                                    </Nodes>
                                                                </telerik:RadTreeNode>
                                                            </Nodes>
                                                        </telerik:RadTreeView>
                                                    </td>
                                                    <td style="width: 20px;"></td>
                                                    <td valign="top" style="border-right: 1px dashed #c2d2e2; width: 33%;">
                                                        <telerik:RadTreeView ID="ProcedureTreeView" runat="server" CheckBoxes="true" Skin="WebBlue" TriStateCheckBoxes="true" OnClientNodeChecked="NodeChecked" OnClientLoad="onTreeLoad">
                                                            <Nodes>
                                                                <telerik:RadTreeNode Text="Procedure" Value="Procedure">
                                                                    <Nodes>
                                                                        <telerik:RadTreeNode Text="Diagnoses" Value="GPReportDiagnosesCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Therapeutic Procedures" Value="GPReportTherapeuticProceduresCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Specimens taken" Value="GPReportSpecimensTakenCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Procedure Notes" Value="GPReportProcedureNotesCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Site Notes" Value="GPReportSiteNotesCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Bowel Preparation" Value="GPReportBowelPreparationCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Extent of Intubation" Value="GPReportExtentOfIntubationCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Extent and limiting factors" Value="GPReportExtentAndLimitingFactorsCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Cannulation" Value="GPReportCannulationCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Extent of visualisation" Value="GPReportExtentOfVisualisationCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Contrast media used" Value="GPReportContrastMediaUsedCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Papillary anatomy" Value="GPReportPapillaryAnatomyCheckBox" Checked="true" />
                                                                    </Nodes>
                                                                </telerik:RadTreeNode>
                                                            </Nodes>
                                                        </telerik:RadTreeView>
                                                    </td>
                                                    <td style="width: 20px;"></td>
                                                    <td valign="top">
                                                        <telerik:RadTreeView ID="PostProcedureTreeView" runat="server" CheckBoxes="true" Skin="WebBlue" TriStateCheckBoxes="true" OnClientNodeChecked="NodeChecked" OnClientLoad="onTreeLoad">
                                                            <Nodes>
                                                                <telerik:RadTreeNode Text="Post Procedure" Value="PostProcedure">
                                                                    <Nodes>
                                                                        <telerik:RadTreeNode Text="Follow up" Value="GPReportFollowUpCheckBox" Checked="true" />
                                                                        <telerik:RadTreeNode Text="Peri-operative Complications" Value="GPReportPeriOperativeComplicationsCheckBox" Checked="true" />
                                                                    </Nodes>
                                                                </telerik:RadTreeNode>
                                                            </Nodes>
                                                        </telerik:RadTreeView>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <%--</fieldset>--%>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="RadPageView1" runat="server">
                            <div style="padding-bottom: 10px; padding-top: 10px; padding-left: 5px;" class="ConfigureBg">
                                <fieldset class="sysFieldset">
                                    <legend><b>Photographs</b></legend>

                                    <table runat="server" id="Table6" class="optionsBodyText" width="95%">
                                        <tr>
                                            <td>Default number of copies : 
                                                <telerik:RadNumericTextBox ID="PhotosDefaultNumberOfCopiesNumericTextBox" runat="server"
                                                    IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="1"
                                                    Width="35px"
                                                    MinValue="0"
                                                    MaxLength="3"
                                                    MaxValue="50">
                                                    <NumberFormat DecimalDigits="0" />
                                                </telerik:RadNumericTextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Size of image
                                                <telerik:RadComboBox ID="PhotosDefaultImageSize" runat="server">
                                                    <Items>
                                                        <telerik:RadComboBoxItem Text="Small" Value="1" />
                                                        <telerik:RadComboBoxItem Text="Medium" Value="2" />
                                                        <telerik:RadComboBoxItem Text="Large" Value="3" />
                                                    </Items>
                                                </telerik:RadComboBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="PhotosDefaultExportImage" runat="server" Text="Export Images" Checked="false" />
                                            </td>
                                        </tr>
                                    </table>
                                </fieldset>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="RadPageView2" runat="server">
                            <div style="padding-bottom: 10px; padding-top: 10px;" class="ConfigureBg">
                                <table style="width: 100%;">
                                    <tr>
                                        <td style="width: 50%;">
                                            <table runat="server" id="siteTable" class="optionsBodyText" style="margin-top: 5px; margin-left: 5px;" cellpadding="1" cellspacing="1">
                                                <tr>
                                                    <td style="padding-bottom: 5px;">Default number of copies : 
                                                        <telerik:RadNumericTextBox ID="PatientFriendlyDefaultCopiesRadNumericTextBox" runat="server"
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0"
                                                            MaxLength="3"
                                                            MaxValue="50">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:CheckBox ID="NoFollowupCheckBox" runat="server" Skin="Windows7"
                                                            Text="Include 'No further follow up appointment is necessary' where appropriate" />
                                                        <br />
                                                        <br />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:CheckBox ID="UreaseCheckBox" runat="server" Skin="Windows7"
                                                            Text="If the patient had an inconclusive urease (CLO) test, add this text to the report" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="PatientFriendlyTextBoxCell">
                                                        <telerik:RadTextBox runat="server" ID="UreaseTextBox" Width="100%" TextMode="MultiLine" Height="45px" Resize="None">
                                                        </telerik:RadTextBox><br />
                                                        <br />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:CheckBox ID="PolypectomyCheckBox" runat="server" Skin="Windows7"
                                                            Text="If the patient has had a polypectomy, add this text to the report" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="PatientFriendlyTextBoxCell">
                                                        <telerik:RadTextBox runat="server" ID="PolypectomyTextBox" Width="100%" TextMode="MultiLine" Height="45px" Resize="None">
                                                        </telerik:RadTextBox><br />
                                                        <br />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:CheckBox ID="OtherBiopsyCheckBox" runat="server" Skin="Windows7"
                                                            Text="If the patient had other (non-polyp / non-urease) biopsies, add this text to the report" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="PatientFriendlyTextBoxCell">
                                                        <telerik:RadTextBox runat="server" ID="OtherBiopsyTextBox" Width="100%" TextMode="MultiLine" Height="45px" Resize="None">
                                                        </telerik:RadTextBox><br />
                                                        <br />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:CheckBox ID="AnyOtherBiopsyCheckBox" runat="server" Skin="Windows7"
                                                            Text="For any biopsies also add this text" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="PatientFriendlyTextBoxCell">
                                                        <telerik:RadTextBox runat="server" ID="AnyOtherBiopsyTextBox" Width="100%" TextMode="MultiLine" Height="45px" Resize="None">
                                                        </telerik:RadTextBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td style="vertical-align: top; width: 40%; padding-right: 10px;">
                                            <table runat="server" id="Table2" class="optionsBodyText" style="margin-top: 5px; margin-left: 5px; padding-left: 15px; border-left: 1px dashed #c2d2e2;" cellpadding="1" cellspacing="1">
                                                <tr>
                                                    <td>
                                                        <asp:CheckBox ID="AdviceCommentsCheckBox" runat="server" Skin="Windows7"
                                                            Text="Include text in the follow up screen's advice/comments" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:CheckBox ID="PreceedAdviceCommentsCheckBox" runat="server" Skin="Windows7"
                                                            Text="Precede the advice/comments with this message" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="PatientFriendlyTextBoxCell">
                                                        <telerik:RadTextBox runat="server" ID="PreceedAdviceCommentsTextBox" Width="100%" TextMode="MultiLine" Height="45px" Resize="None">
                                                        </telerik:RadTextBox><br />
                                                        <br />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:Label ID="Label1" runat="server" Skin="Windows7"
                                                            Text="The following are boxes (and text) you want to appear in the report, and which will be manually ticked as appropriate" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <telerik:RadButton ID="AddEntryButton" runat="server" Text="Add Entry" Skin="Windows7" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:ListView ID="AdditionalListView" runat="server" DataKeyNames="Id">
                                                            <LayoutTemplate>
                                                                <table id="itemPlaceholderContainer" runat="server" border="0" class="rptSummaryText12" cellspacing="3" cellpadding="0" width="100%">
                                                                    <tr id="itemPlaceholder" runat="server">
                                                                    </tr>
                                                                </table>
                                                            </LayoutTemplate>
                                                            <ItemTemplate>
                                                                <tr>
                                                                    <td style="width: 10px;">
                                                                        <asp:CheckBox ID="AdditionalCheckBox" runat="server" Skin="Windows7" Checked='<%#Eval("IncludeAdditionalText") %>' />
                                                                    </td>
                                                                    <td>
                                                                        <telerik:RadTextBox runat="server" ID="AdditionalTextBox" Width="100%" Text='<%#Eval("AdditionalText") %>'>
                                                                        </telerik:RadTextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr style="height: 3px">
                                                                    <td></td>
                                                                </tr>
                                                            </ItemTemplate>
                                                        </asp:ListView>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <br />
                                                        <asp:CheckBox ID="FinalTextCheckBox" runat="server" Skin="Windows7"
                                                            Text="Include this final text to go at the bottom of the report" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="PatientFriendlyTextBoxCell">
                                                        <telerik:RadTextBox runat="server" ID="FinalTextBox" Width="100%" TextMode="MultiLine" Height="45px" Resize="None">
                                                        </telerik:RadTextBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="RadPageView3" runat="server">
                            <div style="padding-bottom: 10px; padding-top: 10px; padding-left: 5px;" class="ConfigureBg">
                                <fieldset class="sysFieldset">
                                    <legend><b>Configuration</b></legend>
                                    <table runat="server" id="Table1" class="optionsBodyText" style="margin-top: 5px; margin-left: 5px;" width="95%" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td colspan="2" style="padding-bottom: 5px;">Default number of copies : 
                                                        <telerik:RadNumericTextBox ID="LabRequestDefaultCopiesRadNumericTextBox" runat="server"
                                                            IncrementSettings-InterceptMouseWheel="false"
                                                            IncrementSettings-Step="1"
                                                            Width="35px"
                                                            MinValue="0"
                                                            MaxLength="3"
                                                            MaxValue="50">
                                                            <NumberFormat DecimalDigits="0" />
                                                        </telerik:RadNumericTextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <asp:RadioButtonList ID="LabRequestGroupSpecimensRadioButtonList" runat="server"
                                                    CellSpacing="0" CellPadding="0" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="rbl">
                                                    <asp:ListItem Value="1" Text="Print one request for every specimen taken" Selected="True"></asp:ListItem>
                                                    <asp:ListItem Value="2" Text="Group specimens by destination"></asp:ListItem>
                                                </asp:RadioButtonList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="LabRequestsPerPageCheckBox" runat="server" Text="Requests per A4 page" Skin="Windows7" Checked="true" Enabled="false" />&nbsp;&nbsp;
                                                <telerik:RadDropDownList ID="LabRequestsPerPageDropDownList" runat="server" Skin="Windows7">
                                                    <Items>
                                                        <telerik:DropDownListItem Text="One" Value="1"></telerik:DropDownListItem>
                                                        <telerik:DropDownListItem Text="Two" Value="2"></telerik:DropDownListItem>
                                                    </Items>
                                                </telerik:RadDropDownList>
                                            </td>
                                        </tr>
                                    </table>
                                </fieldset>
                                <br />
                                <fieldset class="sysFieldset">
                                    <table runat="server" id="Table3" class="optionsBodyText" style="margin-top: 5px; margin-left: 5px;" width="95%" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td>
                                                <asp:CheckBox ID="LabRequestDiagramCheckBox" runat="server" Text="Include diagram" Checked="true" Skin="Windows7" />
                                            </td>
                                        </tr>
                                    </table>
                                </fieldset>
                                <br />
                                <fieldset class="sysFieldset">
                                    <legend><b>Time specimen collected</b></legend>
                                    <table runat="server" id="Table4" class="optionsBodyText" style="margin-top: 5px; margin-left: 5px;" width="95%" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td colspan="2">
                                                <asp:CheckBox ID="LabRequestTimeCheckBox" runat="server" Text="Include the appropriate time the specimen was collected" Checked="true" Skin="Windows7" />
                                            </td>
                                        </tr>
                                    </table>
                                </fieldset>
                                <br />
                                <fieldset class="sysFieldset">
                                    <legend><b>Request body text</b></legend>
                                    <table runat="server" id="Table5" class="optionsBodyText" style="margin-top: 5px; margin-left: 5px;" width="95%" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td>To include :</td>
                                            <td>
                                                <asp:CheckBox ID="LabRequestHeadingCheckBox" runat="server" Text="Text to be headed : " Checked="true" Skin="Windows7" />&nbsp;&nbsp;
                                                <telerik:RadComboBox ID="LabRequestHeadingComboBox" runat="server" Skin="Windows7"
                                                    OnClientSelectedIndexChanged="ToggleOtherTextBox">
                                                    <Items>
                                                        <telerik:RadComboBoxItem Text="Clinical Details" Value="1"></telerik:RadComboBoxItem>
                                                        <telerik:RadComboBoxItem Text="Clinical Findings" Value="2"></telerik:RadComboBoxItem>
                                                        <telerik:RadComboBoxItem Text="Clinical Features" Value="3"></telerik:RadComboBoxItem>
                                                        <telerik:RadComboBoxItem Text="Clinical Indications" Value="4" Selected="true"></telerik:RadComboBoxItem>
                                                        <telerik:RadComboBoxItem Text="Other" Value="5"></telerik:RadComboBoxItem>
                                                    </Items>
                                                </telerik:RadComboBox>
                                            </td>
                                            <td>
                                                <telerik:RadTextBox ID="LabRequestOtherTextBox" runat="server" Width="150" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding-left: 10px;">
                                                <asp:CheckBox ID="LabRequestIndicationsCheckBox" runat="server" Text="Indications" Checked="true" Skin="Windows7" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding-left: 10px;">
                                                <asp:CheckBox ID="LabRequestProcedureNotesCheckBox" runat="server" Text="Procedure notes" Checked="true" Skin="Windows7" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding-left: 10px;">
                                                <asp:CheckBox ID="LabRequestAbnormalitiesCheckBox" runat="server" Text="Findings/Abnormalities" Checked="true" Skin="Windows7" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding-left: 10px;">
                                                <asp:CheckBox ID="LabRequestSiteNotesCheckBox" runat="server" Text="Site notes" Checked="true" Skin="Windows7" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding-left: 10px;">
                                                <asp:CheckBox ID="LabRequestDiagnosesCheckBox" runat="server" Text="Diagnoses" Checked="true" Skin="Windows7" />
                                            </td>
                                        </tr>
                                    </table>
                                </fieldset>
                            </div>
                        </telerik:RadPageView>
                    </telerik:RadMultiPage>
                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="43px" CssClass="">
                <%--<div id="cmdOtherData" style="height: 10px; margin-top: 10px; margin-left: 10px; padding-top: 6px;">--%>
                <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" />
                <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" Visible="false" Icon-PrimaryIconCssClass="telerikCancelButton" />
                <telerik:RadButton ID="CloseButton" runat="server" Text="Close" Skin="Web20" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                <%--</div>--%>
            </telerik:RadPane>
        </telerik:RadSplitter>
    </form>
</body>
</html>
