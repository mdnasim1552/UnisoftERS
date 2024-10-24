<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_Scheduler_SchedulerSplit" Codebehind="SchedulerSplit.aspx.vb" %>

<%@ Register TagPrefix="unisoft" TagName="Footer" Src="~/UserControls/Footer.ascx" %>
<%@ Register TagPrefix="unisoft" TagName="Appointment" Src="~/UserControls/AppointmentForm.ascx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <link href="../Styles/Site.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../Scripts/Global.js"></script>
    <style type="text/css">
        .exampleWrapper {
            float: left;
        }

        .multiPage {
        }

        .box {
            transform: rotate(270deg) !important;
            line-height: 120px !important;
            height: 120px !important;
            width: 30px !important;
        }

        .AppointmentsTable {
            border: none;
        }

            .AppointmentsTable td {
                border: none;
            }

        .AppointmentsTableHeader {
            text-align: center;
            height: 40px;
            font-weight: bold;
            background-color: #dae2e8;
            font: 20px "segoe ui",arial,sans-serif;
        }

        .AppointmentsTableHeader2 {
            text-align: center;
            height: 50px;
            font-weight: bold;
            background-color: #dae2e8;
            font: 12px "segoe ui",arial,sans-serif;
        }

        .AppointmentsTableCell {
            vertical-align: top;
        }

        .NextPrevButtons {
            font-weight: bold;
            font-size: 1.5em;
        }

        /*Disable the resize of appointments*/
        .rsAptResize {
            display: none;
        }

        .classImage {
            background: url('../Images/Search_32x32.png');
            background-position: 0 0;
            background-repeat: no-repeat;
            width: 150px;
            height: 94px;
        }

        .rtileIconImage {
             margin-top:5px !important;
             height:40px !important;
             /*width:50px !important;*/
         }
             
         .rtileTitle {
             /*text-transform:lowercase !important;*/
             font-size: 11px !important;
             /*white-space:nowrap !important;*/
             width:100% !important;
         }

         .ImageLabel {
            text-align: left;
            height: 40px;
            font-weight: bold;
            font: 12px "segoe ui",arial,sans-serif;
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="cmdOtherData" Skin="Metro" />

        <asp:SqlDataSource ID="AppointmentsObjectDataSource" runat="server"
                SelectCommand="sch_diary_page_select" 
                SelectCommandType="StoredProcedure" >
            </asp:SqlDataSource>

        <div style="margin-left: 10px;">
            <div>
                <asp:Image ID="imgLogo" runat="server" ImageUrl="~/Images/NewLogo_138_58.png" />
            </div>
            <div class="uniProductTitle">
                Scheduler<br />
                <br />
            </div>

            <telerik:RadAjaxPanel ID="RadAjaxPanel1" runat="server">
                <div>
                    <table cellspacing="0" cellpadding="0" style="margin-top:-40px;">
                        <tr>
                            <td></td>
                            <td>
                                <table>
                                    <tr>
                                        <td style="vertical-align:bottom;">
                                            <telerik:RadIconTile ID="FindSlotTile" runat="server" Height="70px" Width="90px" 
                                                Title-Text="Find slot" Skin="Metro" 
                                                ImageUrl="~/Images/dashboard-icons/find-slot.png">
                                            </telerik:RadIconTile>
                                            <%--<telerik:RadTextTile ID="RadTextTile1" runat="server" Title-Text="Find Slot" Font-Bold="true"
                                                Height="70px" Width="115px" Skin="Metro">
                                            </telerik:RadTextTile>--%>
                                            <%--<telerik:RadImageAndTextTile ID="RadImageTile1" runat="server" Text="Find Slot" ImageUrl="~/Images/Search_32x32.png">
                                                <PeekTemplateSettings Animation="Slide" ShowInterval="5000" CloseDelay="5000" AnimationDuration="1000" />
                                                <PeekTemplate>
                                                    <img src="~/Images/Search_32x32.png" alt="" />
                                                </PeekTemplate>
                                            </telerik:RadImageAndTextTile>--%>
                                            <%--<telerik:radbutton id="RadButton1" runat="server" text="Image Button" cssclass="classImage"
                                                    hoveredcssclass="classHoveredImage" pressedcssclass="classPressedImage">
                                                <Image EnableImageButton="true" />
                                            </telerik:radbutton>--%>
                                            <%--<asp:Image ID="dsa" runat="server" ImageUrl="~/Images/find.ico" /> --%>
                                            <%--<asp:ImageButton ID="FindSlotImageButton" runat="server" ImageUrl="~/Images/Search_24x24.png" ToolTip="Find booking" CssClass="image-button" />
                                            <asp:Label ID="FindSlotLabel" runat="server" CssClass="ImageLabel">Find slot</asp:Label>--%>
                                        </td>
                                        <%--<td style="width:20px;"></td>--%>
                                        <td style="vertical-align:bottom;">
                                            <telerik:RadIconTile ID="FindBookingTile" runat="server" Height="70px" Width="90px" 
                                                Title-Text="Find booking" Skin="Metro"
                                                ImageUrl="~/Images/dashboard-icons/booking.png">
                                            </telerik:RadIconTile>
                                           <%-- <telerik:RadTextTile ID="RadTextTile2" runat="server" Title-Text="Find Booking" Font-Size="6px" Font-Bold="true"
                                                Height="70px" Width="115px" Skin="Metro">
                                            </telerik:RadTextTile>--%>
                                            <%--<telerik:RadIconTile Width="120px" Height="120px" ID="radTilePASDownload" runat="server"
                                                ImageUrl="~/Images/dashboard-icons/download-to-pas.png" ImageHeight="60px" ImageWidth="70px" BackColor="#0058bc"
                                                Title-Text="PAS Download" Skin="Metro">
                                            </telerik:RadIconTile>--%>
                                            <%--<asp:Image ID="Image1" runat="server" ImageUrl="~/Images/filesearch.ico" />--%>
                                            <%--<asp:ImageButton ID="FindBookingImageButton" runat="server" ImageUrl="~/Images/Preview_24x24.png" ToolTip="Find booking" CssClass="image-button" />
                                            <asp:Label ID="FindBookingLabel" runat="server" CssClass="ImageLabel">Find slot</asp:Label>--%>
                                        </td>
                                        <td>
                                             <telerik:RadIconTile ID="ShowTodayTile" runat="server" Height="70px" Width="90px" 
                                                 Title-Text="Show today" Skin="Metro" AutoPostBack="true"
                                                 ImageUrl="~/Images/dashboard-icons/show-today.png">
                                            </telerik:RadIconTile>
                                            <%--<telerik:RadTextTile ID="RadTextTile3" runat="server" Title-Text="Show Today" Font-Size="8px" Font-Bold="true"
                                                Height="70px" Width="115px" Skin="Metro">
                                            </telerik:RadTextTile>--%>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td style="text-align: right; vertical-align: top;">
                                <telerik:RadButton ID="PrevButton" runat="server" Text="<<" CssClass="NextPrevButtons" Skin="Metro" ToolTip="Previous Week" />
                            </td>
                            <td>
                                <telerik:RadTabStrip ID="DaysRadTabStrip" runat="server" SelectedIndex="0" MultiPageID="RadMultiPage2"
                                    Orientation="HorizontalTop" Align="Justify" Skin="Metro">
                                </telerik:RadTabStrip>
                            </td>
                            <td style="vertical-align: top;">
                                <telerik:RadButton ID="NextButton" runat="server" Text=">>" CssClass="NextPrevButtons" Skin="Metro" ToolTip="Next Week" />
                            </td>
                        </tr>
                        <tr>
                            <td style="vertical-align: top;">
                                <telerik:RadTabStrip ID="RoomsRadTabStrip" runat="server" SelectedIndex="0" MultiPageID="RadMultiPage2"
                                    Orientation="VerticalLeft" Skin="Metro" Style="float: left;">
                                    <Tabs>
                                        <telerik:RadTab Text="Endo Room 1" />
                                        <telerik:RadTab Text="Endo Room 2" />
                                        <telerik:RadTab Text="Endo Room 3" />
                                        <telerik:RadTab Text="X-Ray" />
                                    </Tabs>
                                </telerik:RadTabStrip>
                            </td>
                            <td>
                                <table cellspacing="0" cellpadding="0" class="AppointmentsTable">
                                    <tr>
                                        <th class="AppointmentsTableHeader">Morning</th>
                                        <th class="AppointmentsTableHeader" style="width: 20px"></th>
                                        <th class="AppointmentsTableHeader">Afternoon</th>
                                        <th class="AppointmentsTableHeader" style="width: 20px"></th>
                                        <th class="AppointmentsTableHeader">Evening</th>
                                    </tr>
                                    <tr>
                                        <td class="AppointmentsTableHeader2">
                                            <table style="width: 100%">
                                                <tr>
                                                    <td style="text-align: right;">List Consultant</td>
                                                    <td style="width: 5px"></td>
                                                    <td style="text-align: left;">Dr Eric Haley</td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align: right;">Endoscopist</td>
                                                    <td></td>
                                                    <td style="text-align: left;">Mr G Cosgrove</td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td class="AppointmentsTableHeader2"></td>
                                        <td class="AppointmentsTableHeader2">
                                            <table style="width: 100%">
                                                <tr>
                                                    <td style="text-align: right;">List Consultant</td>
                                                    <td style="width: 5px"></td>
                                                    <td style="text-align: left;">Mr B Sturgemon</td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align: right;">Endoscopist</td>
                                                    <td></td>
                                                    <td style="text-align: left;">Dr Eric Haley</td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td class="AppointmentsTableHeader2"></td>
                                        <td class="AppointmentsTableHeader2">
                                            <table style="width: 100%">
                                                <tr>
                                                    <td style="text-align: right;">List Consultant</td>
                                                    <td style="width: 5px"></td>
                                                    <td style="text-align: left;">Dr K Forsythe</td>
                                                </tr>
                                                <tr>
                                                    <td style="text-align: right;">Endoscopist</td>
                                                    <td></td>
                                                    <td style="text-align: left;">(None)</td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="AppointmentsTableCell">
                                            <telerik:RadMultiPage ID="RadMultiPage2" runat="server" SelectedIndex="0">
                                                <telerik:RadPageView ID="radPage1" runat="server" BorderStyle="None" BorderWidth="0">
                                                    <telerik:RadScheduler runat="server" ID="RadScheduler1" Width="300px" Height="500px"
                                                        FirstDayOfWeek="Monday" LastDayOfWeek="Friday" OverflowBehavior="Auto" SelectedView="DayView"
                                                        DayStartTime="08:00:00" DayEndTime="13:00:00" HoursPanelTimeFormat="H:mm"
                                                        Skin="Metro"
                                                        ShowHeader="false" ShowFooter="false" ShowAllDayRow="false"
                                                        DataSourceID="AppointmentsObjectDataSource" DataKeyField="ID" DataSubjectField="Subject" DataStartField="Start" DataEndField="End"
                                                        BorderStyle="None" BorderWidth="0"
                                                        StartInsertingInAdvancedForm="true" AllowInsert="true" AllowEdit="true">
                                                        <AdvancedForm Modal="true"></AdvancedForm>
                                                        <AdvancedInsertTemplate>
                                                            <unisoft:Appointment ID="dsada" runat="server" />
                                                        </AdvancedInsertTemplate>
                                                        <AppointmentTemplate>
                                                            <div>
                                                                <%#Eval("Subject") %>
                                                                <span id="test" runat="server">
                                                                    <br />
                                                                    0013, Patient
                                                            <br />
                                                                    PEG insertion
                                                                </span>
                                                            </div>
                                                        </AppointmentTemplate>
                                                        <DayView HeaderDateFormat="dd/MM/yyyy" ShowResourceHeaders="false" />
                                                        <TimeSlotContextMenuSettings EnableDefault="true"></TimeSlotContextMenuSettings>
                                                        <AppointmentContextMenuSettings EnableDefault="true"></AppointmentContextMenuSettings>
                                                    </telerik:RadScheduler>
                                                </telerik:RadPageView>
                                            </telerik:RadMultiPage>
                                        </td>
                                        <td></td>
                                        <td class="AppointmentsTableCell">
                                            <telerik:RadMultiPage ID="RadMultiPage1" runat="server" SelectedIndex="0">
                                                <telerik:RadPageView ID="RadPageView1" runat="server">
                                                    <telerik:RadScheduler runat="server" ID="RadScheduler2" Width="300px" Height="500px"
                                                        FirstDayOfWeek="Monday" LastDayOfWeek="Friday" OverflowBehavior="Auto" SelectedView="DayView"
                                                        DayStartTime="13:00:00" DayEndTime="17:00:00" HoursPanelTimeFormat="HH:mm"
                                                        Skin="Metro"
                                                        ShowHeader="false" ShowFooter="false" ShowAllDayRow="false"
                                                        DataSourceID="AppointmentsObjectDataSource" DataKeyField="ID" DataSubjectField="Subject" DataStartField="Start" DataEndField="End"
                                                        StartInsertingInAdvancedForm="true" AllowInsert="true" AllowEdit="true">
                                                        <AdvancedForm Modal="true"></AdvancedForm>
                                                        <AdvancedInsertTemplate>
                                                            <unisoft:Appointment ID="ytrry" runat="server" />
                                                        </AdvancedInsertTemplate>
                                                        <AppointmentTemplate>
                                                            <div>
                                                                <%#Eval("Subject") %>
                                                                <span id="test" runat="server">
                                                                    <br />
                                                                    0013, Patient
                                                            <br />
                                                                    PEG insertion
                                                                </span>
                                                            </div>
                                                        </AppointmentTemplate>
                                                        <TimeSlotContextMenuSettings EnableDefault="true"></TimeSlotContextMenuSettings>
                                                        <AppointmentContextMenuSettings EnableDefault="true"></AppointmentContextMenuSettings>
                                                    </telerik:RadScheduler>
                                                </telerik:RadPageView>
                                            </telerik:RadMultiPage>
                                        </td>
                                        <td></td>
                                        <td class="AppointmentsTableCell">
                                            <telerik:RadMultiPage ID="RadMultiPage3" runat="server" SelectedIndex="0">
                                                <telerik:RadPageView ID="RadPageView2" runat="server">
                                                    <telerik:RadScheduler runat="server" ID="RadScheduler3" Width="300px" Height="500px"
                                                        FirstDayOfWeek="Monday" LastDayOfWeek="Friday" OverflowBehavior="Auto" SelectedView="DayView"
                                                        DayStartTime="17:00:00" DayEndTime="20:00:00" HoursPanelTimeFormat="H:mm"
                                                        Skin="Metro"
                                                        ShowHeader="false" ShowFooter="false" ShowAllDayRow="false"
                                                        DataSourceID="AppointmentsObjectDataSource" DataKeyField="ID" DataSubjectField="Subject" DataStartField="Start" DataEndField="End"
                                                        StartInsertingInAdvancedForm="true" AllowInsert="true" AllowEdit="true">
                                                        <AdvancedForm Modal="true"></AdvancedForm>
                                                        <AdvancedInsertTemplate>
                                                            <unisoft:Appointment ID="mnbmnb" runat="server" />
                                                        </AdvancedInsertTemplate>
                                                        <AppointmentTemplate>
                                                            <div>
                                                                <%#Eval("Subject") %>
                                                                <span id="test" runat="server">
                                                                    <br />
                                                                    0087, Patient
                                                            <br />
                                                                    [PB]
                                                                </span>
                                                            </div>
                                                        </AppointmentTemplate>
                                                        <TimeSlotContextMenuSettings EnableDefault="true"></TimeSlotContextMenuSettings>
                                                        <AppointmentContextMenuSettings EnableDefault="true"></AppointmentContextMenuSettings>
                                                    </telerik:RadScheduler>
                                                </telerik:RadPageView>
                                            </telerik:RadMultiPage>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </div>
            </telerik:RadAjaxPanel>
            <unisoft:Footer ID="SchFooter" runat="server" />
        </div>
    </form>
</body>
</html>
