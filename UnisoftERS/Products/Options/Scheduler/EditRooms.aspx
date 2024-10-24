<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_Scheduler_EditRooms" CodeBehind="EditRooms.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Room Details</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
            });

            $(document).ready(function () {

            });

            function CheckForValidPage() {
                var valid = Page_ClientValidate("SaveRoom");
                if (!valid) {
                    $("#<%=ServerErrorLabel.ClientID%>").hide();
                    $find("<%=ValidationNotification.ClientID%>").show();
                }
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
                <asp:ObjectDataSource ID="RoomProcedureObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetRoomProcedureTypes">
                    <SelectParameters>
                        <asp:Parameter Name="RoomId" DbType="Int32" DefaultValue="0" />
                    </SelectParameters>
                </asp:ObjectDataSource>

                <div id="FormDiv" runat="server">
                    <div style="margin-left: 10px; padding-top: 15px" class="rptText">

                        <table>
                            <tr>
                                <td valign="top">
                                    <asp:Label runat="server" Text="Room name" Width="120px" />
                                    <asp:TextBox ID="RoomNameTextBox" runat="server" Width="200" />
                                    <asp:RequiredFieldValidator ID="RoomNameRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                        ControlToValidate="RoomNameTextBox" EnableClientScript="true" Display="Dynamic"
                                        ErrorMessage="Room name is required" Text="*" ToolTip="This is a required field"
                                        ValidationGroup="SaveRoom">
                                    </asp:RequiredFieldValidator>
                                    <br />
                                    <br />
                                    <asp:Label runat="server" Text="Room sort order"/><br />
                                    <asp:TextBox ID="RoomSortOrderTextBox" runat="server" Width="40" />
                                    <asp:RequiredFieldValidator ID="RoomSortOrderRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                                ControlToValidate="RoomSortOrderTextBox" EnableClientScript="true" Display="Dynamic"
                                                                ErrorMessage="Room sort order is required" Text="*" ToolTip="This is a required field"
                                                                ValidationGroup="SaveRoom">
                                    </asp:RequiredFieldValidator>
                                    <br />
                                    <br />
                                    <asp:Label runat="server" Text="Hospital" Width="120px" />
                                    <telerik:RadDropDownList ID="HospitalDropDownList" runat="server" Width="200" DataTextField="HospitalName" DefaultMessage="Select a hospital" DataValueField="OperatingHospitalID" DataSourceID="HospitalObjectDataSource" />
                                    <%--added by rony tfs-2608--%>
                                    <asp:RequiredFieldValidator ID="HospitalRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                                ControlToValidate="HospitalDropDownList" EnableClientScript="true" Display="Dynamic"
                                                                ErrorMessage="Hospital is required" Text="*" ToolTip="This is a required field"
                                                                ValidationGroup="SaveRoom">
                                    </asp:RequiredFieldValidator>

                                    <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 280px;">
                                        <telerik:RadButton ID="SaveButton" runat="server" Text="Save & Close" Skin="Metro" OnClick="SaveRoom" CausesValidation="true" OnClientClicked="CheckForValidPage" Icon-PrimaryIconCssClass="telerikSaveButton" />
                                        <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Metro" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                                    </div>
                                </td>
                                <td valign="top">
                                    <div style="padding-right: 40px;">
                                        <fieldset>
                                            <legend>&nbsp;Procedures available in this room&nbsp;</legend>
                                            <div style="padding: 10px">
                                                <telerik:RadListBox ID="ProcedureTypeRadListBox" runat="server" CheckBoxes="true" ShowCheckAll="true" Width="320" DataTextField="ProcedureType" DataValueField="ProcedureTypeID" DataSourceID="RoomProcedureObjectDataSource" Height="380px" />
                                            </div>
                                        </fieldset>
                                    </div>
                                </td>
                            </tr>

                        </table>

                        <%--<div style="padding-bottom: 15px; float: left;">
                        </div>--%>

                    </div>

                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>


        <telerik:RadNotification ID="ValidationNotification" runat="server" Animation="None" Width="400"
            EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
            LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
            AutoCloseDelay="7000">
            <ContentTemplate>
                <asp:ValidationSummary ID="SaveRoomValidationSummary" runat="server" ValidationGroup="SaveRoom" DisplayMode="BulletList"
                    EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                <asp:Label ID="ServerErrorLabel" runat="server" CssClass="aspxValidationSummary" Visible="false"></asp:Label>
            </ContentTemplate>
        </telerik:RadNotification>
    </form>
</body>
</html>
