<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="EditNonGIConsultant.aspx.vb" Inherits="UnisoftERS.EditNonGIConsultant" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Consultant details form</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />

    <script src="../../../Scripts/global.js"></script>
    <script src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <link href="../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {

            });

            $(document).ready(function () {
            });



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

            function CancelEdit() {
                GetRadWindow().BrowserWindow.refreshGrid();
                GetRadWindow().close();
            }

        </script>
    </telerik:RadScriptBlock>
</head>
<body>
    <form id="form1" runat="server">

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <div class="optionsHeading">
            <asp:Label ID="HeadingLabel" runat="server" Text="Edit Consultant"></asp:Label>
        </div>

        <telerik:RadFormDecorator ID="UserMaintenanceRadFormDecorator" runat="server" DecoratedControls="All"
            DecorationZoneID="FormDiv" Skin="Metro" />


        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" AutoCloseDelay="0" />

        <div id="FormDiv">
            <div style="margin-top: 5px; margin-left: 10px; margin-bottom: 10px;" class="rptText">
                <asp:FormView ID="ConsultantDetailsFormView" runat="server"
                    DataSourceID="NonGIConsultantsDatasource" DataKeyNames="UserId" BorderStyle="None"
                    OnItemInserting="ConsultantDetailsFormView_ItemInserting"
                    OnItemUpdating="ConsultantDetailsFormView_ItemUpdating">
                    <EditItemTemplate>
                        <table id="dsa" runat="server" cellpadding="2" cellspacing="2">
                            <tr>
                                <td width="70px">
                                    <telerik:RadLabel ID="TitleLabel" runat="server" Text="Title:" Skin="Metro" />
                                </td>
                                <td>
                                    <telerik:RadTextBox ID="TitleTextBox" Text='<%# Bind("Title") %>' runat="Server" Width="50px" Skin="Metro" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <telerik:RadLabel ID="ForenameLabel" runat="server" Text="Forename:" Skin="Metro" />
                                </td>
                                <td>
                                    <telerik:RadTextBox ID="ForenameTextBox" Text='<%# Bind("Forename") %>' runat="Server" Skin="Metro" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <telerik:RadLabel ID="SurnameLabel" runat="server" Text="Surname:" Skin="Metro" />
                                </td>
                                <td>
                                    <telerik:RadTextBox ID="SurnameTextBox" Text='<%# Bind("Surname") %>' runat="Server" Skin="Metro" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <telerik:RadLabel ID="GMCLabel" runat="server" Text="GMC Code:" Skin="Metro" />
                                </td>
                                <td>
                                    <telerik:RadTextBox ID="GMCCodeTextBox" Text='<%# Bind("GMCCode") %>' runat="Server" Skin="Metro" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <telerik:RadLabel ID="StaffTitleLabel" runat="server" Text="Job Title:" Skin="Metro" />
                                    <asp:RequiredFieldValidator runat="server" Text="*" ControlToValidate="TitleRadDropDownList" ForeColor="Red" />
                                </td>
                                <td colspan="10">
                                    <telerik:RadDropDownList ID="TitleRadDropDownList" runat="server" Skin="Metro" AppendDataBoundItems="true">
                                        <Items>
                                            <telerik:DropDownListItem Text="" Value="0" />
                                        </Items>
                                    </telerik:RadDropDownList>
                                </td>
                            </tr>
                        </table>
                        <br />
                        <div id="buttonsdiv" style="height: 10px; margin-left: 5px; margin-bottom: 10px; padding-top: 6px; vertical-align: central;">
                            <table style="width: 100%;">
                                <tr>
                                    <td>
                                        <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Metro" Visible="false" />
                                        <telerik:RadButton ID="SaveAndCloseButton" runat="server" Text="Save & Close" Skin="Metro" Icon-PrimaryIconCssClass="telerikSaveButton" AutoPostBack="true" />
                                        <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Metro" AutoPostBack="false" OnClientClicked="CancelEdit" Icon-PrimaryIconCssClass="telerikCancelButton"
                                            CausesValidation="false" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </EditItemTemplate>
                </asp:FormView>
            </div>
        </div>

        <asp:ObjectDataSource ID="NonGIConsultantsDatasource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetNonGIConsultant" UpdateMethod="UpdateUser" InsertMethod="InsertUser">
            <SelectParameters>
                <asp:Parameter Name="UserId" DbType="Int32" DefaultValue="0" />
            </SelectParameters>
            <UpdateParameters>
                 <asp:Parameter Name="UserId" DbType="Int32" DefaultValue="0" />
                <asp:Parameter Name="Username" DbType="String" DefaultValue="" />
                <asp:Parameter Name="ExpiresOn" DbType="Date" />
                <asp:Parameter Name="Title" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Forename" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Surname" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Initials" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Qualifications" DbType="String" DefaultValue="" />
                <asp:Parameter Name="isGIConsultant" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="JobTitleId" DbType="Int32" DefaultValue="0" />
                <asp:Parameter Name="RoleID" DbType="String" DefaultValue="7" />
                <asp:Parameter Name="CanRunAK" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsListConsultant" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsEndoscopist1" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsEndoscopist2" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsAssistantOrTrainee" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsNurse1" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsNurse2" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="Suppressed" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="ShowTooltips" DbType="Boolean" DefaultValue="True" />
                <asp:Parameter Name="CanEditDropdowns" DbType="Boolean" DefaultValue="True" />
                <asp:Parameter Name="CanViewAllUserAudits" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="GMCCode" DbType="String" DefaultValue="" ConvertEmptyStringToNull="false" />
            </UpdateParameters>
            <InsertParameters>
                <asp:Parameter Name="Username" DbType="String" DefaultValue="" />
                <asp:Parameter Name="ExpiresOn" DbType="Date" />
                <asp:Parameter Name="Title" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Forename" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Surname" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Initials" DbType="String" DefaultValue="" />
                <asp:Parameter Name="Qualifications" DbType="String" DefaultValue="" />
                <asp:Parameter Name="isGIConsultant" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="JobTitleId" DbType="Int32" DefaultValue="0" />
                <asp:Parameter Name="RoleID" DbType="String" DefaultValue="7" />
                <asp:Parameter Name="CanRunAK" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsListConsultant" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsEndoscopist1" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsEndoscopist2" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsAssistantOrTrainee" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsNurse1" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="IsNurse2" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="Suppressed" DbType="Boolean" DefaultValue="False" />
                <asp:Parameter Name="ShowTooltips" DbType="Boolean" DefaultValue="True" />
                <asp:Parameter Name="CanEditDropdowns" DbType="Boolean" DefaultValue="True" />
                <asp:Parameter Name="GMCCode" DbType="String" DefaultValue="" ConvertEmptyStringToNull="false" />
                <asp:Parameter Name="UserId" DbType="Int32" DefaultValue="0" Direction="Output" />
                <asp:Parameter Name="CanViewAllUserAudits" DbType="Boolean" DefaultValue="False" />
            </InsertParameters>
        </asp:ObjectDataSource>

    </form>
</body>
</html>
