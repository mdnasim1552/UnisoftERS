<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_RegistrationDetails" CodeBehind="RegistrationDetails.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .optionsHeadingNote_bgWhite table td:first-child {
            width: 160px;
        }
    </style>

    <script type="text/javascript">
        $(window).on('load', function () {

        });

        $(document).ready(function () {

            PageLoad();
        });

        function showCopySettingsOptions() {
            //$('#CopySettingsDiv').css('visibility', 'visible');
        }

        function hideCopySettingsOptions() {
            //$('#CopySettingsDiv').css('visibility', 'hidden');
        }

        function patient_datasource_changed(sender, args) {
            var ddlValue = sender.get_value();
            showHideReportPathEntry(ddlValue);
        }

        function showHideReportPathEntry(ddlValue) {
            if (ddlValue === null || ddlValue === undefined || ddlValue === "") {
                $('#ReportPathTR').hide();
            }
            else {
                $('#ReportPathTR').show();
            }
        }
    </script>
</head>

<body>
    <script type="text/javascript">
</script>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="CopySettingsDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />

        <telerik:RadAjaxManager runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="AddNewHospitalRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="formDiv" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="OperatingHospitalsRadComboBox" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="AddNewTrustRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="formDiv" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="AddNewTrustRadButton" />
                        <telerik:AjaxUpdatedControl ControlID="AddNewHospitalRadButton" />
                        <telerik:AjaxUpdatedControl ControlID="TrustRadComboBox" />
                        <telerik:AjaxUpdatedControl ControlID="OperatingHospitalsRadComboBox" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="OperatingHospitalsRadComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="formDiv" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="TrustRadComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="OperatingHospitalsRadComboBox" />
                        <telerik:AjaxUpdatedControl ControlID="formDiv" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SaveButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="formDiv" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="OperatingHospitalsRadComboBox" />
                        <%--<telerik:AjaxUpdatedControl ControlID="TrustRadComboBox" />--%>
                        <%--<telerik:AjaxUpdatedControl ControlID="AddNewTrustRadButton" />--%>
                        <telerik:AjaxUpdatedControl ControlID="AddNewHospitalRadButton" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <%--<telerik:AjaxSetting AjaxControlID="CancelButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="formDiv" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>--%>
            </AjaxSettings>
        </telerik:RadAjaxManager>
        <telerik:RadScriptBlock ID="radscript1" runat="server">
            <script type="text/javascript">
                function PageLoad() {
                    //MH added on 27 Oct 2021 - to make visible/invisible of the export path textbox on form load
                    var cbo = document.getElementById("cboWSValue").value;
                    
                    showHideReportPathEntry(cbo);
                }
                function ShowHideControls() {
                    var cbo = $find('<%=cboImportPatientByWebservice.ClientID %>');
                    //alert(cbo.get_selectedItem().get_value());
                    showHideReportPathEntry(cbo.get_selectedItem().get_value());
                }
            </script>
        </telerik:RadScriptBlock>
        <asp:HiddenField ID="cboWSValue" runat="server" />

        <div class="optionsHeading">Registration Details</div>
        <table class="optionsBodyText">
            <tr id="TrustFilterTR" runat="server" visible="false">
                <td>Trust:</td>
                <td>
                    <telerik:RadComboBox CssClass="filterDDL" ID="TrustRadComboBox" runat="server" Width="270px" AutoPostBack="true" OnSelectedIndexChanged="TrustRadComboBox_SelectedIndexChanged" DataTextField="TrustName" DataValueField="TrustId" />
                </td>
                <td>
                    <telerik:RadButton ID="AddNewTrustRadButton" runat="server" Text="Add New Trust" OnClick="AddNewTrustRadButton_Click" Visible="false"/>
                </td>
            </tr>
            <tr id="OperatingHospitalFilterTD" runat="server">
                <td>Operating Hospital:</td>
                <td>
                    <telerik:RadComboBox CssClass="filterDDL" ID="OperatingHospitalsRadComboBox" runat="server" Width="270px" AutoPostBack="true" OnSelectedIndexChanged="OperatingHospitalsRadComboBox_SelectedIndexChanged" />
                </td>
                <td>
                    <telerik:RadButton ID="AddNewHospitalRadButton" runat="server" Text="Add New Hospital" OnClick="AddNewHospitalRadButton_Click" OnClientClicked="showCopySettingsOptions" />
                </td>
            </tr>
        </table>

        <%--<div style="margin-left: 10px;" class="optionsHeadingNote">
            <b>Please note:</b><br />
            The report Heading refers to the title that appears at the top of every report and is usually the name of the hospital.<br />
            <br />
            The Department Name refers to the name that appears in the opening screen along with the name of the Hospital to which the software has been registered. 
            This name appears nowhere else in the software and can be left blank.
        </div>--%>

        <div id="formDiv" runat="server" style="margin-left: 10px;" class="optionsHeadingNote_bgWhite">
            <fieldset>
                <table>
                    <tr>
                        <td colspan="2">
                            <telerik:RadButton ID="btnToggle" runat="server" ToggleType="CheckBox" ButtonType="ToggleButton" AutoPostBack="false" Skin="Metro" Text="Enable NHS style header for reports" Font-Bold="true">
                            </telerik:RadButton>
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 50%;">
                            <table id="tableOptions">

                                <tr>
                                    <td style="width: 195px;">Trust Name :</td>
                                    <td>
                                        <telerik:RadTextBox ID="TrustNameRadTextBox" runat="server" Skin="Metro" Enabled="false" />
                                    </td>

                                </tr>
                                <tr>
                                    <td style="width: 195px;">Hospital Name :</td>
                                    <td>
                                        <telerik:RadTextBox ID="HospitalNameRadTextBox" runat="server" Width="250" Skin="Metro" />
                                    </td>

                                </tr>
                                <tr>
                                    <td>Internal Hospital ID :</td>
                                    <td>
                                        <telerik:RadTextBox ID="InternalHospitalIdRadTextBox" runat="server" Width="250" Skin="Metro" Text="" />
                                    </td>
                                </tr>
                                <tr>
                                    <td id="NationalHealthName" runat="server"> Hospital ID :</td>
                                    <td>
                                        <telerik:RadTextBox ID="NHSHospitalIdRadTextBox" runat="server" Width="250" Skin="Metro" Text="" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td>
                            <table cellspacing="10" cellpadding="0" border="0">
                                <tr>
                                    <td>Trust Type :</td>
                                    <td>
                                        <telerik:RadTextBox ID="TrustTypeRadTextBox" runat="server" Width="250" Skin="Metro" Text="NHS Trust" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Contact Number :</td>
                                    <td>
                                        <telerik:RadTextBox ID="ContactNumberRadTextBox" runat="server" Width="250" Skin="Metro" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Department Name :</td>
                                    <td>
                                        <telerik:RadTextBox ID="DepartmentNameRadTextBox" runat="server" Width="250" Skin="Metro" Text="" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </fieldset>

            <fieldset>

                <table id="tableReporting" runat="server">
                    <tr>
                        <td style="width: 180px;">Report Heading :</td>
                        <td>
                            <telerik:RadTextBox ID="ReportHeadingRadTextBox" runat="server" Width="400" Skin="Metro" Text="Default" />
                        </td>
                    </tr>
                    <tr>
                        <td>Report subheading :</td>
                        <td>
                            <telerik:RadTextBox ID="ReportSubheadingRadTextBox" runat="server" Width="400" Skin="Metro" Text="" />
                        </td>
                    </tr>
                    <tr>
                        <td>Report Footer :</td>
                        <td>
                            <telerik:RadTextBox ID="ReportFooterRadTextBox" runat="server" Width="400" Skin="Metro" Text="" />
                        </td>
                    </tr>
                </table>
            </fieldset>

            <!-- Mahfuz added on 8 Mar 2021 10:55 am. For D&G SE Upgrade-->
              <fieldset>
                <table width="100%" style="vertical-align:middle;">
                    <tr>
                        <td style="width: 180px;">Patient Datasource
                        </td>
                        <td>
                            <telerik:RadComboBox runat="server" ID="cboImportPatientByWebservice" Width="400" Skin="Metro" OnClientSelectedIndexChanged="patient_datasource_changed" />
                            &nbsp;
                            <asp:CheckBox ID="chkSuppressMainReportPDF" runat="server" Text="Suppress Main Report PDF" />
                        </td>
                    </tr>
                    <tr id="ReportPathTR" style="display: none;">
                        <td>Report Export Path :</td>
                        <td style="vertical-align:middle !important;">
                            <telerik:RadTextBox ID="ReportExportPathRadTextBox" runat="server" Width="400" Skin="Metro" Text="" />&nbsp;&nbsp;
                            <asp:CheckBox ID="chkAddFileExportForMirth" runat="server" Text="Add File Export for Mirth" />
                        </td>
                    </tr>
                    <tr>
                        <td>Export Document Name Prefix :</td>
                        <td style="vertical-align:middle !important;">
                            <telerik:RadTextBox ID="txtExportDocumentFilePrefix" runat="server" Width="400" Skin="Metro" Text="" />&nbsp;&nbsp;
                        </td>
                    </tr>
                </table>
            </fieldset>

            <%--            
            <!-- only to be shown if NED enabled-->
            <fieldset id="NEDExportOptionsFieldset" runat="server" class="sysFieldset" style="padding: 1em;">
                <legend><b>NED Export options</b></legend>
                <table>
                    <tr>
                        <td style="width: 200px">Hospital site code (ODS code):</td>
                        <td>
                            <telerik:RadTextBox runat="server" ID="NEDODS_CodeTextBox" Width="100px" Skin="Metro" /></td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label Text="Export Path:" runat="server" /><asp:HyperLink runat="server" ID="ExportPathLink" Visible="false" /></td>
                        <td>
                            <telerik:RadTextBox runat="server" ID="NEDExportPathTextBox" Width="300px" Skin="Office2007" /><img src="../../Images/xml-folder-icon.png" style="display: none;" alt="Select NED Export destination" />
                        </td>
                    </tr>
                </table>


            </fieldset>--%>
        </div>
        <div class="" style="margin-left: 10px;">
            <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Metro" CausesValidation="true" Icon-PrimaryIconCssClass="telerikSaveButton" />
            <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Metro" CausesValidation="false" Icon-PrimaryIconCssClass="telerikCancelButton" OnClientClicked="hideCopySettingsOptions" />
        </div>
        <div id="CopySettingsDiv" class="new-hospital-copy-settings" style="padding-left: 10px; visibility: hidden;">
            <table cellspacing="5" cellpadding="0" border="0">
                <tr>
                    <td>
                        <asp:CheckBox ID="CopyPrintSettingsCheckBox" runat="server" Text="Copy print settings?" Checked="true" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:CheckBox ID="CopyPhraseLibraryCheckBox" runat="server" Text="Copy phrase library?" Checked="true" />
                    </td>
                </tr>
            </table>
        </div>

    </form>
</body>
</html>
