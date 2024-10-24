<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_Scheduler_BookingStatusLinkHL7Code" CodeBehind="BookingStatusLinkHL7Code.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title>Breach Status Link HL7Code</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../../Scripts/rgbcolor.js"></script>

    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .FormatRBL label {
            margin-right: 10px;
        }

        .RadGrid .rgSelectedRow {
            background-color: #25A0DA !important;
        }

        .slot-point td:first-child {
            padding-left: 8px;
        }

        .slot-point {
            height: 30px;
        }

            .slot-point td {
                background-color: darkgrey;
                padding-top: 4px;
                padding-bottom: 3px;
                color: darkgray !important;
            }

                .slot-point td:first-child {
                    width: 0px !important;
                }
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
            });

            $(document).ready(function () {
                Sys.Application.add_load(function () {
                    //refreshGrid(true);
                });
            });

           
            function refreshGrid(arg) {
               if (!arg) {
                    var masterTable = $find("<%= GridBookingBreachHL7Code.ClientID %>").get_masterTableView();
                    masterTable.fireCommand("Rebind", arg);
                }
                else {
                    var masterTable = $find("<%= GridBookingBreachHL7Code.ClientID %>").get_masterTableView();
                    masterTable.fireCommand("RebindAndNavigate", arg);
                }
            }

           

        </script>
    </telerik:RadScriptBlock>
</head>

<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">
            <AjaxSettings>
                             
                <telerik:AjaxSetting AjaxControlID="OperatingHospitalDropdown">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="GridBookingBreachHL7Code" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>                
                <telerik:AjaxSetting AjaxControlID="SaveButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="GridBookingBreachHL7Code" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>

                 <telerik:AjaxSetting AjaxControlID="SaveOnly">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="GridBookingBreachHL7Code" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>

            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />

        <telerik:RadFormDecorator ID="UserMaintenanceRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="700" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Metro">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="530px" Scrolling="None">
                <div id="FormDiv" runat="server" style="width: 710px;">
                    <div style="margin-left: 10px; padding-top: 5px; width: 700px; align-content:center;" class="rptText">
                        <table style="width: 95%;">
                            <tr>
                                <td align="right">
                                    <asp:Label runat="server" Text="Hospital" /></td>
                                <td colspan="2" align="center">
                                    <telerik:RadComboBox ID="OperatingHospitalDropdown" runat="server" DataTextField="HospitalName" DataValueField="OperatingHospitalId" Width="350" OnSelectedIndexChanged="OperatingHospitalDropdown_SelectedIndexChanged" AutoPostBack="true"/>
                                </td>
                            </tr>                            
                        </table>
                        <table style="width: 95%;">                            
                            <tr>
                                <td>
                                    <div id="Div1" runat="server" style="margin-top: 10px; width: 700px; padding-left: 5px; font-family: Calibri; font-size: 11pt;">
                                            <asp:Panel runat="server" Skin="Metro" ID="BookingTypes">
                                                <telerik:RadGrid ID="GridBookingBreachHL7Code" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="false"
                                                    Skin="Metro" PageSize="50" AllowPaging="true" Style="margin-bottom: 10px; width: 95%; height: 450px;">
                                                    <HeaderStyle Font-Bold="true" />
                                                    <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="OperatingHospitalId,StatusId,HL7Code" DataKeyNames="OperatingHospitalId,StatusID,HL7Code" TableLayout="Fixed" EnableNoRecordsTemplate="true" CssClass="MasterClass">
                                                        <ColumnGroups>
                                                            <telerik:GridColumnGroup HeaderText="Available For" Name="ProcedureFor" HeaderStyle-HorizontalAlign="Center"></telerik:GridColumnGroup>
                                                        </ColumnGroups>
                                                        <Columns>
                                                            <telerik:GridBoundColumn DataField="StatusIdLinkHL7RowId" Visible="false"></telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="OperatingHospitalId" Visible="false"></telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="Description" HeaderText="Type of Booking" HeaderStyle-Width="100px" />
                                                            <telerik:GridTemplateColumn HeaderText="Colour" HeaderStyle-Width="60px" UniqueName="Colour" ItemStyle-HorizontalAlign="Center">
                                                                <ItemTemplate>
                                                                    <asp:Label ID="ColourLabel" runat="server" Width="50" Height="12"></asp:Label>
                                                                </ItemTemplate>
                                                            </telerik:GridTemplateColumn>

                                                            <telerik:GridTemplateColumn UniqueName="GI" DataField="GI" HeaderText="Endoscopic" HeaderStyle-Width="70px" AllowFiltering="false" ColumnGroupName="ProcedureFor">
                                                                <ItemTemplate>
                                                                    <asp:CheckBox ID="GICheckBox" runat="server" AutoPostBack="true"
                                                                        Checked='<%# Bind("GI") %>' Enabled="false" />
                                                                </ItemTemplate>
                                                            </telerik:GridTemplateColumn>
                                                            <telerik:GridTemplateColumn UniqueName="nonGI" DataField="nonGI" HeaderText="Other" HeaderStyle-Width="70px" AllowFiltering="false" ColumnGroupName="ProcedureFor">
                                                                <ItemTemplate>
                                                                    <asp:CheckBox ID="nonGICheckBox" runat="server" AutoPostBack="true"
                                                                        Checked='<%# Bind("nonGI") %>' Enabled="false" />
                                                                </ItemTemplate>
                                                            </telerik:GridTemplateColumn>
                                                            <telerik:GridBoundColumn DataField="BreachDays" HeaderText="Breach Days" HeaderStyle-Width="65px" />

                                                            <telerik:GridTemplateColumn UniqueName="HDCKey" HeaderText="HDCKey" HeaderStyle-Width="100px">
                                                                <ItemTemplate>
                                                                    <asp:TextBox ID="txtHDCKey" runat="server" AutoPostBack="false" Text='<%# Bind("HDCKey") %>' Enabled="true" Width="100%"></asp:TextBox>
                                                                </ItemTemplate>
                                                            </telerik:GridTemplateColumn>

                                                            <telerik:GridTemplateColumn UniqueName="HL7Code" HeaderText="HL7Code" HeaderStyle-Width="100px">
                                                                <ItemTemplate>
                                                                    <asp:TextBox ID="txtHL7Code" runat="server" AutoPostBack="false" Text='<%# Bind("HL7Code") %>' Enabled="true" Width="100%"></asp:TextBox>
                                                                </ItemTemplate>
                                                            </telerik:GridTemplateColumn>
                                                        </Columns>
                                                    </MasterTableView>
                                                    <ClientSettings>
                                                        <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                                                    </ClientSettings>
                                                </telerik:RadGrid>
                                            </asp:Panel>
                                        </div>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="40px" CssClass="SiteDetailsButtonsPane">
                <div style="margin-left: 10px;">
                    <telerik:RadLabel ID="TemplateNotificationRadLabel" runat="server" ForeColor="Red" Text="This template has bookings against it and therefore cannot be changed" Visible="false" Style="" />
                </div>
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px;align-content:center; text-align:center;">
                    <telerik:RadButton ID="SaveOnly" runat="server" Text="Save" Skin="Metro" OnClick="SaveOnlyBookingBreachHL7Code" CausesValidation="true" Icon-PrimaryIconCssClass="telerikSaveButton" />&nbsp;&nbsp;
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save & Close" Skin="Metro" OnClick="SaveBookingBreachHL7Code" CausesValidation="true" Icon-PrimaryIconCssClass="telerikSaveButton" />&nbsp;&nbsp;
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Metro" OnClientClicked="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>

        <telerik:RadNotification ID="ValidationNotification" runat="server" Animation="None" Width="400"
            EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
            LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
            AutoCloseDelay="7000">
            <ContentTemplate>
                <asp:ValidationSummary ID="SaveSlotsValidationSummary" runat="server" DisplayMode="BulletList"
                    EnableClientScript="true" BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                <asp:Label ID="ServerErrorLabel" runat="server" CssClass="aspxValidationSummary" Visible="false"></asp:Label>
            </ContentTemplate>
        </telerik:RadNotification>
    </form>
</body>

</html>