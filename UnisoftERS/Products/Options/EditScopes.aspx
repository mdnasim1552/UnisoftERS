<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_EditScopes" CodeBehind="EditScopes.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Scope Details</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/global.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">

            var AddNewItemRadTextBoxClientId = "<%= AddNewItemRadTextBox.ClientID %>";
            var AddNewItemRadWindowClientId = "<%= AddNewItemRadWindow.ClientID %>";


            function newWindowOpening() {
                $find(AddNewItemRadTextBoxClientId).set_value("");
            }

            $(window).on('load', function () {
            });

            $(document).ready(function () {

            });

            function CheckForValidPage() {
                var valid = Page_ClientValidate("SaveScope");
                if (!valid) {
                    $("#<%=ServerErrorLabel.ClientID%>").hide();
                    $find("<%=ValidationNotification.ClientID%>").show();
                }
            }

            function ValidateProcedureTypes(source, args) {
                var listbox = $find('<%= ProcedureTypeRadListBox.ClientID %>');
                var check = 0;
                var items = listbox.get_items();
                for (var i = 0; i <= items.get_count() - 1; i++) {
                    var item = items.getItem(i);
                    if (item.get_checked()) {
                        check = 1;
                    }
                }
                if (check)
                    args.IsValid = true;
                else
                    args.IsValid = false;
            }
            function ValidateHospitals(source, args) {

                var hlistbox = $find('<%= HospitalListBox.ClientID %>');
                var check = 0;
                var hitems = hlistbox.get_items();


                for (var i = 0; i <= hitems.get_count() - 1; i++) {
                    var hitem = hitems.getItem(i);

                    if (hitem.get_checked()) {

                        check = 1;
                    }


                }

                if (check)
                    args.IsValid = true;
                else
                    args.IsValid = false;


            }
            function CloseAndRebind(args) {
                GetRadWindow().BrowserWindow.refreshGrid(args);
                GetRadWindow().close();
            }

            function GetRadWindow() {
                var oWindow = null;
                if (window.radWindow) oWindow = window.radWindow; //Will work in Moz in all cases, including clasic dialog
                else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow; //IE (and Moz as well)

                return oWindow;
            }

        </script>
    </telerik:RadScriptBlock>
</head>

<body>
    <script type="text/javascript">
</script>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />

        <telerik:RadFormDecorator ID="UserMaintenanceRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Metro">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="480px" Scrolling="None">
                <asp:ObjectDataSource ID="HospitalObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetOperatingHospitals" />
                <asp:ObjectDataSource ID="ScopeProcedureObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetScopeProcedureTypes">
                    <SelectParameters>
                        <asp:Parameter Name="ScopeId" DbType="Int32" DefaultValue="0" />
                    </SelectParameters>
                </asp:ObjectDataSource>

                <telerik:RadAjaxManager ID="RadAjaxMAnager1" runat="server">
                    <AjaxSettings>
                        <telerik:AjaxSetting AjaxControlID="ScopeManufacturerComboBox">
                            <UpdatedControls>
                                <telerik:AjaxUpdatedControl ControlID="ScopeManufacturerComboBox" />
                                <telerik:AjaxUpdatedControl ControlID="ScopeGenerationComboBox" />
                                <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                            </UpdatedControls>
                        </telerik:AjaxSetting>
                        <telerik:AjaxSetting AjaxControlID="ScopeGenerationComboBox">
                            <UpdatedControls>
                                <telerik:AjaxUpdatedControl ControlID="ScopeGenerationComboBox" />
                                <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                            </UpdatedControls>
                        </telerik:AjaxSetting>
                    </AjaxSettings>
                </telerik:RadAjaxManager>
                <div id="FormDiv" runat="server">
                    <div style="margin-left: 10px; padding-top: 15px" class="rptText">

                        <table>
                            <tr>
                                <td valign="top">
                                    <asp:Label runat="server" Text="Model and serial number" Width="120px" /><asp:TextBox ID="ScopeNameTextBox" runat="server" Width="200" />
                                    <asp:Label runat="server" Text="(e.g XQ230 - 6012345)" Width="120px" ForeColor="Gray" />
                                    <asp:RequiredFieldValidator ID="ScopeNameRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                        ControlToValidate="ScopeNameTextBox" EnableClientScript="true" Display="Dynamic"
                                        ErrorMessage="Scope name is required" Text="*" ToolTip="This is a required field"
                                        ValidationGroup="SaveScope">
                                    </asp:RequiredFieldValidator>
                                    <br />
                                    <div>
                                        <telerik:RadListBox ID="HospitalListBox" runat="server" CheckBoxes="true" ShowCheckAll="true" Width="270" Height="250px" />
                                        <asp:CustomValidator ID="HospitalListBoxValidator" runat="server" CssClass="aspxValidator"
                                            ClientValidationFunction="ValidateHospitals" EnableClientScript="true" Display="Dynamic"
                                            ErrorMessage="At least 1 Hospital is required" Text="*" ToolTip="This is a required field"
                                            ValidationGroup="SaveScope">
                                        </asp:CustomValidator>
                                    </div>
                                    <br />
                                    <asp:Label runat="server" Text="Manufacturer" Width="120px" />
                                    <telerik:RadComboBox ID="ScopeManufacturerComboBox" runat="server" Width="200" DataTextField="Description" DataValueField="UniqueId" AutoPostBack="true" AppendDataBoundItems="true" OnSelectedIndexChanged="ScopeManufacturerComboBox_SelectedIndexChanged">
                                        <Items>
                                            <telerik:RadComboBoxItem Value="0" Text="" />
                                        </Items>
                                    </telerik:RadComboBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" CssClass="aspxValidator"
                                        ControlToValidate="ScopeManufacturerComboBox" EnableClientScript="true" Display="Dynamic"
                                        ErrorMessage="Scope manufacturer is required" Text="*" ToolTip="This is a required field"
                                        ValidationGroup="SaveScope">
                                    </asp:RequiredFieldValidator>
                                    <br />
                                    <br />
                                    <asp:Label runat="server" Text="Generation" Width="120px" />
                                    <telerik:RadComboBox ID="ScopeGenerationComboBox" runat="server" Width="200" DataTextField="Description" DataValueField="UniqueId" AppendDataBoundItems="false">
                                        <Items>
                                            <telerik:RadComboBoxItem Value="0" Text="" />
                                        </Items>
                                    </telerik:RadComboBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" CssClass="aspxValidator"
                                        ControlToValidate="ScopeGenerationComboBox" EnableClientScript="true" Display="Dynamic"
                                        ErrorMessage="Scope generation is required" Text="*" ToolTip="This is a required field"
                                        ValidationGroup="SaveScope">
                                    </asp:RequiredFieldValidator>
                                    <br />
                                    <br />
                                    <div id="cmdOtherData" style="height: 10px; margin-left: 10px; position: absolute; bottom: 35px;">
                                        <telerik:RadButton ID="SaveButton" runat="server" Text="Save & Close" Skin="Metro" OnClick="SaveScope" CausesValidation="true" OnClientClicked="CheckForValidPage" Icon-PrimaryIconCssClass="telerikSaveButton" />
                                        <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Metro" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                                    </div>
                                </td>
                                <td valign="top">
                                    <div style="padding-right: 40px;">
                                        <fieldset>
                                            <legend>&nbsp;Used in&nbsp;</legend>
                                            <div style="padding: 10px">
                                                <telerik:RadListBox ID="ProcedureTypeRadListBox" runat="server" CheckBoxes="true" ShowCheckAll="true" Width="320" DataTextField="ProcedureType" DataValueField="ProcedureTypeID" DataSourceID="ScopeProcedureObjectDataSource" Height="400px" />
                                                <asp:CustomValidator ID="ProcedureTypeRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                    ClientValidationFunction="ValidateProcedureTypes" EnableClientScript="true" Display="Dynamic"
                                                    ErrorMessage="At least 1 procedure type is required" Text="*" ToolTip="This is a required field"
                                                    ValidationGroup="SaveScope">
                                                </asp:CustomValidator>
                                            </div>
                                        </fieldset>
                                    </div>
                                </td>
                            </tr>

                        </table>

                        <div style="padding-bottom: 5px; float: left;">
                        </div>

                    </div>

                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>


        <telerik:RadNotification ID="ValidationNotification" runat="server" Animation="None" Width="400"
            EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
            LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
            AutoCloseDelay="7000">
            <ContentTemplate>
                <asp:ValidationSummary ID="SaveScopeValidationSummary" runat="server" ValidationGroup="SaveScope" DisplayMode="BulletList"
                    EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                <asp:Label ID="ServerErrorLabel" runat="server" CssClass="aspxValidationSummary" Visible="false"></asp:Label>
            </ContentTemplate>
        </telerik:RadNotification>

        <telerik:RadWindowManager ID="RadWindowManager1" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move, Resize" Skin="Metro" EnableShadow="true" Modal="true">
            <Windows>
                <telerik:RadWindow ID="AddNewItemRadWindow" runat="server" ReloadOnShow="true" VisibleStatusbar="false" Title="Add new Item"
                    KeepInScreenBounds="true" Width="400px" Height="150px" OnClientClose="AddNewItemWindowClientClose" OnClientBeforeShow="newWindowOpening">
                    <ContentTemplate>
                        <table cellspacing="3" cellpadding="3" style="width: 100%">
                            <tr>
                                <td>
                                    <br />
                                    <div class="left">
                                        <asp:RequiredFieldValidator ID="AddNewRequiredFieldValidator" runat="server" ValidationGroup="addnew" ControlToValidate="AddNewItemRadTextBox" ErrorMessage="" ForeColor="Red" />
                                        <telerik:RadTextBox ID="AddNewItemRadTextBox" runat="Server" Width="250px" />
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div id="buttonsdiv" style="height: 10px; padding-top: 16px;">
                                        <telerik:RadButton ID="AddNewItemSaveRadButton" runat="server" Text="Add" Skin="WebBlue" AutoPostBack="false" OnClientClicked="AddNewItem" ButtonType="SkinnedButton" ValidationGroup="addnew" />
                                        &nbsp;&nbsp;
                                        <telerik:RadButton ID="AddNewItemCancelRadButton" runat="server" Text="Cancel" Skin="WebBlue" AutoPostBack="false" OnClientClicked="CancelAddNewItem" ButtonType="SkinnedButton" />
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
    </form>
</body>
</html>
