<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Templates/Reports.Master" CodeBehind="SchedulerReports.aspx.vb" Inherits="UnisoftERS.SchedulerReports" ValidateRequest="False" %>

<%--<style type="text/css">
            .exportToExcelImage {
                background: url(../../Images/Excel-icon.png);
                background-position: 0 0;
                width: 5px;
                height: 5px;
            }

            .jagDivGrid {
                overflow: auto;
                max-height: 470px;
            }
        </style>--%>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContentPlaceHolder2" runat="server">
    <style type="text/css">
        .center-icon {
            margin-left: 3px;
            margin-top: 3px;
            /* You can also add margin or padding adjustments here if necessary */
        }

        .center-cross-icon {
            margin-left: 2px;
            margin-top: 1px;
            /* You can also add margin or padding adjustments here if necessary */
        }
    </style>
</asp:Content>
<asp:Content ID="MainBodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <script type="text/javascript" src="../../../Scripts/Reports.js"></script>
    <telerik:RadSkinManager ID="RadSkinManager1" runat="server" Skin="Office2010Blue" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Metro" />
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Skin="Metro" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>" ForeColor="Red" Position="Center" />

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" Modal="true" />


    <div id="loaderPreview">
        <%--        <img alt="loading" src="../../Images/loader_seq.gif" style="position: fixed; top: 30%; left: 40%; z-index: 5000; width: 400px; height:300px; text-align: center; background: #fff; border: 1px solid #000;" />--%>
        Loading...
    </div>

    <div id="ContentDiv">
        <table>
            <tr>
                <td>
                    <div class="optionsHeading">Scheduler Report</div>
                </td>
                <td></td>
            </tr>

        </table>

        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="95%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="650px">
                <asp:Panel ID="NoProceduresPanel" runat="server" Visible="false">
                    <div style="padding: 10px;">
                        <p>No procedures to report on</p>
                    </div>
                </asp:Panel>
                <asp:Panel ID="ReportPanel" runat="server">
                    <div style="margin: 0px 10px; width: 95%;">
                        <div style="margin-top: 10px;"></div>

                        <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" SelectedIndex="0" Skin="MetroTouch" RenderMode="Lightweight" Font-Size="Larger">
                            <Tabs>
                                <telerik:RadTab Text="Filter" Value="1" Font-Bold="false" Selected="true" PageViewID="RadPageView1" Width="80" Style="text-align: center;" />
                                <telerik:RadTab Text="Preview" Value="2" Font-Bold="false" PageViewID="RadPageView2" Selected="false" Enabled="true" />
                            </Tabs>
                        </telerik:RadTabStrip>
                        <telerik:RadMultiPage ID="RadMultiPage1" runat="server">
                            <telerik:RadPageView ID="RadPageView1" runat="server" Selected="true">
                                <div style="padding-bottom: 10px;" class="ConfigureBg">
                                    <table id="ControlsTable" runat="server" class="optionsBodyText" style="margin-top: 15px; margin-left: 15px;" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td>
                                                <asp:Panel ID="FilterPanel" runat="server">
                                                    <asp:ObjectDataSource ID="SqlDSAllRooms" runat="server" SelectMethod="GetRoomsListBox1" TypeName="UnisoftERS.Reporting">
                                                        <SelectParameters>
                                                            <%--<asp:ControlParameter Name="searchPhrase" DbType="String" ControlID="ISMFilter" ConvertEmptyStringToNull="true" />--%>
                                                            <%--<asp:ControlParameter Name="HospitalId" DbType="String" ControlID="ISMFilter" ConvertEmptyStringToNull="true" />--%>
                                                            <asp:SessionParameter DefaultValue="NULL" Name="HospitalId" SessionField="HospitalId" Type="String" />
                                                            <asp:SessionParameter DefaultValue="NULL" Name="RoomId" SessionField="RoomId" Type="String" />
                                                        </SelectParameters>
                                                    </asp:ObjectDataSource>
                                                    <asp:ObjectDataSource ID="SqlDSSelectedRooms" runat="server" SelectMethod="GetRoomsListBox2" TypeName="UnisoftERS.Reporting">
                                                        <SelectParameters>
                                                            <asp:ControlParameter Name="searchPhrase" DbType="String" ControlID="RadListBox2" ConvertEmptyStringToNull="true" />
                                                            <%--<asp:SessionParameter DefaultValue="NULL" Name="HospitalId" SessionField="HospitalId" Type="String" />--%>
                                                            <%--<asp:SessionParameter DefaultValue="NULL" Name="RoomId" SessionField="RoomId" Type="String" />--%>
                                                        </SelectParameters>
                                                    </asp:ObjectDataSource>
                                                    <table>
                                                        <tr runat="server" id="HospitalPanel">
                                                            <td>
                                                                <div style="border: 1px solid #c2d2e2;">
                                                                    <div class="filterRepHeader collapsible_header">
                                                                        <img src="../../../Images/icons/collapse-arrow-down.png" alt="" />
                                                                        <span style="padding-left: 5px;">Hospital</span>

                                                                    </div>
                                                                    <div class="content" style="height: 285px;">

                                                                        <table style="padding: 10px;">
                                                                            <tr>
                                                                                <td style="width: 400px;" colspan="2">
                                                                                    <table id="FilterRoom" runat="server" border="0">
                                                                                        <tr>
                                                                                            <td style="width: 160px;">
                                                                                                <asp:Label ID="Label1" runat="server" Text="Type word(s) to filter on: "></asp:Label>
                                                                                            </td>
                                                                                            <td>
                                                                                                <telerik:RadTextBox runat="server" ID="ISMFilter" CssClass="hospital-search" Width="160px" placeholder="Hospital name" Skin="Windows7" onkeydown="searchOnHospitalEnter(event)">
                                                                                                </telerik:RadTextBox>
                                                                                                <telerik:RadButton ID="HospitalSearchButton" runat="server" ButtonType="SkinnedButton" Skin="Windows7" Width="10" Height="22px" Icon-PrimaryIconUrl="~/Images/magnifying-glass-solid.svg" Icon-PrimaryIconCssClass="center-icon" Icon-PrimaryIconWidth="11px" Icon-PrimaryIconHeight="11px" OnClick="HospitalSearchButton_Click" />
                                                                                                <telerik:RadButton ID="HospitalClear" runat="server" ButtonType="SkinnedButton" Skin="Windows7" Width="10" Height="22px" Icon-PrimaryIconUrl="~/Images/icons/xmark-solid.svg" Icon-PrimaryIconCssClass="center-cross-icon" Icon-PrimaryIconWidth="14px" Icon-PrimaryIconHeight="14px" OnClick="HospitalClear_Click" />
                                                                                                <%--<telerik:RadButton ID="HospitalSearchButton" runat="server" Text="Search" Skin="Office2007" CssClass="filterBtn" OnClick="HospitalSearchButton_Click"/>--%>
                                                                                            </td>
                                                                                        </tr>
                                                                                        <tr>
                                                                                            <td colspan="2" style="height: 2px;"></td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td style="padding-left: 25px; vertical-align: top;">
                                                                                    <div>
                                                                                        <table style="border: 1px solid #c2d2e2; background-color: #ececff;">
                                                                                            <tr>
                                                                                                <td>
                                                                                                    <telerik:RadListBox ID="RadListBox1" runat="server" Width="287px" Height="200px" Skin="Metro"
                                                                                                        CheckBoxes="true" ShowCheckAll="true"
                                                                                                        SelectionMode="Multiple" DataTextField="HospitalName" AutoPostBack="true" OnCheckAllCheck="RadListBox1_CheckAllCheck">
                                                                                                    </telerik:RadListBox>
                                                                                                </td>
                                                                                            </tr>
                                                                                        </table>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </div>
                                                                </div>
                                                            </td>
                                                            <td>
                                                                <div style="border: 1px solid #c2d2e2;">
                                                                    <div class="filterRepHeader collapsible_header">
                                                                        <img src="../../../Images/icons/collapse-arrow-down.png" alt="" />
                                                                        <span style="padding-left: 5px;">Room</span>

                                                                    </div>
                                                                    <div class="content" style="height: 285px;">

                                                                        <table style="padding: 10px;">
                                                                            <tr runat="server" visible="true">

                                                                                <%--  <td colspan="2">
                                                                    <div id="Div1" runat="server" class="optionsBodyText" style="padding-bottom: 15px;">
                                                                        Room(s):&nbsp;<telerik:RadComboBox CheckBoxes="true" EnableCheckAllItemsCheckBox="true" CheckedItemsTexts="DisplayAllInInput" ID="RoomsRadComboBox" OnItemDataBound="RoomsRadComboBox_ItemDataBound" runat="server" Width="270px" AutoPostBack="true" />
                                                                    </div>
                                                                </td>--%>
                                                                            </tr>
                                                                            <tr>
                                                                                <td style="width: 400px;" colspan="2">
                                                                                    <table id="Table1" runat="server" border="0">
                                                                                        <tr>
                                                                                            <td style="width: 160px;">
                                                                                                <asp:Label ID="Label2" runat="server" Text="Type word(s) to filter on: "></asp:Label>
                                                                                            </td>
                                                                                            <td>
                                                                                                <telerik:RadTextBox runat="server" ID="RadTextBox1" CssClass="room-search" Width="160px" placeholder="Room name" Skin="Windows7" onkeydown="searchOnRoomEnter(event)">
                                                                                                </telerik:RadTextBox>
                                                                                                <telerik:RadButton ID="RoomSearchButton" runat="server" ButtonType="SkinnedButton" Skin="Windows7" Width="10" Height="22px" Icon-PrimaryIconUrl="~/Images/magnifying-glass-solid.svg" Icon-PrimaryIconCssClass="center-icon" Icon-PrimaryIconWidth="11px" Icon-PrimaryIconHeight="11px" />
                                                                                                <telerik:RadButton ID="RoomClear" runat="server" ButtonType="SkinnedButton" Skin="Windows7" Width="10" Height="22px" Icon-PrimaryIconUrl="~/Images/icons/xmark-solid.svg" Icon-PrimaryIconCssClass="center-cross-icon" Icon-PrimaryIconWidth="14px" Icon-PrimaryIconHeight="14px"  OnClientClicking="ClearRoom" OnClick="RoomClear_Click" />
                                                                                                <%--<telerik:RadTextBox ID="PhraseSearchBox" runat="server" MinLength="3" MaxLength="500" Skin="Windows7" Height="35px" Width="200px" placeholder="Search here" onkeydown="searchOnEnter(event)" />
                                                                                                <telerik:RadButton ID="searchButton" runat="server" AutoPostBack="true" Width="10" Height="35" Icon-PrimaryIconUrl="~/Images/magnifying-glass-solid.svg" Skin="Windows7" ButtonType="SkinnedButton" CssClass="searchButton" OnClick="PhraseSearchBox_TextChanged">
                                                                                                </telerik:RadButton>--%>
                                                                                            </td>
                                                                                        </tr>
                                                                                        <tr>
                                                                                            <td colspan="2" style="height: 2px;"></td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td style="padding-left: 25px; vertical-align: top;">
                                                                                    <div>
                                                                                        <table style="border: 1px solid #c2d2e2; background-color: #ececff;">
                                                                                            <tr>
                                                                                                <td>
                                                                                                    <telerik:RadListBox ID="RadListBox2" runat="server" Width="287px" Height="200px" Skin="Metro"
                                                                                                        CheckBoxes="true" ShowCheckAll="true"
                                                                                                        SelectionMode="Multiple" DataTextField="RoomName">
                                                                                                    </telerik:RadListBox>
                                                                                                </td>
                                                                                            </tr>
                                                                                        </table>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </div>
                                                                </div>
                                                            </td>
                                                            <td>
                                                                <asp:Panel ID="Panel1" runat="server">
                                                                    <table>
                                                                        <tr runat="server" id="Tr1">
                                                                            <td>
                                                                                <div style="border: 1px solid #c2d2e2;">
                                                                                    <div class="filterRepHeader">
                                                                                        <img src="../../Images/icons/collapse-arrow-down.png" alt="" />
                                                                                        <span style="padding-left: 5px;">Other Reports</span>

                                                                                    </div>
                                                                                    <div class="content" style="padding-left: 10px; height: 285px; width: 400px; overflow-y: auto">
                                                                                        <div style="padding: 10px;">
                                                                                            <asp:CheckBoxList ID="OtherAudits" runat="server" CellSpacing="0" CellPadding="0"
                                                                                                RepeatLayout="Table" RepeatDirection="Vertical" RepeatColumns="1" />
                                                                                        </div>
                                                                                    </div>
                                                                                </div>
                                                                            </td>
                                                                        </tr>
                                                                    </table>

                                                                </asp:Panel>
                                                            </td>
                                                        </tr>

                                                        <%--<tr id="HideSuppressedCriteria" style="display:none">
                                                            <td colspan="2" style="padding-top: 30px; text-align: center; width: 100%; color: #c2d2e2;">------------------------------------------</td>
                                                        </tr>--%>
                                                        <tr>
                                                            <td style="padding-top: 5px;">
                                                                <div style="border: 1px solid #c2d2e2;">
                                                                    <div class="filterRepHeader collapsible_header">
                                                                        <img src="../../../Images/icons/collapse-arrow-down.png" alt="" />
                                                                        <span style="padding-left: 5px;">Suppressed criteria</span>

                                                                    </div>
                                                                    <%--<td colspan="2" style="height: 2px; padding-top: 10px;">--%>
                                                                    <%--<fieldset>--%>
                                                                    <%--<legend>Together with these criteria</legend>--%>
                                                                    <div>
                                                                        <asp:CheckBox ID="chkHideSuppressedList" runat="server" Text="Hide suppressed list consultants" Skin="Windows7" CssClass="mutuallyexclusive" Style="margin-right: 20px;" /><br />
                                                                        <asp:CheckBox ID="chkHideSuppressedEndo" runat="server" Text="Hide suppressed endoscopists" Skin="Windows7" CssClass="mutuallyexclusive" Style="margin-right: 20px;" /><br />
                                                                    </div>
                                                                    <%--</fieldset>--%>
                                                                    <%--</td>--%>
                                                                </div>
                                                            </td>
                                                            <td style="padding-top: 5px;">
                                                                <div style="border: 1px solid #c2d2e2;">
                                                                    <div class="filterRepHeader collapsible_header">
                                                                        <img src="../../../Images/icons/collapse-arrow-down.png" alt="" />
                                                                        <span style="padding-left: 5px;">Dates</span>

                                                                    </div>
                                                                    <div class="content" style="padding-left: 10px;">
                                                                        <table runat="server" border="0" style="margin-top: 5px;">
                                                                            <tr>
                                                                                <td style="text-align: right">From: 
                                                                                </td>
                                                                                <td>
                                                                                    <telerik:RadDatePicker ID="RDPFrom" runat="server" Width="150px" Skin="Windows7" RenderMode="classic">
                                                                                    </telerik:RadDatePicker>
                                                                                </td>
                                                                                <td style="text-align: right;">To:
                                                                                </td>
                                                                                <td>
                                                                                    <telerik:RadDatePicker ID="RDPTo" runat="server" Width="150px" Skin="Windows7" />
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                        <asp:HiddenField ID="SUID" runat="server" />
                                                                        <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidatorFromDate" ControlToValidate="RDPFrom" ErrorMessage="Enter a date!" SetFocusOnError="True" ValidationGroup="FilterGroup" ForeColor="Red"></asp:RequiredFieldValidator>
                                                                        <asp:RequiredFieldValidator runat="server" ID="RequiredfieldvalidatorToDate" ControlToValidate="RDPTo" ErrorMessage="Enter a date!" ValidationGroup="FilterGroup" ForeColor="Red"></asp:RequiredFieldValidator>
                                                                        <asp:CompareValidator ID="dateCompareValidator" runat="server" ControlToValidate="RDPTo" ControlToCompare="RDPFrom" Operator="GreaterThan" ValidationGroup="FilterGroup" Type="Date" ErrorMessage="The second date must be after the first one." SetFocusOnError="True" ForeColor="Red"></asp:CompareValidator>
                                                                    </div>
                                                                </div>
                                                            </td>
                                                        </tr>


                                                        <tr>
                                                            <td style="padding-top: 10px;">
                                                                <div style="border: 1px solid #c2d2e2;">
                                                                    <div class="filterRepHeader collapsible_header">
                                                                        <img src="../../../Images/icons/collapse-arrow-down.png" alt="" />
                                                                        <span style="padding-left: 5px;">Summary reports</span>

                                                                    </div>
                                                                    <div class="content" style="padding-left: 10px;">
                                                                        <table runat="server" cellspacing="1" cellpadding="1" border="0">
                                                                            <tr>
                                                                                <td>
                                                                                    <div id="EndoList">
                                                                                        <asp:CheckBoxList ID="chkReports" runat="server" RepeatColumns="4" Skin="Windows7" CssClass="mutuallyexclusive">
                                                                                            <asp:ListItem Value="Activity">Activity</asp:ListItem>
                                                                                            <asp:ListItem Value="Cancelled">Cancelled</asp:ListItem>
                                                                                            <asp:ListItem Value="DNA">DNA</asp:ListItem>
                                                                                            <asp:ListItem Value="PatientPathway">Patient Pathway</asp:ListItem>
                                                                                            <asp:ListItem Value="PatientStatus">Patient Status</asp:ListItem>
                                                                                            <asp:ListItem Value="ScheduleListCancelled">List Cancelled</asp:ListItem>
                                                                                            <%--<asp:ListItem Value="Audit">Audit</asp:ListItem>--%>
                                                                                        </asp:CheckBoxList>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </div>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <div style="margin-top: 10px;">
                                                                    <telerik:RadButton ID="RadButtonFilter" runat="server" Text="Apply filter" Skin="Silk" ValidationGroup="FilterGroup"
                                                                        OnClientClicking="ValidatingForm" ButtonType="SkinnedButton" SkinID="RadSkinManager1" Icon-PrimaryIconUrl="~/Images/icons/filter.png">
                                                                    </telerik:RadButton>

                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </asp:Panel>
                                            </td>




                                        </tr>
                                    </table>
                                </div>
                            </telerik:RadPageView>
                            <telerik:RadPageView ID="RadPageView2" runat="server">

                                <div style="padding: 20px; max-height: 510px;" class="ConfigureBg">
                                    <%--<table id="Table1" runat="server" class="optionsBodyText" style="margin:15px 10px 10px 15px;" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td style="width:100%;">
                                    <div id="ButtonExport" style="margin-bottom: 10px;visibility:hidden">
                                        <telerik:RadButton ID="RadButtonExportGrids" runat="server" Text="Export Grids to Excel" Enabled="True" Skin="Silk" Style="height: 30px;" Font-Bold="true" Visible="false">
                                        </telerik:RadButton>
                                        <a runat="server" id="downloadFile" visible="false">Download</a>
                                    </div>--%>
                                    <telerik:RadTabStrip ID="RadTabStrip2" runat="server" MultiPageID="RadMultiPage2" SelectedIndex="0" Skin="Office2010Silver" RenderMode="Lightweight">
                                        <Tabs>
                                            <telerik:RadTab runat="server" Text="Activity report" PageViewID="RadPageActivity">
                                            </telerik:RadTab>
                                            <telerik:RadTab runat="server" Text="Cancellation report" PageViewID="RadPageCancellation">
                                            </telerik:RadTab>
                                            <telerik:RadTab runat="server" Text="DNA report" PageViewID="RadPageDna">
                                            </telerik:RadTab>
                                            <telerik:RadTab runat="server" Text="Patient pathway report" PageViewID="RadPagePatientPathway">
                                            </telerik:RadTab>
                                            <telerik:RadTab runat="server" Text="Patient status report" PageViewID="RadPagePatientStatus">
                                            </telerik:RadTab>
                                            <telerik:RadTab runat="server" Text="List cancellation report" PageViewID="RadPageScheduleListCancellation">
                                            </telerik:RadTab>
                                            <%--<telerik:RadTab runat="server" Text="Audit report">
                                            </telerik:RadTab>--%>
                                        </Tabs>
                                    </telerik:RadTabStrip>
                                    <telerik:RadMultiPage ID="RadMultiPage2" runat="server" SelectedIndex="0">
                                        <telerik:RadPageView ID="RadPageActivity" runat="server" Height="100%">
                                            <div class="jagDivGrid">
                                                <asp:ObjectDataSource ID="DSActivity" runat="server" SelectMethod="GetActivityQuery" TypeName="UnisoftERS.SchedulerReports" OnSelecting="DSActivity_OnSelecting">
                                                    <SelectParameters>
                                                        <asp:ControlParameter Name="searchStart" DbType="Date" ControlID="RDPFrom" PropertyName="SelectedDate"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="searchEnd" DbType="Date" ControlID="RDPTo" PropertyName="SelectedDate"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="HideSuppressedEndoscopists" DbType="Boolean" ControlID="chkHideSuppressedEndo" PropertyName="Checked"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="HideSuppressedConsultants" DbType="Boolean" ControlID="chkHideSuppressedList" PropertyName="Checked"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:Parameter Name="operatingHospitalIds" DbType="String" ConvertEmptyStringToNull="true" />
                                                        <asp:Parameter Name="roomIds" DbType="String" ConvertEmptyStringToNull="True" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <telerik:RadGrid ID="RadGridActivity" runat="server" AllowSorting="True" AllowMultiRowSelection="True" AllowPaging="False"
                                                    PageSize="20" AutoGenerateColumns="False" GroupPanelPosition="Top"
                                                    PagerStyle-AlwaysVisible="True" ExportSettings-Excel-Format="ExcelML" ExportSettings-ExportOnlyData="True"
                                                    ShowGroupPanel="False" GridLines="Horizontal" Skin="Office2010Blue">
                                                    <GroupingSettings ShowUnGroupButton="False" />
                                                    <MasterTableView DataKeyNames="RoomId" ClientDataKeyNames="RoomId" CommandItemDisplay="Top" CommandItemStyle-HorizontalAlign="Right" CommandItemStyle-BackColor="lightblue"
                                                        ShowGroupFooter="False" ShowHeader="True" CommandItemStyle-Font-Bold="True" Width="100%">
                                                        <CommandItemSettings ExportToExcelText="" ShowExportToExcelButton="True" ShowAddNewRecordButton="False" ShowRefreshButton="False" />

                                                        <Columns>
                                                            <telerik:GridBoundColumn DataField="Day" DataType="System.DateTime" DataFormatString="{0:d}" HeaderButtonType="TextButton" FilterControlAltText="Filter Day column" HeaderText="Day" ReadOnly="True" SortExpression="Day" UniqueName="Day">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Date" DataType="System.DateTime" DataFormatString="{0:d}"
                                                                FilterControlAltText="Filter Date column" HeaderText="Date" ReadOnly="True" SortExpression="Date" UniqueName="Date" HeaderButtonType="TextButton">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Room" DataType="System.String" HeaderButtonType="TextButton" FilterControlAltText="Filter Room column" HeaderText="Room Name"
                                                                ReadOnly="True" SortExpression="Room" UniqueName="Room" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="List Consultant" DataType="System.String" HeaderButtonType="TextButton" FilterControlAltText="Filter List Consultant column" HeaderText="List consultant" ReadOnly="True" SortExpression="ListConsultant" UniqueName="ListConsultant">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Endoscopist" DataType="System.String" HeaderButtonType="TextButton" FilterControlAltText="Filter Endoscopist column" HeaderText="Endoscopist" ReadOnly="True" SortExpression="Endoscopist" UniqueName="Endoscopist">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="TemplateName" DataType="System.String" HeaderButtonType="TextButton" FilterControlAltText="Filter Template Name column" HeaderText="List name" ReadOnly="True" SortExpression="TemplateName" UniqueName="TemplateName">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="AM/PM" DataType="System.String" HeaderButtonType="TextButton" FilterControlAltText="Filter AM/PM column" HeaderText="AM/PM" ReadOnly="True" SortExpression="AM/PM" UniqueName="AM/PM">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="NoOfPtsOnTemplate" DataType="System.Int32" HeaderButtonType="TextButton" FilterControlAltText="Filter no. of pts on template column"
                                                                HeaderText="Template total points" ReadOnly="True" SortExpression="NoOfPtsOnTemplate" Aggregate="Sum"
                                                                UniqueName="NoOfPtsOnTemplate" ColumnGroupName="Selectable" GroupByExpression="SUM(NoOfPtsOnTemplate) AS [No. of pts on template] Group By NoOfPtsOnTemplate">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="NoOfPtsBooked" DataType="System.Decimal" HeaderButtonType="TextButton" DataFormatString="{0:0.00}" FilterControlAltText="Filter points booked column" HeaderText="Points booked"
                                                                ReadOnly="True" SortExpression="NoOfPtsBooked" UniqueName="NoOfPtsBooked" ColumnGroupName="Selectable" Aggregate="Sum">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="NoOfPtsRemaining" DataType="System.Decimal" HeaderButtonType="TextButton" DataFormatString="{0:0.00}" FilterControlAltText="Filter points remaining column" HeaderText="Points remaining"
                                                                ReadOnly="True" SortExpression="NoOfPtsRemaining" UniqueName="NoOfPtsRemaining" ColumnGroupName="Selectable" Aggregate="Sum">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="NoOfPatientsAttended" DataType="System.Decimal" HeaderButtonType="TextButton" FilterControlAltText="Filter number of patients attended column" HeaderText="Number of patients attended"
                                                                ReadOnly="True" SortExpression="NoOfPatientsAttended" UniqueName="NoOfPatientsAttended" ColumnGroupName="Selectable" Aggregate="Sum">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="NoOfPatientPointsUsed" DataType="System.Decimal" HeaderButtonType="TextButton" DataFormatString="{0:0.00}" FilterControlAltText="Filter number of patient points used column" HeaderText="Number of patient points used"
                                                                ReadOnly="True" SortExpression="NoOfPatientPointsUsed" UniqueName="NoOfPatientPointsUsed" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="ListLocked" DataType="System.Decimal" HeaderButtonType="TextButton" DataFormatString="{0:0.00}" FilterControlAltText="Filter list locked column" HeaderText="List locked"
                                                                ReadOnly="True" SortExpression="ListLocked" UniqueName="ListLocked">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="ReasonsLocked" DataType="System.Decimal" HeaderButtonType="TextButton" DataFormatString="{0:0.00}" FilterControlAltText="Filter reasons locked column" HeaderText="Reasons locked"
                                                                ReadOnly="True" SortExpression="ReasonsLocked" UniqueName="ReasonsLocked" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="ListUnlocked" DataType="System.Decimal" HeaderButtonType="TextButton" DataFormatString="{0:0.00}" FilterControlAltText="Filter list unlocked column" HeaderText="List unlocked"
                                                                ReadOnly="True" SortExpression="ListUnlocked" UniqueName="ListUnlocked" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="ReasonsUnlocked" DataType="System.Decimal" HeaderButtonType="TextButton" DataFormatString="{0:0.00}" FilterControlAltText="Filter reasons unlocked column" HeaderText="Reasons unlocked"
                                                                ReadOnly="True" SortExpression="ReasonsUnlocked" UniqueName="ReasonsUnlocked" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="SlotStatus" DataType="System.String" HeaderButtonType="TextButton" FilterControlAltText="Filter SlotStatus column" HeaderText="Slot Status"
                                                                ReadOnly="True" SortExpression="SlotStatus" UniqueName="SlotStatus" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                        </Columns>
                                                    </MasterTableView>
                                                    <ClientSettings ReorderColumnsOnClient="True" AllowDragToGroup="True" AllowColumnsReorder="True">
                                                        <Selecting AllowRowSelect="True" EnableDragToSelectRows="True"></Selecting>
                                                        <Resizing AllowRowResize="True" AllowColumnResize="True" EnableRealTimeResize="True"
                                                            ResizeGridOnColumnResize="True"></Resizing>
                                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" SaveScrollPosition="True" />
                                                    </ClientSettings>

                                                </telerik:RadGrid>
                                            </div>
                                        </telerik:RadPageView>
                                        <telerik:RadPageView ID="RadPageCancellation" runat="server" Height="100%">
                                            <div class="jagDivGrid">
                                                <asp:ObjectDataSource ID="DSCancellation" runat="server" SelectMethod="GetCancellationQuery" TypeName="UnisoftERS.SchedulerReports" OnSelecting="DSCancellation_OnSelecting">
                                                    <SelectParameters>
                                                        <asp:ControlParameter Name="searchStart" DbType="Date" ControlID="RDPFrom" PropertyName="SelectedDate"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="searchEnd" DbType="Date" ControlID="RDPTo" PropertyName="SelectedDate"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="HideSuppressedEndoscopists" DbType="Boolean" ControlID="chkHideSuppressedEndo" PropertyName="Checked"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="HideSuppressedConsultants" DbType="Boolean" ControlID="chkHideSuppressedList" PropertyName="Checked"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:Parameter Name="operatingHospitalIds" DbType="String" ConvertEmptyStringToNull="true" />
                                                        <asp:Parameter Name="roomIds" DbType="String" ConvertEmptyStringToNull="True" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <telerik:RadGrid ID="RadGridCancellation" runat="server" Skin="Office2010Blue" GroupPanelPosition="Top" AutoGenerateColumns="False" CellSpacing="-1" PagerStyle-AlwaysVisible="true" ExportSettings-Excel-Format="XLSX" ExportSettings-ExportOnlyData="true"
                                                    OnItemDataBound="RadGridCancellation_ItemDataBound">
                                                    <ClientSettings>
                                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" SaveScrollPosition="True" />
                                                        <Selecting EnableDragToSelectRows="True" />
                                                    </ClientSettings>
                                                    <MasterTableView DataKeyNames="RoomId" ClientDataKeyNames="RoomId" CommandItemDisplay="Top" CommandItemStyle-HorizontalAlign="Right" CommandItemStyle-BackColor="lightblue"
                                                        ShowGroupFooter="False" ShowHeader="True" CommandItemStyle-Font-Bold="True" Width="100%">
                                                        <CommandItemSettings ExportToExcelText="" ShowExportToExcelButton="True" ShowAddNewRecordButton="False" ShowRefreshButton="False" />


                                                        <Columns>
                                                            <telerik:GridBoundColumn DataField="Day" DataType="System.DateTime" DataFormatString="{0:d}" FilterControlAltText="Filter Day column" HeaderText="Day" ReadOnly="True" SortExpression="Day" UniqueName="Day">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Date" DataType="System.DateTime" DataFormatString="{0:d}" FilterControlAltText="Filter Date column" HeaderText="Date" ReadOnly="True" SortExpression="Date" UniqueName="Date">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Time" DataType="System.DateTime" DataFormatString="{0:d}" FilterControlAltText="Filter Time column" HeaderText="Time" ReadOnly="True" SortExpression="Time" UniqueName="Time">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="OperatingHospital" DataType="System.String" HeaderButtonType="TextButton" FilterControlAltText="Filter OperatingHospital column" HeaderText="Operating Hospital"
                                                                ReadOnly="True" SortExpression="OperatingHospital" UniqueName="OperatingHospital" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" Width="240px" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Room" DataType="System.String" FilterControlAltText="Filter Room column" HeaderText="Room Name"
                                                                ReadOnly="True" SortExpression="Room" UniqueName="Room" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="CaseNoteNo" DataType="System.Int32" DataFormatString="{0:F0}" FilterControlAltText="Filter hospital number column"
                                                                HeaderText="Hospital No" ReadOnly="True" SortExpression="CaseNoteNo"
                                                                UniqueName="CaseNoteNo" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="ProcedureName" DataType="System.String" FilterControlAltText="Filter procedure column" HeaderText="Procedure type"
                                                                ReadOnly="True" SortExpression="ProcedureName" UniqueName="ProcedureName" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Endoscopist" DataType="System.String" FilterControlAltText="Filter endoscopist column" HeaderText="Endoscopist"
                                                                ReadOnly="True" SortExpression="Endoscopist" UniqueName="Endoscopist" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="NoOfPts" DataType="System.Int32" DataFormatString="{0:F0}" FilterControlAltText="Filter no. of pts column" HeaderText="No. of pts"
                                                                ReadOnly="True" SortExpression="NoOfPts" UniqueName="NoOfPts" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="NoOfDays" DataType="System.Int32" FilterControlAltText="Filter number of days column" HeaderText="Number of days"
                                                                ReadOnly="True" SortExpression="NoOfDays" UniqueName="NoOfDays" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="CancelledDate" DataType="System.DateTime" DataFormatString="{0:d}" FilterControlAltText="Filter cancelled date column" HeaderText="Cancelled date"
                                                                ReadOnly="True" SortExpression="CancelledDate" UniqueName="CancelledDate" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="CancellationReason" DataType="System.String" FilterControlAltText="Filter cancellation reason column" HeaderText="Cancellation reason"
                                                                ReadOnly="True" SortExpression="CancellationReason" UniqueName="CancellationReason" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="RebookedDate" DataType="System.DateTime" DataFormatString="{0:d}" FilterControlAltText="Filter rebooked date column" HeaderText="Rebooked date"
                                                                ReadOnly="True" SortExpression="RebookedDate" UniqueName="RebookedDate" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="CancelledBy" DataType="System.String" FilterControlAltText="Filter cancellation By column" HeaderText="Cancelled By"
                                                                ReadOnly="True" SortExpression="CancelledBy" UniqueName="CancelledBy" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                        </Columns>
                                                    </MasterTableView>
                                                    <ClientSettings ReorderColumnsOnClient="True" AllowDragToGroup="True" AllowColumnsReorder="True">
                                                        <Selecting AllowRowSelect="True"></Selecting>
                                                        <Resizing AllowRowResize="True" AllowColumnResize="True" EnableRealTimeResize="True"
                                                            ResizeGridOnColumnResize="True"></Resizing>
                                                    </ClientSettings>
                                                    <GroupingSettings ShowUnGroupButton="true" />
                                                </telerik:RadGrid>
                                            </div>
                                        </telerik:RadPageView>

                                        <%--     Schedule Cancellation    --%>
                                        <telerik:RadPageView ID="RadPageScheduleListCancellation" runat="server" Height="100%">
                                            <div class="jagDivGrid">
                                                <asp:ObjectDataSource ID="DSScheduleListCancellation" runat="server" SelectMethod="GetScheduleListCancelledData" TypeName="UnisoftERS.SchedulerReports" OnSelecting="DSScheduleListCancellation_OnSelecting">
                                                    <SelectParameters>
                                                        <asp:ControlParameter Name="searchStart" DbType="Date" ControlID="RDPFrom" PropertyName="SelectedDate"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="searchEnd" DbType="Date" ControlID="RDPTo" PropertyName="SelectedDate"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="HideSuppressedEndoscopists" DbType="Boolean" ControlID="chkHideSuppressedEndo" PropertyName="Checked"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="HideSuppressedConsultants" DbType="Boolean" ControlID="chkHideSuppressedList" PropertyName="Checked"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:Parameter Name="operatingHospitalIds" DbType="String" ConvertEmptyStringToNull="true" />
                                                        <asp:Parameter Name="roomIds" DbType="String" ConvertEmptyStringToNull="True" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <telerik:RadGrid ID="RadGridScheduleListCancellation" runat="server" ShowGroupPanel="False" GridLines="Horizontal" Skin="Office2010Blue"
                                                    OnItemDataBound="RadGridCancellation_ItemDataBound">
                                                    <ClientSettings>
                                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" SaveScrollPosition="True" />
                                                        <Selecting EnableDragToSelectRows="True" />
                                                    </ClientSettings>
                                                    <MasterTableView DataKeyNames="DiaryId" ClientDataKeyNames="DiaryId" CommandItemDisplay="Top" AutoGenerateColumns="False" CommandItemStyle-HorizontalAlign="Right" CommandItemStyle-BackColor="lightblue"
                                                        ShowGroupFooter="False" ShowHeader="True" CommandItemStyle-Font-Bold="True" Width="100%">
                                                        <CommandItemSettings ExportToExcelText="" ShowExportToExcelButton="True" ShowAddNewRecordButton="False" ShowRefreshButton="False" />

                                                        <Columns>
                                                            <telerik:GridBoundColumn DataField="Day" HeaderText="Day" ReadOnly="True">
                                                                <HeaderStyle HorizontalAlign="Center" Width="50px" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="Date" HeaderText="Date" ReadOnly="True">
                                                                <HeaderStyle HorizontalAlign="Center" Width="100px" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="TimeSlot" HeaderText="Time slot" ReadOnly="True">
                                                                <HeaderStyle HorizontalAlign="Center" Width="100px" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="OperatingHospital" HeaderText="Hospital"
                                                                ReadOnly="True" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" Width="240px" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Room" HeaderText="Room"
                                                                ReadOnly="True" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" Width="80px" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Endoscopist" HeaderText="Endoscopist">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="List" HeaderText="List"
                                                                ReadOnly="True" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="Points" HeaderText="Points"
                                                                ReadOnly="True" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" Width="50px" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="CancelledDate" HeaderText="Cancelled date"
                                                                ReadOnly="True" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" Width="120px" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="CancelledBy" HeaderText="Cancelled by"
                                                                ReadOnly="True" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="CancellationReason" HeaderText="Cancellation reason"
                                                                ReadOnly="True" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                        </Columns>
                                                    </MasterTableView>
                                                    <ClientSettings ReorderColumnsOnClient="True" AllowDragToGroup="True" AllowColumnsReorder="True">
                                                        <Selecting AllowRowSelect="True"></Selecting>
                                                        <Resizing AllowRowResize="True" AllowColumnResize="True" EnableRealTimeResize="True"
                                                            ResizeGridOnColumnResize="True"></Resizing>
                                                    </ClientSettings>
                                                    <GroupingSettings ShowUnGroupButton="true" />
                                                </telerik:RadGrid>
                                            </div>
                                        </telerik:RadPageView>





                                        <telerik:RadPageView ID="RadPageDna" runat="server" Height="100%">
                                            <div class="jagDivGrid">
                                                <asp:ObjectDataSource ID="DSDna" runat="server" SelectMethod="GetDnaQuery" TypeName="UnisoftERS.SchedulerReports" OnSelecting="DSDna_OnSelecting">
                                                    <SelectParameters>
                                                        <asp:ControlParameter Name="searchStart" DbType="Date" ControlID="RDPFrom" PropertyName="SelectedDate"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="searchEnd" DbType="Date" ControlID="RDPTo" PropertyName="SelectedDate"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="HideSuppressedEndoscopists" DbType="Boolean" ControlID="chkHideSuppressedEndo" PropertyName="Checked"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="HideSuppressedConsultants" DbType="Boolean" ControlID="chkHideSuppressedList" PropertyName="Checked"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:Parameter Name="operatingHospitalIds" DbType="String" ConvertEmptyStringToNull="true" />
                                                        <asp:Parameter Name="roomIds" DbType="String" ConvertEmptyStringToNull="True" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <telerik:RadGrid ID="RadGridDna" runat="server" Skin="Office2010Blue" GroupPanelPosition="Top" AutoGenerateColumns="False" CellSpacing="-1" PagerStyle-AlwaysVisible="true" ExportSettings-Excel-Format="XLSX" ExportSettings-ExportOnlyData="true" AllowSorting="True" AllowMultiRowSelection="True" AllowPaging="False"
                                                    OnItemDataBound="RadGridDna_ItemDataBound">
                                                    <ClientSettings>
                                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" SaveScrollPosition="True" />
                                                        <Selecting EnableDragToSelectRows="True" />
                                                    </ClientSettings>
                                                    <MasterTableView DataKeyNames="RoomId" ClientDataKeyNames="RoomId" CommandItemDisplay="Top" CommandItemStyle-HorizontalAlign="Right" CommandItemStyle-BackColor="lightblue"
                                                        ShowGroupFooter="False" ShowHeader="True" CommandItemStyle-Font-Bold="True" Width="100%">
                                                        <CommandItemSettings ExportToExcelText="" ShowExportToExcelButton="True" ShowAddNewRecordButton="False" ShowRefreshButton="False" />

                                                        <Columns>
                                                            <telerik:GridBoundColumn DataField="Day" DataType="System.DateTime" DataFormatString="{0:d}" FilterControlAltText="Filter Day column" HeaderText="Day" ReadOnly="True" SortExpression="Day" UniqueName="Day" Aggregate="Sum">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="Date" DataType="System.DateTime" DataFormatString="{0:d}" FilterControlAltText="Filter Date column" HeaderText="Date" ReadOnly="True" SortExpression="Date" UniqueName="Date" Aggregate="Sum">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="Time" DataType="System.DateTime" DataFormatString="{0:d}" FilterControlAltText="Filter Time column" HeaderText="Time" ReadOnly="True" SortExpression="Time" UniqueName="Time" Aggregate="Sum">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="OperatingHospital" DataType="System.String" HeaderButtonType="TextButton" FilterControlAltText="Filter OperatingHospital column" HeaderText="Operating Hospital"
                                                                ReadOnly="True" SortExpression="OperatingHospital" UniqueName="OperatingHospital" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" Width="240px" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Room" DataType="System.String" FilterControlAltText="Filter Room column" HeaderText="Room Name" Aggregate="Sum"
                                                                ReadOnly="True" SortExpression="Room" UniqueName="Room" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="CaseNoteNo" DataType="System.String" FilterControlAltText="Filter hospital number column" Aggregate="Sum"
                                                                HeaderText="Hospital No" ReadOnly="True" SortExpression="CaseNoteNo"
                                                                UniqueName="CaseNoteNo" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="ProcedureName" DataType="System.String" FilterControlAltText="Filter procedure name column" HeaderText="Procedure type"
                                                                ReadOnly="True" SortExpression="ProcedureName" UniqueName="ProcedureName" ColumnGroupName="Selectable" Aggregate="Sum">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="Endoscopist" DataType="System.String" FilterControlAltText="Filter endoscopist column" HeaderText="Endoscopist"
                                                                ReadOnly="True" SortExpression="Endoscopist" UniqueName="Endoscopist" ColumnGroupName="Selectable" Aggregate="Sum">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            <telerik:GridBoundColumn DataField="NoOfPts" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter no. of pts column" HeaderText="No. of points"
                                                                ReadOnly="True" SortExpression="NoOfPts" UniqueName="NoOfPts" ColumnGroupName="Selectable" Aggregate="Sum">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                        </Columns>
                                                    </MasterTableView>
                                                    <ClientSettings ReorderColumnsOnClient="True" AllowDragToGroup="True" AllowColumnsReorder="True">
                                                        <Selecting AllowRowSelect="True"></Selecting>
                                                        <Resizing AllowRowResize="True" AllowColumnResize="True" EnableRealTimeResize="True"
                                                            ResizeGridOnColumnResize="True"></Resizing>
                                                    </ClientSettings>
                                                    <GroupingSettings ShowUnGroupButton="true" />
                                                </telerik:RadGrid>
                                            </div>
                                        </telerik:RadPageView>
                                        <telerik:RadPageView ID="RadPagePatientPathway" runat="server" Height="100%">
                                            <div class="jagDivGrid">
                                                <asp:ObjectDataSource ID="DSPatientPathway" runat="server" SelectMethod="GetPatientPathwayQuery" TypeName="UnisoftERS.SchedulerReports" OnSelecting="DSPatientPathway_OnSelecting">
                                                    <SelectParameters>
                                                        <asp:ControlParameter Name="searchStart" DbType="Date" ControlID="RDPFrom" PropertyName="SelectedDate"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="searchEnd" DbType="Date" ControlID="RDPTo" PropertyName="SelectedDate"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="HideSuppressedEndoscopists" DbType="Boolean" ControlID="chkHideSuppressedEndo" PropertyName="Checked"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="HideSuppressedConsultants" DbType="Boolean" ControlID="chkHideSuppressedList" PropertyName="Checked"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:Parameter Name="operatingHospitalIds" DbType="String" ConvertEmptyStringToNull="true" />
                                                        <asp:Parameter Name="roomIds" DbType="String" ConvertEmptyStringToNull="True" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <telerik:RadGrid ID="RadGridPatientPathway" runat="server" Skin="Office2010Blue" GroupPanelPosition="Top" AutoGenerateColumns="False" CellSpacing="-1" PagerStyle-AlwaysVisible="true" ExportSettings-Excel-Format="XLSX" ExportSettings-ExportOnlyData="true" AllowSorting="True" AllowMultiRowSelection="True" AllowPaging="False"
                                                    OnItemDataBound="RadGridPatientPathway_ItemDataBound">
                                                    <ClientSettings>
                                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" SaveScrollPosition="True" />
                                                        <Selecting EnableDragToSelectRows="True" />
                                                    </ClientSettings>
                                                    <MasterTableView DataKeyNames="RoomId" ClientDataKeyNames="RoomId" CommandItemDisplay="Top" CommandItemStyle-HorizontalAlign="Right" CommandItemStyle-BackColor="lightblue"
                                                        ShowGroupFooter="False" ShowHeader="True" CommandItemStyle-Font-Bold="True" Width="100%">
                                                        <CommandItemSettings ExportToExcelText="" ShowExportToExcelButton="True" ShowAddNewRecordButton="False" ShowRefreshButton="False" />

                                                        <Columns>
                                                            <telerik:GridBoundColumn DataField="Day" DataType="System.DateTime" DataFormatString="{0:d}" FilterControlAltText="Filter Day column" HeaderText="Day" ReadOnly="True" SortExpression="Day" UniqueName="Day">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Date" DataType="System.DateTime" DataFormatString="{0:d}" FilterControlAltText="Filter Date column" HeaderText="Date" ReadOnly="True" SortExpression="Date" UniqueName="Date">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="BookedTime" DataType="System.DateTime" DataFormatString="{0:d}" FilterControlAltText="Filter Booked time column" HeaderText="Booked time" ReadOnly="True" SortExpression="BookedTime" UniqueName="BookedTime">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="OperatingHospital" DataType="System.String" HeaderButtonType="TextButton" FilterControlAltText="Filter OperatingHospital column" HeaderText="Operating Hospital"
                                                                ReadOnly="True" SortExpression="OperatingHospital" UniqueName="OperatingHospital" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" Width="240px" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Room" DataType="System.String" FilterControlAltText="Filter Room column" HeaderText="Room Name"
                                                                ReadOnly="True" SortExpression="Room" UniqueName="Room" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="CaseNoteNo" DataType="System.String" FilterControlAltText="Filter hospital number column"
                                                                HeaderText="Hospital No" ReadOnly="True" SortExpression="CaseNoteNo"
                                                                UniqueName="CaseNoteNo" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Procedure" DataType="System.String" FilterControlAltText="Filter procedure column" HeaderText="Procedure name"
                                                                ReadOnly="True" SortExpression="Procedure" UniqueName="Procedure" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="PatientAttended" DataType="System.DateTime" FilterControlAltText="Filter patient attended column" HeaderText="Patient Attended"
                                                                ReadOnly="True" SortExpression="PatientAttended" UniqueName="PatientAttended" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="PatientInRoom" DataType="System.DateTime" DataFormatString="{0:d}" FilterControlAltText="Filter patient in room column"
                                                                HeaderText="Patient in room" ReadOnly="True" SortExpression="PatientInRoom" UniqueName="PatientInRoom">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="PatientLeftRoom" DataType="System.DateTime" DataFormatString="{0:d}" FilterControlAltText="Filter patient left room column"
                                                                HeaderText="Patient left room" ReadOnly="True" SortExpression="PatientLeftRoom" UniqueName="PatientLeftRoom">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="TimeInDept" DataType="System.DateTime" DataFormatString="{0:d}" FilterControlAltText="Filter time in department column"
                                                                HeaderText="Time in dept" ReadOnly="True" SortExpression="TimeInDept" UniqueName="TimeInDept">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Discharged" DataType="System.DateTime" DataFormatString="{0:d}" FilterControlAltText="Filter Discharged column"
                                                                HeaderText="Discharged" ReadOnly="True" SortExpression="Discharged" UniqueName="Discharged">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                        </Columns>
                                                    </MasterTableView>
                                                </telerik:RadGrid>
                                            </div>
                                        </telerik:RadPageView>
                                        <telerik:RadPageView ID="RadPagePatientStatus" runat="server" Height="100%">
                                            <div class="jagDivGrid">
                                                <asp:ObjectDataSource ID="DSPatientStatus" runat="server" SelectMethod="GetPatientStatusQuery" TypeName="UnisoftERS.SchedulerReports" OnSelecting="DSPatientStatus_OnSelecting">
                                                    <SelectParameters>
                                                        <asp:ControlParameter Name="searchStart" DbType="Date" ControlID="RDPFrom" PropertyName="SelectedDate"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="searchEnd" DbType="Date" ControlID="RDPTo" PropertyName="SelectedDate"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="HideSuppressedEndoscopists" DbType="Boolean" ControlID="chkHideSuppressedEndo" PropertyName="Checked"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="HideSuppressedConsultants" DbType="Boolean" ControlID="chkHideSuppressedList" PropertyName="Checked"
                                                            ConvertEmptyStringToNull="True" />
                                                        <asp:Parameter Name="operatingHospitalIds" DbType="String" ConvertEmptyStringToNull="true" />
                                                        <asp:Parameter Name="roomIds" DbType="String" ConvertEmptyStringToNull="True" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <telerik:RadGrid ID="RadGridPatientStatus" runat="server" AllowSorting="True" AllowMultiRowSelection="True" AllowPaging="False"
                                                    RenderMode="Lightweight" PageSize="20" AutoGenerateColumns="False" GroupPanelPosition="Top"
                                                    PagerStyle-AlwaysVisible="True" ExportSettings-Excel-Format="ExcelML" ExportSettings-ExportOnlyData="True"
                                                    ShowGroupPanel="False" GridLines="Horizontal" Skin="Office2010Blue">
                                                    <GroupingSettings ShowUnGroupButton="False" />
                                                    <MasterTableView DataKeyNames="RoomId" ClientDataKeyNames="RoomId" CommandItemDisplay="Top" CommandItemStyle-HorizontalAlign="Right" CommandItemStyle-BackColor="lightblue"
                                                        ShowGroupFooter="False" ShowHeader="True" CommandItemStyle-Font-Bold="True" Width="100%">
                                                        <CommandItemSettings ExportToExcelText="" ShowExportToExcelButton="True" ShowAddNewRecordButton="False" ShowRefreshButton="False" />

                                                        <Columns>
                                                            <telerik:GridBoundColumn DataField="Day" DataType="System.DateTime" DataFormatString="{0:d}" FilterControlAltText="Filter Day column" HeaderText="Day" ReadOnly="True" SortExpression="Day" UniqueName="Day">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Date" DataType="System.DateTime" DataFormatString="{0:d}" FilterControlAltText="Filter Date column" HeaderText="Date" ReadOnly="True" SortExpression="Date" UniqueName="Date">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="RoomName" DataType="System.String" FilterControlAltText="Filter room name column" HeaderText="Room Name"
                                                                ReadOnly="True" SortExpression="RoomName" UniqueName="RoomName" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="OperatingHospital" DataType="System.String" HeaderButtonType="TextButton" FilterControlAltText="Filter OperatingHospital column" HeaderText="Operating Hospital"
                                                                ReadOnly="True" SortExpression="OperatingHospital" UniqueName="OperatingHospital" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" Width="240px" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="ListConsultant" DataType="System.String" FilterControlAltText="Filter list consultant column"
                                                                HeaderText="List consultant" ReadOnly="True" SortExpression="ListConsultant"
                                                                UniqueName="ListConsultant" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Endoscopist" DataType="System.String" FilterControlAltText="Filter endoscopist column" HeaderText="Endoscopist name"
                                                                ReadOnly="True" SortExpression="Endoscopist" UniqueName="Endoscopist" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="AM/PM" DataType="System.String" FilterControlAltText="Filter AM/PM column" HeaderText="AM/PM"
                                                                ReadOnly="True" SortExpression="AM/PM" UniqueName="AM/PM" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Routine" DataType="System.String" FilterControlAltText="Filter routine column" HeaderText="Routine"
                                                                ReadOnly="True" SortExpression="Routine" UniqueName="Routine" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="InPatient" DataType="System.String" FilterControlAltText="Filter in patient column" HeaderText="InPatient"
                                                                ReadOnly="True" SortExpression="InPatient" UniqueName="InPatient" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Urgent" DataType="System.String" FilterControlAltText="Filter urgent column" HeaderText="Urgent"
                                                                ReadOnly="True" SortExpression="Urgent" UniqueName="Urgent" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Planned" DataType="System.String" FilterControlAltText="Filter planned column" HeaderText="Planned"
                                                                ReadOnly="True" SortExpression="Planned" UniqueName="Planned" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="TwoWeekWait" DataType="System.String" FilterControlAltText="Filter two week wait column" HeaderText="Two Week Wait"
                                                                ReadOnly="True" SortExpression="TwoWeekWait" UniqueName="TwoWeekWait" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="OpenAccess" DataType="System.String" FilterControlAltText="Filter open access column" HeaderText="Open Access"
                                                                ReadOnly="True" SortExpression="OpenAccess" UniqueName="OpenAccess" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="BowelScreening" DataType="System.String" FilterControlAltText="Filter bowel screening column" HeaderText="Bowel Screening"
                                                                ReadOnly="True" SortExpression="BowelScreening" UniqueName="BowelScreening" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                        </Columns>
                                                    </MasterTableView>
                                                    <ClientSettings ReorderColumnsOnClient="True" AllowDragToGroup="True" AllowColumnsReorder="True">
                                                        <Selecting AllowRowSelect="True" EnableDragToSelectRows="True"></Selecting>
                                                        <Resizing AllowRowResize="True" AllowColumnResize="True" EnableRealTimeResize="True"
                                                            ResizeGridOnColumnResize="True"></Resizing>
                                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" SaveScrollPosition="True" />
                                                    </ClientSettings>
                                                </telerik:RadGrid>
                                            </div>
                                        </telerik:RadPageView>
                                        <%--<telerik:RadPageView ID="RadPageAudit" runat="server" Height="100%">
                                            <div class="jagDivGrid">
                                                <asp:ObjectDataSource ID="DSAudit" runat="server" SelectMethod="GetAuditQuery" TypeName="UnisoftERS.SchedulerReports" OnSelecting="DSAudit_OnSelecting">
                                                    <SelectParameters>
                                                        <asp:ControlParameter Name="searchStart" DbType="Date" ControlID="RDPFrom" PropertyName="SelectedDate" 
                                                                              ConvertEmptyStringToNull="True" />
                                                        <asp:ControlParameter Name="searchEnd" DbType="Date" ControlID="RDPTo" PropertyName="SelectedDate" 
                                                                              ConvertEmptyStringToNull="True" />
                                                        <asp:Parameter Name="operatingHospitalIds" DbType="String" ConvertEmptyStringToNull="true" />
                                                        <asp:Parameter Name="roomIds" DbType="String" ConvertEmptyStringToNull="True" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <telerik:RadGrid ID="RadGridAudit" runat="server" Skin="Office2010Blue" AutoGenerateColumns="False" GroupPanelPosition="Top" PagerStyle-AlwaysVisible="true" 
                                                    ExportSettings-Excel-Format="ExcelML" ExportSettings-ExportOnlyData="true">
                                                    <GroupingSettings />
                                                    <ClientSettings>
                                                        <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                                                        <Selecting EnableDragToSelectRows="True" CellSelectionMode="SingleCell"></Selecting>
                                                    </ClientSettings>
                                                    <MasterTableView DataKeyNames="RoomId" ClientDataKeyNames="RoomId" CommandItemDisplay="Top" CommandItemStyle-BackColor="lightblue"  CommandItemStyle-Font-Bold="true">
                                                        <CommandItemSettings ExportToExcelText="Export" ShowExportToExcelButton="true" ShowAddNewRecordButton="false" ShowRefreshButton="false" />
                                                        <Columns>
                                                            <telerik:GridBoundColumn DataField="Day" DataType="System.DateTime" DataFormatString="{0:P0}" FilterControlAltText="Filter Day column" HeaderText="Day" ReadOnly="True" SortExpression="Day" UniqueName="Day">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Date" DataType="System.DateTime" DataFormatString="{0:P0}" FilterControlAltText="Filter Date column" HeaderText="Date" ReadOnly="True" SortExpression="Date" UniqueName="Date">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Time" DataType="System.DateTime" DataFormatString="{0:P0}" FilterControlAltText="Filter Date column" HeaderText="Date" ReadOnly="True" SortExpression="Date" UniqueName="Date">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Room" DataType="System.String" FilterControlAltText="Filter Room column" HeaderText="Room Name" 
                                                                ReadOnly="True" SortExpression="Room" UniqueName="Room" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>
                                                            
                                                            <telerik:GridBoundColumn DataField="CaseNoteNo" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter case note number column" 
                                                                HeaderText="Case Note No" ReadOnly="True" SortExpression="CaseNoteNo" 
                                                                UniqueName="CaseNoteNo" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="Procedure" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter procedure column" HeaderText="Procedure name" 
                                                                ReadOnly="True" SortExpression="Procedure" UniqueName="Procedure" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="NoOfPts" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter number of points column" HeaderText="Number of points" 
                                                                ReadOnly="True" SortExpression="NoOfPts" UniqueName="NoOfPts" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="NoOfDays" DataType="System.Decimal" DataFormatString="{0:P0}" FilterControlAltText="Filter number of days column" HeaderText="Number of days" 
                                                                ReadOnly="True" SortExpression="NoOfDays" UniqueName="NoOfDays" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="CancelledDate" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter cancelled date column" HeaderText="Cancelled date" 
                                                                ReadOnly="True" SortExpression="CancelledDate" UniqueName="CancelledDate" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                            <telerik:GridBoundColumn DataField="CancellationReason" DataType="System.Decimal" DataFormatString="{0:0.00}" FilterControlAltText="Filter Median dose (Age <70) Pethidine column" HeaderText="Median dose (Age <70) Pethidine" 
                                                                ReadOnly="True" SortExpression="CancellationReason" UniqueName="CancellationReason" ColumnGroupName="Selectable">
                                                                <HeaderStyle HorizontalAlign="Center" />
                                                                <ItemStyle HorizontalAlign="Center" />
                                                            </telerik:GridBoundColumn>

                                                        </Columns>
                                                    </MasterTableView>
                                                </telerik:RadGrid>
                                            </div>
                                        </telerik:RadPageView>--%>
                                    </telerik:RadMultiPage>

                                </div>
                            </telerik:RadPageView>
                        </telerik:RadMultiPage>
                    </div>


                </asp:Panel>
            </telerik:RadPane>
        </telerik:RadSplitter>

        <telerik:RadWindowManager ID="RadWindowManager1" runat="server" Animation="Fade" AutoSize="true" Modal="True" RenderMode="Classic" VisibleStatusbar="False" Skin="Metro" MinHeight="500px" MinWidth="650px">
            <Windows>
                <telerik:RadWindow ID="RadWindow1" runat="server" Height="600" Width="950" AutoSize="false" CssClass="rad-window-popup" VisibleStatusbar="false" ReloadOnShow="true" />
            </Windows>
        </telerik:RadWindowManager>
    </div>

    <telerik:RadScriptBlock runat="server">

        <%-- MH commented out on 21 Jan 2022. Already added on top-- %>
        <%--<script type="text/javascript" src="../../Scripts/Reports.js"></script>--%>
        <script type="text/javascript">
            //var docURL = document.URL;
            //var grid;
            //var OGD = {}
            //OGD.columnName = "";
            //OGD.rowID = "";
            //var PEG = {}
            //PEG.columnName = "";
            //PEG.rowID = "";
            //var ERC = {}
            //ERC.columnName = "";
            //ERC.rowID = "";
            //var SIG = {}
            //SIG.columnName = "";
            //SIG.rowID = "";
            //var EUS = {}
            //EUS.columnName = "";
            //EUS.rowID = "";
            //var COL = {}
            //COL.columnName = "";
            //COL.rowID = "";
            //var Bowel = {}
            //Bowel.columnName = "";
            //Bowel.rowID = "";
            //var BPB = {}
            //BPB.columnName = "";
            //BPB.rowID = "";
            //var CON = {}
            //CON.columnName = "";
            //CON.rowID = "";

            function getMenuXML(pt, cn) {
                var res;
                var jsondata = {
                    Group: pt,
                    columnName: cn
                };
                $.ajax({
                    type: "POST",
                    async: false,
                    url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Reports/WebMethods.aspx/getMenuXML",
                    data: JSON.stringify(jsondata),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) { res = msg.d; },
                });
                return res;
            }

            function ValidatingForm(sender, args) {
                var validated = Page_ClientValidate('FilterGroup');

                if (!validated) return;
                else {
                    if ($('#BodyContentPlaceHolder_BodyContentPlaceHolder_HospitalPanel').length === 1) {
                        if (($find('<%=RadListBox1.ClientID%>').get_checkedItems().length === 0) || ($find('<%=RadListBox2.ClientID%>').get_checkedItems().length === 0)) {
                            $find('<%=RadNotification1.ClientID%>').set_text("No hospital(s) or room(s) selected!");
                            $find('<%=RadNotification1.ClientID%>').show();
                            validated = false;
                            args.set_cancel(true);
                        }
                    } else {
                        validated = true;
                    }
                }
            }
            function searchOnRoomEnter(event) {
                if (event.keyCode === 13 || event.which === 13) {
                    event.preventDefault();
                    $('#<%= RoomSearchButton.ClientID %>').click();
                }
            }
            function searchOnHospitalEnter(event) {
                if (event.keyCode === 13 || event.which === 13) {
                    event.preventDefault();
                    $('#<%= HospitalSearchButton.ClientID %>').click();
                }
            }
            function ClearRoom() {
                $('#<%= RadTextBox1.ClientID %>').val("");
            }
            
            $(document).ready(function () {
                $("#loaderPreview").hide().delay(1000);
                $("#AllOf").hide();
                $("#Since_wrapper").hide();
                $("#lbFor").hide();
                $("#n").hide();
                $("#DWMQY").hide();
                $("#selectAll").change(function () {
                    $("#SchedulerReportList :checkbox").prop('checked', $(this).prop("checked"));
                });

                $(".room-search").on('keyup', function () {
                    var item;
                    var search;
                    search = $(this).val(); //get textBox value
                    var availableRoomList = $find("<%=RadListBox2.ClientID%>"); //Get RadList

                    if (search.length > 0) {

                        for (var i = 0; i < availableRoomList._children.get_count(); i++) {
                            if (availableRoomList.getItem(i).get_text().toLowerCase().match(search.toLowerCase())) {
                                availableRoomList.getItem(i).select();
                            }
                            else {
                                availableRoomList.getItem(i).unselect();
                            }
                        }
                    }
                    else {
                        availableRoomList.clearSelection();
                        availableRoomList.selectedIndex = -1;
                    }
                });
                $.extend($.expr[":"],
                    {
                        "contains-ci": function (elem, i, match, array) {
                            return (elem.TextContent || elem.innerText || $(elem).text() || "").toLowerCase().indexOf((match[3] || "").toLowerCase()) >= 0;
                        }
                    });

                //$("#chkHideSuppressedList").change(function () {
                //    formChange();
                //});
                //$("#chkHideSuppressedEndo").change(function () {
                //    formChange();
                //});
                //$("#ComboConsultants_Input").change(function () {
                //    formChange();
                //});
            });

            <%--function formChange() {
                $("#ISMFilter").val("");
                ct = $("#ComboConsultants_Input").val();
                var hideSuppList = document.getElementById("<%=chkHideSuppressedList.ClientID%>").checked;
                var hideSuppEndo = document.getElementById("<%=chkHideSuppressedEndo.ClientID%>").checked;
                var hideSuppListToggle = "";
                var hideSuppEndoToggle = "";

                if (hideSuppList === true) {
                    hideSuppListToggle = "1";
                } else  {
                    hideSuppListToggle = "0";
                }

                if (hideSuppEndo === true) {
                    hideSuppEndoToggle = "1";
                } else  {
                    hideSuppEndoToggle = "0";
                }

                var listbox1 = $find("<%=RadListBox2.ClientID%>");
                var item1 = new Telerik.Web.UI.RadListBoxItem();
                var itemsNo1 = listbox1.get_items().get_count();
                var usr = document.getElementById("<%=SUID.ClientID%>").value;
                var text = getRooms("2");
                var parser = new DOMParser();
                var xmlDoc = parser.parseFromString(text, "text/xml");
                x = xmlDoc.documentElement.getElementsByTagName("row");
                var consultant = "";
                var reportId = "";
                listbox1.get_items().clear();
                for (var i = 0; i < x.length; i++) {
                    consultant = x[i].getAttribute("Room");
                    reportId = x[i].getAttribute("RoomId");
                    var item1 = new Telerik.Web.UI.RadListBoxItem();
                    item1.set_text(consultant);
                    item1.set_value(reportId);
                    listbox1.get_items().add(item1);
                }
            }--%>

            $(".collapsible_header").click(function () {

                $header = $(this);
                //getting the next element
                $content = $header.next();
                //open up the content needed - toggle the slide- if visible, slide up, if not slidedown.
                $content.slideToggle(500, function () {
                    var $arrowSpan = $header.find('img');
                    if ($content.is(":visible")) {
                        $arrowSpan.attr("src", "../../../../Images/icons/collapse-arrow-down.png");
                    } else {
                        $arrowSpan.attr("src", "../../../../Images/icons/collapse-arrow-up.png");
                    }
                });
            });

            <%--function OpenDetails(procType, consultantId) {
                var url = "<%= ResolveUrl("~/Products/Reports/DrillDown.aspx?procType={0}&consultantId={1}")%>";
                url = url.replace("{0}", procType);
                url = url.replace("{1}", consultantId);
                var oWnd = $find("<%= RadWindow1.ClientID %>");

                oWnd._navigateUrl = url;
                oWnd.SetSize(1200, 500);
                oWnd.show();
            }--%>

            //function onTabSelecting() {

            //    window.location.reload();

            //}

            //function TabSelected(sender, eventArgs) {
            //    sender.repaint();
            //    sender._scroller.repaint();
            //    //if ($telerik.isIE9) {
            //    //    var childList = sender.get_childListElement();
            //    //    var childListWidth = parseInt(childList.style.width);
            //    //    if (!isNaN(childListWidth))
            //    //        childList.style.width = childListWidth + 2 + "px";
            //    //}
            //} 

        </script>
    </telerik:RadScriptBlock>

</asp:Content>
