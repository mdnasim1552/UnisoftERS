<%@ Page Language="VB" MasterPageFile="~/Templates/Unisoft.master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Common_Options" Codebehind="Options.aspx.vb" %>

<asp:Content ID="IDHead" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">
    <title>Options</title>
    <link href="../../Styles/Site.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <style type="text/css">
        .asubheader:after {
            content: '';
            display: inline-block;
            width: 50%;
            border-top: 1px solid;
            vertical-align: middle;
            /*margin-left: 5px;
            margin-right: 5px;*/
        }

        .RequiredFieldsTable {
            border:none;            
        }

        .RequiredFieldsTable th {
            text-align:left;
            height:20px;
            font-weight:bold;
        }

        .UnlockImage:hover {
            background-image: url('~/Images/Lock-Lock-48x48.png');
        }
    </style>

    <script type="text/javascript">
        //function GetRadWindow() {
        //    var oWindow = null;
        //    if (window.radWindow) oWindow = window.radWindow;
        //    else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow;
        //    return oWindow;
        //}

        //function CloseDialog(button) {
        //    GetRadWindow().close();
        //}

        //$(document).ready(function () {
        //    alert(window.innerWidth);
        //    alert(window.innerHeight);
        //});

        //window.onresize = function(event) {
        //    alert(window.innerWidth);
        //        alert(window.innerHeight);
        //};

        function openAddTitleWindow() {
            //Get a reference to the window.
            var oWnd = $find("<%= AddNewTitleRadWindow.ClientID %>");

            ////Add the name of the function to be executed when RadWindow is closed.
            //oWnd.add_close(OnClientClose);

            oWnd.show();

            //window.radopen(null, "AddNewTitleRadWindow");

            return false;
        }

        function closeAddTitleWindow() {
            var oWnd = $find("<%= AddNewTitleRadWindow.ClientID %>");
            if (oWnd != null)
                oWnd.close();
            return false;
        }

        //function OnClientClose(oWnd, eventArgs) {
        //    //Remove the OnClientClose function to avoid
        //    //adding it for a second time when the window is shown again.
        //    oWnd.remove_close(OnClientClose);
        //    return false;
        //}
    </script>
</asp:Content>

<asp:Content ID="IDBody" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadSplitter ID="radMainBody" runat="server" Orientation="Horizontal" Skin="Office2007">
            <telerik:RadPane ID="radPaneRight" runat="server">
                <telerik:RadMultiPage ID="RadMultiPage" runat="server" SelectedIndex="0">
                    <telerik:RadPageView ID="rvPage1" runat="server">
                        <div class="optHeaderText">Password settings</div>
                        <div class="rptText" style="margin: 5px 15px;">
                            <table id="tablePassword" runat="server" cellspacing="1" cellpadding="0">
                                <tr>
                                    <td style="width: 110px;">Old password:</td>
                                    <td>
                                        <telerik:RadTextBox ID="txtOldPassword" runat="server" TextMode="Password" Width="110" /></td>
                                </tr>
                                <tr>
                                    <td>New password:</td>
                                    <td>
                                        <telerik:RadTextBox ID="txtNewPassword1" runat="server" TextMode="Password" Width="110" /></td>
                                </tr>
                                <tr>
                                    <td>Confirm password:</td>
                                    <td>
                                        <telerik:RadTextBox ID="txtNewPassword2" runat="server" TextMode="Password" Width="110" /></td>
                                </tr>
                            </table>
                        </div>
                        <div class="optHeaderText" style="margin-top: 15px;">Start-up settings</div>
                    </telerik:RadPageView>
                    <telerik:RadPageView ID="rvPage2" runat="server">
                        <div class="optHeaderText">Software settings</div>
                        <div class="rptText" style="margin: 5px 12px;">
                            <fieldset>
                                <legend>&nbsp;<b>OGD diagnoses</b>&nbsp;</legend>
                                <table id="tableOGDDiag" runat="server" cellspacing="1" cellpadding="0" border="0">
                                    <tr>
                                        <td colspan="2">When the whole upper tract is normal the Diagnosis screen is to automatically show</td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:RadioButton ID="optOGDWhole" runat="server" GroupName="optOGDDiag" Text="Whole upper tract normal" Checked="true" />&nbsp;&nbsp;</td>
                                        <td>
                                            <asp:RadioButton ID="optOGDIndividual" runat="server" GroupName="optOGDDiag" Text="Individually Oesophagus normal, Stomach normal, Duodenum normal." /></td>
                                    </tr>
                                </table>
                            </fieldset>
                        </div>
                        <div class="rptText" style="margin: 5px 12px;">
                            <fieldset>
                                <legend>&nbsp;<b>Site lettering / numbering</b>&nbsp;</legend>
                                <table id="tableSiteLabels" runat="server" cellspacing="1" cellpadding="0" border="0">
                                    <tr>
                                        <td colspan="2" style="width: auto;">The sites on the diagram of the anatomy can either be identified with lower case letters of the alphabet (a, b, c) <b>OR</b> by numerics (1, 2, 3)</td>
                                    </tr>
                                    <tr>
                                        <td style="width: 70px;">
                                            <asp:RadioButton ID="optAlpha" runat="server" GroupName="optSiteLabel" Text="Letters" Checked="true" />&nbsp;&nbsp;</td>
                                        <td>
                                            <asp:RadioButton ID="optNumerics" runat="server" GroupName="optSiteLabel" Text="Numerics" /></td>
                                    </tr>
                                </table>
                            </fieldset>
                        </div>
                        <div class="rptText" style="margin: 5px 12px;">
                            <fieldset>
                                <legend>&nbsp;<b>Urease tests</b>&nbsp;</legend>
                                <table id="tableUrease" runat="server" cellspacing="1" cellpadding="0" border="0">
                                    <tr>
                                        <td colspan="2" style="width: auto;">With belated urease results you can either include tick boxes for +ve and -ve on the report, which then we manually ticked by a nurse.</td>
                                    </tr>
                                    <tr>
                                        <td style="width: auto;">
                                            <asp:CheckBox ID="chkUrease" runat="server" Text="Include tick boxes on the report." /></td>
                                        <td>&nbsp;</td>
                                    </tr>
                                </table>
                            </fieldset>
                        </div>
                        <div class="rptText" style="margin: 5px 12px;">
                            <fieldset>
                                <legend>&nbsp;<b>Report locking options</b>&nbsp;</legend>
                                <table id="tableReportLockOptions" runat="server" cellspacing="1" cellpadding="0" border="0">
                                    <tr>
                                        <td style="width: auto;">
                                            <asp:RadioButton ID="optReportsEdit" runat="server" GroupName="optReportLockOptions" Text="Reports can always be edited (Default)" Checked="true" />&nbsp;&nbsp;</td>
                                        <td>
                                            <asp:RadioButton ID="optReportsLock" runat="server" GroupName="optReportLockOptions" Text="Reports must be locked (Read-only)" /></td>
                                    </tr>
                                </table>
                            </fieldset>
                        </div>
                        <div class="rptText" style="margin: 5px 12px;">
                            <fieldset style="width: 400px; float: left;">
                                <legend>&nbsp;<b>GP registration</b>&nbsp;</legend>
                                <table id="table1" runat="server" cellspacing="1" cellpadding="0" border="0">
                                    <tr>
                                        <td style="width: auto;">
                                            <asp:RadioButton ID="optGPBased" runat="server" GroupName="optGPReg" Text="GP based registration (Default)" Checked="true" />&nbsp;&nbsp;</td>
                                        <td>
                                            <asp:RadioButton ID="optPractceBased" runat="server" GroupName="optGPReg" Text="Practice based registration" /></td>
                                    </tr>
                                </table>
                            </fieldset>
                        </div>
                        <div class="rptText" style="margin: 5px 12px;">
                            <fieldset>
                                <legend>&nbsp;<b>Oesophagitis Classification</b>&nbsp;</legend>
                                <table id="tableOesoClass" runat="server" cellspacing="1" cellpadding="0" border="0">
                                    <tr>
                                        <td style="width: auto;">
                                            <asp:RadioButton ID="optSavaryMiller" runat="server" GroupName="optOesoClass" Text="Modified Savary Miller" Checked="true" />&nbsp;&nbsp;</td>
                                        <td>
                                            <asp:RadioButton ID="optLA" runat="server" GroupName="optOesoClass" Text="LA Classification" /></td>
                                    </tr>
                                </table>
                            </fieldset>
                        </div>
                        <div class="rptText" style="margin: 5px 12px;">
                            <fieldset style="width: 400px; float: left;">
                                <legend>&nbsp;<b>Recording medication</b>&nbsp;</legend>
                                <table id="tableRecMeds" runat="server" cellspacing="1" cellpadding="0" border="0">
                                    <tr>
                                        <td style="width: auto;">
                                            <asp:RadioButton ID="optAuthMeds" runat="server" GroupName="optRecMeds" Text="No authentication required (Default)" Checked="true" />&nbsp;&nbsp;</td>
                                        <td>
                                            <asp:RadioButton ID="optNoAuthMeds" runat="server" GroupName="optRecMeds" Text="Authenticate with password" /></td>
                                    </tr>
                                </table>
                            </fieldset>
                        </div>
                        <div class="rptText" style="margin: 5px 12px;">
                            <fieldset>
                                <legend>&nbsp;<b>Boston bowel prep scale</b>&nbsp;</legend>
                                <table id="tableBBPS" runat="server" cellspacing="1" cellpadding="0" border="0">
                                    <tr>
                                        <td style="width: auto;">
                                            <asp:RadioButton ID="optBBPSOff" runat="server" GroupName="optBBPS" Text="Off (Default)" Checked="true" />&nbsp;&nbsp;</td>
                                        <td>
                                            <asp:RadioButton ID="optBBPSOn" runat="server" GroupName="optBBPS" Text="On" /></td>
                                    </tr>
                                </table>
                            </fieldset>
                        </div>
                        <div class="rptText" style="margin: 5px 12px;">
                            <fieldset>
                                <legend>&nbsp;<b>Application Options</b>&nbsp;</legend>
                                <table id="tableAppTimeout" runat="server" cellspacing="1" cellpadding="0" border="0">
                                    <tr>
                                        <td style="width: auto;">Set application timeout period in&nbsp;&nbsp;</td>
                                        <td>
                                            <telerik:RadNumericTextBox ID="txtPeriod" runat="server" Skin="Office2007" Width="35" Value="20" MinValue="15" MaxValue="120" NumberFormat-DecimalDigits="0" /></td>
                                        <td>&nbsp;minutes (range 15 - 120)</td>
                                    </tr>
                                </table>
                                <table id="tableAppAudit" runat="server" cellspacing="1" cellpadding="0" border="0">
                                    <tr style="vertical-align: middle;">
                                        <td style="width: 110px;">Enable Audit log&nbsp;&nbsp;</td>
                                        <td>
                                            <asp:RadioButton ID="optAuditLogOn" runat="server" GroupName="optAuditLog" Text="Enabled" Checked="true" />&nbsp;&nbsp;</td>
                                        <td>
                                            <asp:RadioButton ID="optAuditLogOff" runat="server" GroupName="optAuditLog" Text="Disabled" /></td>
                                    </tr>
                                </table>
                                <table id="tableAppError" runat="server" cellspacing="1" cellpadding="0" border="0">
                                    <tr style="vertical-align: middle;">
                                        <td style="width: 110px;">Enable Error log&nbsp;&nbsp;</td>
                                        <td>
                                            <asp:RadioButton ID="optErrLogOn" runat="server" GroupName="optErrorLog" Text="Enabled" Checked="true" />&nbsp;&nbsp;</td>
                                        <td>
                                            <asp:RadioButton ID="optErrLogOff" runat="server" GroupName="optErrorLog" Text="Disabled" /></td>
                                    </tr>
                                </table>
                                <table id="tableAppImGrab" runat="server" cellspacing="1" cellpadding="0" border="0">
                                    <tr style="vertical-align: middle;">
                                        <td style="width: 110px;">Enable ImGrab&nbsp;&nbsp;</td>
                                        <td>
                                            <asp:RadioButton ID="optImGrabOn" runat="server" GroupName="optImGrab" Text="Enabled" />&nbsp;&nbsp;</td>
                                        <td>
                                            <asp:RadioButton ID="optImGrabOff" runat="server" GroupName="optImGrab" Text="Disabled" /></td>
                                    </tr>
                                </table>
                            </fieldset>
                        </div>
                    </telerik:RadPageView>
                    <telerik:RadPageView ID="rvPage3" runat="server">
                        <div class="rptText" style="margin: 10px 12px;">
                            <table id="tableExportOptions" runat="server" cellspacing="1" cellpadding="0" border="0">
                                <tr style="vertical-align: top;">
                                    <td>
                                        <telerik:RadTreeView ID="rtvExportOptions" runat="server" Skin="Office2010Silver" BorderWidth="1" Width="140" Height="440" BorderColor="#c0c0c0">
                                            <Nodes>
                                                <telerik:RadTreeNode Text="Export Options" Expanded="true" Selected="true" Font-Bold="true">
                                                    <Nodes>
                                                        <telerik:RadTreeNode Text="Filename" />
                                                        <telerik:RadTreeNode Text="Fields" />
                                                    </Nodes>
                                                </telerik:RadTreeNode>
                                                <telerik:RadTreeNode Text="Report Log" Font-Bold="true" />
                                            </Nodes>
                                        </telerik:RadTreeView>
                                    </td>
                                    <td style="width: 100%;">
                                        <div class="optHeaderText">Options</div>
                                        <div style="margin-left: 10px;">
                                            <table id="tableOptions" runat="server" cellspacing="3" cellpadding="0" border="0">
                                                <tr>
                                                    <td style="width: 80px;">Profile</td>
                                                    <td>
                                                        <telerik:RadComboBox ID="cboProfile" runat="server" Skin="Windows7">
                                                            <Items>
                                                                <telerik:RadComboBoxItem Text="Default" />
                                                                <telerik:RadComboBoxItem Text="Export2EDT" Selected="true" />
                                                            </Items>
                                                        </telerik:RadComboBox>
                                                    </td>
                                                    <td>
                                                        <telerik:RadButton ID="cmdCreateProfile" runat="server" Text="Create profile" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>File type</td>
                                                    <td colspan="2">
                                                        <telerik:RadComboBox ID="cboFileType" runat="server" Skin="Windows7" Width="200">
                                                            <Items>
                                                                <telerik:RadComboBoxItem Text="Comma separated values (CSV)" />
                                                                <telerik:RadComboBoxItem Text="Portable document format (PDF)" Selected="true" />
                                                            </Items>
                                                        </telerik:RadComboBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Export Path</td>
                                                    <td colspan="2">
                                                        <telerik:RadTextBox ID="txtExportPath" runat="server" Width="250" Skin="Office2007" Text="C:\Temp\" /></td>
                                                </tr>
                                            </table>
                                            <table id="tableOptionSettings" runat="server" cellspacing="3" cellpadding="0" border="0">
                                                <tr style="vertical-align: middle;">
                                                    <td style="width: 150px;">Include field names?</td>
                                                    <td>
                                                        <asp:RadioButton ID="optNo" runat="server" GroupName="optInclFieldNames" Text="No (Default)" Checked="true" />&nbsp;&nbsp;<asp:RadioButton ID="optYes" runat="server" GroupName="optInclFieldNames" Text="Yes" /></td>
                                                </tr>
                                                <tr style="vertical-align: top;">
                                                    <td>Display notification message after each export?</td>
                                                    <td>
                                                        <asp:RadioButton ID="optMsgNo" runat="server" GroupName="optDisplayMsg" Text="No (Default)" Checked="true" />&nbsp;&nbsp;<asp:RadioButton ID="optMsgYes" runat="server" GroupName="optDisplayMsg" Text="Yes" /></td>
                                                </tr>
                                                <tr style="vertical-align: middle;">
                                                    <td>If fields are empty?</td>
                                                    <td>
                                                        <telerik:RadComboBox ID="cboFieldsBlank" runat="server" Skin="Windows7">
                                                            <Items>
                                                                <telerik:RadComboBoxItem Text="Leave blank" Selected="true" />
                                                            </Items>
                                                        </telerik:RadComboBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </telerik:RadPageView>
                    <telerik:RadPageView ID="rvPage4" runat="server">
                        <div class="rptSummaryText10">Database settings</div>
                    </telerik:RadPageView>
                    <telerik:RadPageView ID="rvPage5" runat="server">
                        <div class="rptText" style="margin: 10px 12px;">
                            <telerik:RadTabStrip ID="rtsAdminUtils" runat="server" Skin="Vista" SelectedIndex="0" MultiPageID="RadMultiPage2">
                                <Tabs>
                                    <telerik:RadTab Text="Registration details" />
                                    <telerik:RadTab Text="Password rules" />
                                    <telerik:RadTab Text="NHS No validation" />
                                    <telerik:RadTab Text="System usage" />
                                    <telerik:RadTab Text="Drug list" />
                                    <telerik:RadTab Text="GP details" />
                                    <telerik:RadTab Text="Instrument details" />
                                    <telerik:RadTab Text="Referral details" />
                                    <telerik:RadTab Text="Consultant/operators" />
                                </Tabs>
                            </telerik:RadTabStrip>
                            <telerik:RadMultiPage ID="RadMultiPage2" runat="server" SelectedIndex="0">
                                <telerik:RadPageView ID="radPage1" runat="server">
                                    <div class="text">Registration details</div>
                                </telerik:RadPageView>
                                <telerik:RadPageView ID="radPage2" runat="server">
                                    <div class="lblText" style="margin: 5px 12px;">
                                        <table id="tablePassWDRules" runat="server" cellspacing="3" cellpadding="0" border="0" style="width: auto;">
                                            <tr>
                                                <td colspan="3" style="height: 30px;">These are the rules to be applied when users create their passwords</td>
                                            </tr>
                                            <tr>
                                                <td style="width: 180px;">
                                                    <asp:CheckBox ID="chkMinLen" runat="server" Text="Minimum length" />&nbsp;</td>
                                                <td style="width: 55px;">
                                                    <telerik:RadNumericTextBox ID="txtMinLen" runat="server" Skin="Office2007" Width="35" Value="1" MinValue="1" MaxValue="10" NumberFormat-DecimalDigits="0" />&nbsp;</td>
                                                <td>character(s)</td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="chkMustHave" runat="server" Text="Must contain at least" />&nbsp;</td>
                                                <td style="width: 55px;">
                                                    <telerik:RadNumericTextBox ID="txtMustHave" runat="server" Skin="Office2007" Width="35" MinValue="1" MaxValue="10" NumberFormat-DecimalDigits="0" />&nbsp;</td>
                                                <td>non-alphanumeric character(s)</td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="chkMustChange" runat="server" Text="Must be changed every" />&nbsp;</td>
                                                <td style="width: 55px;">
                                                    <telerik:RadNumericTextBox ID="txtEvery" runat="server" Skin="Office2007" Width="35" MinValue="1" MaxValue="10" NumberFormat-DecimalDigits="0" />&nbsp;</td>
                                                <td>day(s)</td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:CheckBox ID="chkMustDiff" runat="server" Text="Must be different to the last" />&nbsp;</td>
                                                <td style="width: 55px;">
                                                    <telerik:RadNumericTextBox ID="txtLastPW" runat="server" Skin="Office2007" Width="35" MinValue="1" MaxValue="10" NumberFormat-DecimalDigits="0" />&nbsp;</td>
                                                <td>password(s)</td>
                                            </tr>
                                            <tr>
                                                <td colspan="3">
                                                    <asp:CheckBox ID="chkNoSpaces" runat="server" Text="Must NOT include spaces" /></td>
                                            </tr>
                                            <tr>
                                                <td colspan="3">
                                                    <asp:CheckBox ID="chkNotUserID" runat="server" Text="Cannot be the same as the UserID" /></td>
                                            </tr>
                                        </table>
                                    </div>
                                </telerik:RadPageView>
                            </telerik:RadMultiPage>
                        </div>
                    </telerik:RadPageView>
                    <telerik:RadPageView ID="rvPage54" runat="server">
                        <telerik:RadFormDecorator ID="ReqFieldsSetupRadFormDecorator" runat="server" DecoratedControls="All"
                            DecorationZoneID="ReqFieldsSetupDiv" Skin="Web20" />
                        <div class="optHeaderText">Required Fields Setup</div>
                        <div id="ReqFieldsSetupDiv">

                            <asp:ObjectDataSource ID="ReqFieldsObjectDataSource" runat="server"
                                TypeName="Options" SelectMethod="GetRequiredFields" UpdateMethod="UpdateRequiredFields">
                                <SelectParameters>
                                    <asp:Parameter Name="ProcedureType" DbType="Int32" />
                                    <asp:Parameter Name="PageName" DbType="String" />
                                    <asp:Parameter Name="ClassName" DbType="String" />
                                    <asp:Parameter Name="Required" DbType="Boolean" />
                                    <asp:Parameter Name="CommonFields" DbType="Boolean" DefaultValue="true" />
                                </SelectParameters>
                                <UpdateParameters>
                                    <asp:Parameter Name="RequiredFieldId" DbType="Int32" />
                                    <asp:Parameter Name="Required" DbType="Boolean" />
                                </UpdateParameters>
                            </asp:ObjectDataSource>

                            <%--<telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" UpdateInitiatorPanelsOnly="true">
                                <AjaxSettings>
                                    <telerik:AjaxSetting AjaxControlID="RequiredFieldsGrid">
                                        <UpdatedControls>
                                            <telerik:AjaxUpdatedControl ControlID="RequiredFieldsGrid" />
                                        </UpdatedControls>
                                    </telerik:AjaxSetting>
                                    <telerik:AjaxSetting AjaxControlID="LoggedInUsersGrid">
                                        <UpdatedControls>
                                            <telerik:AjaxUpdatedControl ControlID="LoggedInUsersGrid" />
                                        </UpdatedControls>
                                    </telerik:AjaxSetting>
                                    <telerik:AjaxSetting AjaxControlID="LockedPatientsGrid">
                                        <UpdatedControls>
                                            <telerik:AjaxUpdatedControl ControlID="LockedPatientsGrid" />
                                        </UpdatedControls>
                                    </telerik:AjaxSetting>
                                </AjaxSettings>
                            </telerik:RadAjaxManager>--%>

                            <div style="margin-top: 5px;margin-left:10px;">
                                
                                <telerik:RadGrid ID="RequiredFieldsGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
                                    DataSourceID="ReqFieldsObjectDataSource" AllowFilteringByColumn="true"
                                    Skin="WebBlue" GridLines="None" PageSize="50" AllowPaging="true" Width="600px">
                                    <MasterTableView DataKeyNames="RequiredFieldId">
                                        <Columns>
                                            <telerik:GridBoundColumn UniqueName="ProcedureType" DataField="ProcedureType" HeaderText="Procedure" SortExpression="ProcedureType" HeaderStyle-Width="50px">
                                                <FilterTemplate>
                                                    <telerik:RadComboBox ID="ProcedureTypeComboBox" runat="server" AppendDataBoundItems="true" Skin="Windows7"
                                                        OnClientSelectedIndexChanged="ProcedureTypeChanged" 
                                                        OnSelectedIndexChanged="ProcedureTypeComboBox_SelectedIndexChanged" 
                                                        OnPreRender="ProcedureTypeComboBox_PreRender">
                                                    </telerik:RadComboBox>
                                                    <telerik:RadScriptBlock ID="ProcTypeRadScriptBlock" runat="server">
                                                        <script type="text/javascript">
                                                            function ProcedureTypeChanged(sender, args) {
                                                                var tableView = $find("<%# (DirectCast(Container, GridItem)).OwnerTableView.ClientID %>");
                                                                tableView.filter("ProcedureType", args.get_item().get_value(), "EqualTo");
                                                            }
                                                        </script>
                                                    </telerik:RadScriptBlock>
                                                </FilterTemplate>
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="PageName" HeaderText="Form" SortExpression="PageName" HeaderStyle-Width="80px" >
                                                <FilterTemplate>
                                                    <telerik:RadComboBox ID="PageNameComboBox" runat="server" AppendDataBoundItems="true" Skin="Windows7"
                                                        OnClientSelectedIndexChanged="PageNameChanged"
                                                        OnSelectedIndexChanged="PageNameComboBox_SelectedIndexChanged" 
                                                        OnPreRender="PageNameComboBox_PreRender">
                                                    </telerik:RadComboBox>
                                                    <telerik:RadScriptBlock ID="PageNameRadScriptBlock" runat="server">
                                                        <script type="text/javascript">
                                                            function PageNameChanged(sender, args) {
                                                                var tableView = $find("<%# (DirectCast(Container, GridItem)).OwnerTableView.ClientID %>");
                                                                tableView.filter("PageName", args.get_item().get_value(), "EqualTo");
                                                            }
                                                        </script>
                                                    </telerik:RadScriptBlock>
                                                </FilterTemplate>
                                            </telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="FieldName" HeaderText="Field" SortExpression="FieldName" HeaderStyle-Width="80px"  AllowFiltering="false" ></telerik:GridBoundColumn>
                                            <telerik:GridTemplateColumn UniqueName="RequiredColumn" DataField="Required" HeaderText="Required" SortExpression="Required" HeaderStyle-Width="25px"  AllowFiltering="false" >
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="RequiredCheckBox" runat="server" AutoPostBack="true" 
                                                        Checked='<%# Bind("Required") %>' Enabled='<%# Not Eval("CannotBeSuppressed") %>' 
                                                        OnCheckedChanged="RequiredCheckBox_CheckedChanged" />
                                                </ItemTemplate>
                                            </telerik:GridTemplateColumn>
                                        </Columns>
                                    </MasterTableView>
                                </telerik:RadGrid>
                                   
                            </div>
                        </div>
                    </telerik:RadPageView>
                    <telerik:RadPageView ID="SystemUsagePageView" runat="server">
                        <telerik:RadFormDecorator ID="SystemUsageFormDecorator" runat="server" DecoratedControls="All"
                            DecorationZoneID="SystemUsageDiv" Skin="Metro" />
                        <div class="optHeaderText">System Usage</div>
                        <div id="SystemUsageDiv">

                            <asp:ObjectDataSource ID="LoggedInUsersObjectDataSource" runat="server"
                                TypeName="Options" SelectMethod="GetLoggedInUsers" DeleteMethod="RemoveLoggedInUser">
                                <DeleteParameters>
                                    <asp:Parameter Name="userId" DbType="Int32" />
                                </DeleteParameters>
                            </asp:ObjectDataSource>

                            <div style="margin-top: 5px;margin-left:10px;">
                                <div class="divTileHeading" style="margin-top: 10px;margin-bottom: 10px;">
                                    <b>Logged In Users</b>
                                </div>
                                <telerik:RadGrid ID="LoggedInUsersGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
                                    DataSourceID="LoggedInUsersObjectDataSource" AllowAutomaticDeletes="True"
                                    Skin="WebBlue" GridLines="None" PageSize="50" AllowPaging="true" Width="600px">
                                    <MasterTableView DataKeyNames="UserId" TableLayout="Fixed">
                                        <Columns>
                                            <telerik:GridBoundColumn DataField="Username" HeaderText="User ID" SortExpression="Username" HeaderStyle-Width="50px"></telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="User" HeaderText="User" SortExpression="User" HeaderStyle-Width="80px"></telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="LastLoggedIn" HeaderText="Logged in at" SortExpression="LastLoggedIn" HeaderStyle-Width="50px"></telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="IsReadOnly" HeaderText="Readonly" SortExpression="IsReadOnly" HeaderStyle-Width="30px"></telerik:GridBoundColumn>
                                            <%--<telerik:GridButtonColumn CommandName="Delete" Text="Logoff" ImageUrl="~/Images/NewLogo_138_58.png" 
                                                ConfirmText="Are you sure you want to logout this user?" HeaderStyle-Width="20px"></telerik:GridButtonColumn>--%>
                                            <telerik:GridTemplateColumn UniqueName="DeleteTemplateColumn" ItemStyle-HorizontalAlign="Center" HeaderText="Logoff" HeaderStyle-Width="20px">
                                                <ItemTemplate>
                                                    <asp:ImageButton ID="ImageButton1" runat="server" ImageUrl="~/Images/Log Out_24x24.png" CommandName="Delete" ToolTip="Remove this login"
                                                        OnClientClick="javascript:if(!confirm('Are you sure you want to logout this user?')){return false;}" Height="20px" Width="20px"/>
                                                </ItemTemplate>
                                            </telerik:GridTemplateColumn>
                                        </Columns>
                                        <NoRecordsTemplate>
                                            <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;">
                                                No users currently logged in
                                            </div>
                                        </NoRecordsTemplate>
                                    </MasterTableView>
                                </telerik:RadGrid>
                            </div>

                            <br /><br /><br />

                            <asp:ObjectDataSource ID="LockedPatientsObjectDataSource" runat="server"
                                TypeName="Options" SelectMethod="GetLockedPatients" DeleteMethod="UpdateLockedPatients">
                                <DeleteParameters>
                                    <asp:Parameter Name="patientId" DbType="Int32" />
                                </DeleteParameters>
                            </asp:ObjectDataSource>

                            <div style="margin-top: 5px;margin-left:10px;">
                                <div class="divTileHeading" style="margin-top: 10px;margin-bottom: 10px;">
                                    <b>Locked Patient Records</b>
                                </div>
                                <telerik:RadGrid ID="LockedPatientsGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
                                    DataSourceID="LockedPatientsObjectDataSource" AllowAutomaticDeletes="True"
                                    Skin="WebBlue" GridLines="None" PageSize="50" AllowPaging="true" Width="600px">
                                    <MasterTableView DataKeyNames="PatientId" TableLayout="Fixed">
                                        <Columns>
                                            <telerik:GridBoundColumn DataField="PatientName" HeaderText="Patient" SortExpression="PatientName" HeaderStyle-Width="80px"></telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="LockedBy" HeaderText="Locked By" SortExpression="LockedBy" HeaderStyle-Width="100px"></telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn DataField="LockedOn" HeaderText="Locked On" SortExpression="LockedOn" HeaderStyle-Width="50px"></telerik:GridBoundColumn>
                                            <%--<telerik:GridButtonColumn CommandName="Delete" HeaderText="Unlock" Text="Unlock" ImageUrl="~/Images/NewLogo_138_58.png" 
                                                ConfirmText="Are you sure you want to unlock this patient?" ItemStyle-Width="5px"></telerik:GridButtonColumn>--%>
                                            <telerik:GridTemplateColumn UniqueName="UnlockTemplateColumn" ItemStyle-HorizontalAlign="Center" HeaderText="Unlock" HeaderStyle-Width="25px">
                                                <ItemTemplate>
                                                    <asp:ImageButton ID="UnlockImageButton" runat="server" ImageUrl="~/Images/Lock-Unlock-48x48.png" CommandName="Delete" ToolTip="Unlock this record"
                                                        OnClientClick="javascript:if(!confirm('Are you sure you want to unlock this patient?')){return false;}" 
                                                        Height="20px" Width="20px"/>
                                                </ItemTemplate>
                                            </telerik:GridTemplateColumn>
                                        </Columns>
                                        <NoRecordsTemplate>
                                            <div style="margin-top: 10px; margin-bottom: 10px;margin-left:5px;">
                                                No patient records are currently being used (locked)
                                            </div>
                                        </NoRecordsTemplate>
                                    </MasterTableView>
                                </telerik:RadGrid>
                            </div>
                        </div>
                    </telerik:RadPageView>
                    <telerik:RadPageView ID="rvPage6" runat="server">
                        <telerik:RadFormDecorator ID="UserMaintenanceRadFormDecorator" runat="server" DecoratedControls="All"
                            DecorationZoneID="UserMaintenanceDiv" Skin="Web20" />
                        <div class="optHeaderText">User Maintenance</div>
                        <div id="UserMaintenanceDiv">

                            <asp:ObjectDataSource ID="UsersObjectDataSource" runat="server" SelectMethod="GetUsers" TypeName="Options">
                                <SelectParameters>
                                    <asp:ControlParameter Name="SearchPhrase" DbType="String" ControlID="UserSearchTextBox" ConvertEmptyStringToNull="true" />
                                </SelectParameters>
                            </asp:ObjectDataSource>

                            <asp:ObjectDataSource ID="UserDetailsObjectDataSource" runat="server"
                                TypeName="UnisoftERS.DataAccess" SelectMethod="GetUser" UpdateMethod="UpdateUser" InsertMethod="InsertUser">
                                <SelectParameters>
                                    <asp:Parameter Name="UserId" DbType="Int32" DefaultValue="0" />
                                </SelectParameters>
                                <UpdateParameters>
                                    <asp:Parameter Name="UserId" DbType="Int32" DefaultValue="0" />
                                    <asp:Parameter Name="Username" DbType="String" DefaultValue="" />
                                    <asp:Parameter Name="Title" DbType="String" DefaultValue="" />
                                    <asp:Parameter Name="Forename" DbType="String" DefaultValue="" />
                                    <asp:Parameter Name="Surname" DbType="String" DefaultValue="" />
                                    <asp:Parameter Name="Initials" DbType="String" DefaultValue="" />
                                    <asp:Parameter Name="Qualifications" DbType="String" DefaultValue="" />
                                    <asp:Parameter Name="JobTitle" DbType="String" DefaultValue="" />
                                    <asp:Parameter Name="AccessRights" DbType="Int32" DefaultValue="0" />
                                    <asp:Parameter Name="DeletePatients" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="ModifyTables" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="CanRunAK" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="IsListConsultant" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="IsEndoscopist1" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="IsEndoscopist2" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="AssistantOrTrainee" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="Nurse1" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="Nurse2" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="Active" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="Suppressed" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="ExpiresOn" DbType="Date" />
                                </UpdateParameters>
                                <InsertParameters>
                                    <asp:Parameter Name="Username" DbType="String" DefaultValue="" />
                                    <asp:Parameter Name="ExpiresOn" DbType="Date" />
                                    <asp:Parameter Name="Title" DbType="String" DefaultValue="" />
                                    <asp:Parameter Name="Forename" DbType="String" DefaultValue="" />
                                    <asp:Parameter Name="Surname" DbType="String" DefaultValue="" />
                                    <asp:Parameter Name="Initials" DbType="String" DefaultValue="" />
                                    <asp:Parameter Name="Qualifications" DbType="String" DefaultValue="" />
                                    <asp:Parameter Name="JobTitle" DbType="String" DefaultValue="" />
                                    <asp:Parameter Name="AccessRights" DbType="Int32" DefaultValue="0" />
                                    <asp:Parameter Name="DeletePatients" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="ModifyTables" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="CanRunAK" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="IsListConsultant" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="IsEndoscopist1" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="IsEndoscopist2" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="AssistantOrTrainee" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="Nurse1" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="Nurse2" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="Active" DbType="Boolean" DefaultValue="False" />
                                    <asp:Parameter Name="Suppressed" DbType="Boolean" DefaultValue="False" />
                                </InsertParameters>
                            </asp:ObjectDataSource>

                            <div style="margin-top: 5px;margin-left:10px;" class="rptText">
                                <asp:Panel ID="Panel1" runat="server" DefaultButton="UserSearchButton">
                                    <table id="UserSearchTable" runat="server" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td style="padding-right: 5px;">
                                                Search by User ID / Name:
                                            </td>
                                            <td style="padding-right: 10px;">
                                                <telerik:RadTextBox ID="UserSearchTextBox" runat="server" Skin="Windows7" Width="200" /></td>
                                            <td style="padding-right: 5px;">
                                                <telerik:RadButton ID="UserSearchButton" runat="server" Text="Search" Skin="WebBlue" />
                                            </td>
                                            <td>
                                                <telerik:RadButton ID="UserSearchClearButton" runat="server" Text="Clear" Skin="WebBlue" />
                                            </td>
                                        </tr>
                                    </table>
                                </asp:Panel>

                                <div style="margin-top: 5px;">
                                    <telerik:RadGrid ID="UsersRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false"
                                        DataSourceID="UsersObjectDataSource" MasterTableView-DataKeyNames="UserId"
                                        CellSpacing="0" GridLines="None" Skin="Office2010Blue" PageSize="50" AllowPaging="true" Height="220px" Width="900px"
                                        OnSelectedIndexChanged="UsersRadGrid_SelectedIndexChanged">
                                        <HeaderStyle Font-Bold="true" Height="12px" />
                                        <MasterTableView ShowHeadersWhenNoRecords="true">
                                            <Columns>
                                                <telerik:GridTemplateColumn ItemStyle-HorizontalAlign="Center" HeaderText="" HeaderStyle-Width="50px" HeaderStyle-Wrap="false">
                                                <ItemTemplate>
                                                    <asp:ImageButton ID="ImageButton1" runat="server" ImageUrl="~/Images/edit.png" CommandName="Delete" ToolTip="Edit user details"
                                                        Width="15px"/>
                                                    <asp:ImageButton ID="ImageButton2" runat="server" ImageUrl="~/Images/stop.png" CommandName="Delete" ToolTip="Suppress this user"
                                                        OnClientClick="javascript:if(!confirm('Are you sure you want to suppress this user?')){return false;}" Width="15px"/>
                                                </ItemTemplate>
                                            </telerik:GridTemplateColumn>
                                                <telerik:GridBoundColumn DataField="UserName" HeaderText="User ID" SortExpression="UserName" HeaderStyle-Width="120px"></telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn DataField="Name" HeaderText="Name" SortExpression="Name" HeaderStyle-Width="200px"></telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn DataField="AccessRights" HeaderText="Access Rights" SortExpression="AccessRights"></telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn DataField="ModifyTables" HeaderText="Modify Tables" SortExpression="ModifyTables"></telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn DataField="DeletePatients" HeaderText="Delete Patients" SortExpression="DeletePatients"></telerik:GridBoundColumn>
                                                <telerik:GridBoundColumn DataField="Suppressed" HeaderText="Suppressed" SortExpression="Suppressed"></telerik:GridBoundColumn>
                                            </Columns>
                                            <NoRecordsTemplate>
                                                <div style="margin-left: 5px;">No records found</div>
                                            </NoRecordsTemplate>
                                        </MasterTableView>
                                        <PagerStyle Mode="NextPrev" />
                                        <ClientSettings EnablePostBackOnRowClick="true">
                                            <Selecting AllowRowSelect="True" />
                                            <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                        </ClientSettings>
                                    </telerik:RadGrid>
                                </div>

                                <asp:FormView ID="UserDetailsFormView" runat="server"
                                    DataSourceID="UserDetailsObjectDataSource" DataKeyNames="UserId" BorderStyle="None">
                                    <EditItemTemplate>
                                        
                                                <table id="dsa" runat="server" cellpadding="2" cellspacing="2">
                                                    <tr>
                                                        <td colspan="10">
                                                            <span class="subheader">
                                                                <b>User Details</b>
                                                            </span>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td width="70px">Title:
                                                        </td>
                                                        <td>
                                                            <telerik:RadTextBox ID="TitleTextBox" Text='<%# Bind("Title") %>' runat="Server" Width="50px" />
                                                        </td>
                                                        <td>Forename:
                                                        </td>
                                                        <td>
                                                            <telerik:RadTextBox ID="ForenameTextBox" Text='<%# Bind("Forename") %>' runat="Server" />
                                                        </td>
                                                        <td>Surname:
                                                        </td>
                                                        <td>
                                                            <telerik:RadTextBox ID="SurnameTextBox" Text='<%# Bind("Surname") %>' runat="Server"  />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>User Id:
                                                        </td>
                                                        <td>
                                                            <telerik:RadTextBox ID="UserIdTextBox" Text='<%# Bind("UserName") %>' runat="Server" />
                                                        </td>
                                                        <td>Expires On:
                                                        </td>
                                                        <td>
                                                            <telerik:RadDatePicker ID="ExpiresOnDatePicker" SelectedDate='<%# Bind("ExpiresOn") %>' runat="server" 
                                                                MinDate='<%# DateTime.Now.Date() %>' MaxDate="01/01/3000" Calendar-ShowRowHeaders="false"></telerik:RadDatePicker>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td valign="top">Permissions:
                                                        </td>
                                                        <td valign="top">
                                                            <telerik:RadDropDownList ID="PermissionsDropDownList" runat="server" SelectedValue='<%# Bind("AccessRights") %>'>
                                                                <Items>
                                                                    <telerik:DropDownListItem />
                                                                    <telerik:DropDownListItem Text="Read Only" Value="1"></telerik:DropDownListItem>
                                                                    <telerik:DropDownListItem Text="Regular" Value="2"></telerik:DropDownListItem>
                                                                    <telerik:DropDownListItem Text="Administrator" Value="3"></telerik:DropDownListItem>
                                                                </Items>
                                                            </telerik:RadDropDownList>
                                                        </td>
                                                        <td colspan="10">
                                                            <table>
                                                                <tr>
                                                                    <td>
                                                                        <asp:CheckBox ID="ModifyTablesCheckBox" runat="server" Text="Can add/modify reference tables" Checked='<%# Bind("ModifyTables") %>' />
                                                                    </td>
                                                                    <td>
                                                                        <asp:CheckBox ID="DeletePatientsCheckBox" runat="server" Text="Can delete patients" Checked='<%# Bind("DeletePatients") %>' />
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <asp:CheckBox ID="ActiveCheckBox" runat="server" Text="Lock System Access" Checked='<%# Bind("Active")%>' />
                                                                    </td>
                                                                    <td>
                                                                        <asp:CheckBox ID="SuppressedCheckBox" runat="server" Text="Suppressed" Checked='<%# Bind("Suppressed") %>' />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                    <%--<tr>
                                                    <td colspan="10">
                                                        <hr />
                                                    </td>
                                                </tr>--%>
                                                    <tr>
                                                        <td colspan="10">
                                                            <span class="subheader">
                                                                <b>Staff Details</b>
                                                            </span>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Title:
                                                        </td>
                                                        <td colspan="10">
                                                            <telerik:RadDropDownList ID="TitleRadDropDownList" runat="server"></telerik:RadDropDownList>
                                                            <telerik:RadButton ID="AddNedwRadButton" runat="server" Text="Add New"
                                                                OnClientClicked="openAddTitleWindow" AutoPostBack="false"
                                                                Skin="WebBlue" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Qualifications:
                                                        </td>
                                                        <td>
                                                            <telerik:RadTextBox ID="QualificationsRadTextBox" Text='<%# Bind("Qualifications") %>' runat="Server" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td valign="top" nowrap>Can appear as:
                                                        </td>
                                                        <td colspan="10">
                                                            <table>
                                                                <tr>
                                                                    <td>
                                                                        <asp:CheckBox ID="ListConsultantCheckBox" runat="server" Text="List Consultant" Checked='<%# Bind("IsListConsultant") %>' />
                                                                    </td>
                                                                    <td>
                                                                        <asp:CheckBox ID="AssistantTraineeCheckBox" runat="server" Text="Assistant/Trainee" Checked='<%# Bind("AssistantOrTrainee")%>' />
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <asp:CheckBox ID="Endoscopist1" runat="server" Text="Endoscopist 1" Checked='<%# Bind("IsEndoscopist1") %>' />
                                                                    </td>
                                                                    <td>
                                                                        <asp:CheckBox ID="Nurse1CheckBox" runat="server" Text="Nurse 1" Checked='<%# Bind("Nurse1") %>' />
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <asp:CheckBox ID="Endoscopist2" runat="server" Text="Endoscopist 2" Checked='<%# Bind("IsEndoscopist2") %>' />
                                                                    </td>
                                                                    <td>
                                                                        <asp:CheckBox ID="Nurse2CheckBox" runat="server" Text="Nurse 2" Checked='<%# Bind("Nurse2") %>' />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            <br />
                                                <div id="buttonsdiv" style="height: 10px; margin-left: 5px; padding-top: 6px; vertical-align: central;">
                                                    <telerik:RadButton ID="UpdateButton" runat="server" Text="Save" Skin="Web20" CommandName="Update" />
                                                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" CommandName="Cancel" />
                                                </div>
                                    </EditItemTemplate>
                                </asp:FormView>
                            </div>
                            <telerik:RadWindowManager ID="AddNewTitleRadWindowManager" runat="server" ShowContentDuringLoad="false"
                                Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
                                <Windows>
                                    <telerik:RadWindow ID="AddNewTitleRadWindow" runat="server" ReloadOnShow="true"
                                        KeepInScreenBounds="true" Width="400px" Height="180px">
                                        <ContentTemplate>
                                            <table cellspacing="3" cellpadding="3">
                                                <tr>
                                                    <td>
                                                        <b>Add new title</b>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <telerik:RadTextBox ID="AddNewTitleRadTextBox" runat="Server" Width="300px" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <div id="buttonsdiv" style="height: 10px; padding-top: 6px; vertical-align: central;">
                                                            <telerik:RadButton ID="AddNewTitleSaveRadButton" runat="server" Text="Save" Skin="WebBlue" />
                                                            <telerik:RadButton ID="AddNewTitleCancelRadButton" runat="server" Text="Cancel" Skin="WebBlue" OnClientClicked="closeAddTitleWindow" />
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </ContentTemplate>
                                    </telerik:RadWindow>
                                </Windows>
                            </telerik:RadWindowManager>
                        </div>
                    </telerik:RadPageView>
                </telerik:RadMultiPage>
            </telerik:RadPane>
        </telerik:RadSplitter>
</asp:Content>
