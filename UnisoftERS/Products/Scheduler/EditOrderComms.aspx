<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="EditOrderComms.aspx.vb" Inherits="UnisoftERS.EditOrderComms" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <link href="../../Styles/Scheduler.css" rel="stylesheet" type="text/css" />
    <link href="../../Styles/Site.css" rel="stylesheet" type="text/css" />
    <link rel="icon" type="image/png" href="../images/icons/favicon.png" />

    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-ui.min.js"></script>
    <style type="text/css">
        .toppane {
            border-bottom-style: solid !important;
            border-bottom-width: 1px !important;
            border-bottom-color: inherit !important;
            height: 100% !importnat;
        }

        .footer2 {
            border-style: solid !important;
            border-width: 10px !important;
            border-color: red !important;
        }

        .footerlink a:link {
            color: red;
        }

        .footerlink a:visited {
            color: blue;
        }

        .footerlink a:hover {
            color: green;
            text-decoration: none;
        }

        .footerlink a:active {
            color: yellow;
        }

        #ctl00_RadPane1 {
            border-bottom-style: solid !important;
            border-bottom-width: 1px !important;
        }

        #RAD_SPLITTER_PANE_CONTENT_ctl00_RadPane1 {
            overflow-x: auto !important;
        }

        .MainPage {
            overflow: hidden;
        }

        .RadMainMenu.RadMenu .rmHorizontal .rmItem {
            padding-right: 10px !important;
        }

        #ValidationNotification {
            display: none;
            border-color: #6788be;
            color: #333;
            background-color: #fff;
            font-size: 12px;
            font-family: "Segoe UI",Arial,Helvetica,sans-serif;
            box-shadow: 2px 2px 3px #6788be;
            position: fixed;
            width: 500px;
            z-index: 10000;
            visibility: visible;
            left: 710px;
            top: 428px;
            border-radius: .41666667em;
            box-sizing: content-box;
            margin: 0;
            padding: 0;
            border-width: 1px;
            border-style: solid;
            word-wrap: break-word;
            overflow: hidden;
        }

            #ValidationNotification .rnTitleBar {
                border-color: #5f90cf;
                color: #fff;
                background-color: #92b3de;
                background-image: linear-gradient(#9db7db,#7b95c6 50%,#698ac0 50%,#92b3de);
                border-bottom-color: inherit;
                margin: 0;
                padding: 4px;
                line-height: 1.25;
                border-bottom-width: 1px;
                border-bottom-style: solid;
                background-repeat: repeat-x;
                background-position: 0 0;
                border-radius: .41666667em .41666667em 0 0;
            }

            #ValidationNotification .rnCommands {
                margin: 0;
                padding: 0;
                width: auto;
                float: right;
                list-style: none;
            }

        .validation-modal {
            display: none;
            position: absolute;
            left: 0px;
            top: 0px;
            z-index: 9999;
            background-color: rgb(170, 170, 170);
            opacity: 0.5;
            width: 100%;
            height: 100%;
        }
    </style>
    <style type="text/css">
        .rsArrowBottom {
            display: none !important;
        }

        .diary-calendar input, .diary-calendar td:first-child {
            display: none;
        }

        .calender-li {
            width: 20px;
            color: white !important;
        }

        .room-tabs ul {
            margin: 0;
            padding: 0;
        }

        .room-tabs input {
            border: none;
            background: none;
        }

        .room-tabs li {
            list-style-type: none;
            background-color: #f9f9f9;
            color: #000;
            border: 1px solid #e0e0e0;
            padding: 10px 15px !important;
        }

            .room-tabs li:hover {
                border-color: #cecece;
                background-color: #e7e7e7;
                cursor: pointer;
            }

            .room-tabs li.selected {
                border-color: #25a0da;
                color: #fff;
                background-color: #25a0da;
            }

        .tod-div {
            float: left;
            width: 49%;
            padding-right: 10px;
        }

            .tod-div h2 {
                text-align: center;
            }

        .day-notes textarea {
            height: 50px;
            width: 98.5%;
            margin-top: 2px;
            resize: none;
        }

        .calenderHeaderDiv {
            width: 100%;
            height: 30px;
            line-height: 25px;
            z-index: 1000;
            border: 1px solid #25a0da;
            color: #fff;
            background-color: #25a0da;
        }

        /*.rooms-tabs div {
        border-bottom: none !important;
    }*/

        .date-toggle ul {
            float: left;
            margin: 0;
            padding: 0;
        }

        .date-toggle li {
            list-style-type: none;
            float: left;
            color: white !important;
            padding: 3px;
            margin: 2px 3px 1px 1px;
            height: 25px;
            padding: 0 3px 0 3px;
            cursor: pointer;
        }

        .date-toggle span {
            font-size: 15px;
        }

        .calender-view-toggle ul {
            float: right;
            padding-right: 10px;
            margin: 0;
            text-decoration: none;
        }

        .calender-view-toggle li {
            list-style-type: none;
            float: left;
            color: white;
            padding: 3px;
            margin: 2px 3px 1px 1px;
            height: 25px;
            padding: 0 10px 0 10px;
            cursor: pointer;
        }

        .calender-view-toggle a, .date-toggle a {
            text-decoration-line: none;
            color: white !important;
        }

        .calender-view-toggle li:hover, .calender-view-toggle li.selected-li {
            border: 1px solid white;
            margin: 1px 2px 0px 0px;
            padding: -1px 9px -1px 9px;
        }

        .context-menu-popup {
            z-index: 999 !important;
        }

        .rsAptResize, .rsAptDelete {
            visibility: hidden !important;
        }

        #RadMenu1 {
            position: fixed;
            z-index: 8001 !important;
        }

        .RadAjaxPanel {
            display: inline !important;
        }

        .rsDayView .rsHorizontalHeaderTable tr:first-child th div,
        .rsWeekView .rsHorizontalHeaderTable tr:first-child th div,
        .rsMonthView .rsHorizontalHeaderTable tr:first-child th div,
        .rsTimelineView .rsVerticalHeaderWrapper .rsVerticalHeaderTable .rsMainHeader,
        .rsAgendaView .rsAgendaRow .rsResourceHeader {
            font-weight: bolder;
            color: #004d66;
            text-align: center;
            font-size: 13px;
        }

        .rsWeekView .rsDateHeader,
        .rsTimelineView .rsHorizontalHeaderTable tr:first-child th div,
        .rsAgendaView .rsHorizontalHeaderTable tr:first-child th div,
        .rsHorizontalHeaderTable tr:nth-child(2) th div {
            color: olive;
        }

        .rsTimelineView .rsAllDayTable .rsAllDayRow {
            background-color: #fbfffb !important;
        }

        #SearchAvailableSlotDiv {
            overflow-x: hidden;
        }

        #FilterDiv {
            margin-left: 15px;
        }

            #FilterDiv div {
                margin-bottom: 5px;
            }

        .search-fieldset div {
            margin-bottom: 5px;
        }

        .patient-details-table td {
            vertical-align: top;
        }

        /*.patient-booking-slot {
        border: 0.5px dotted blue !important;
        width: 100% !important;
        padding-left: 0px !important;
        left: 0px !important;
    }*/

        .free-slot, .patient-booking-slot {
            width: 98.9% !important;
            border: 1px solid black !important;
            padding-left: 0px !important;
            left: 0px !important;
        }

        .overview-slot {
            height: 85px !important;
        }

        .overview-free {
            background-color: #46a958;
        }

        .overview-used {
            background-color: #d89f3b;
        }

        .overview-full {
            background-color: #d33a3a;
        }

        .Overview-Scheduler .rsWrap {
            height: 82px !important;
        }

        .Overview-Scheduler .rsDateWrap {
            height: 20px !important;
        }


        .end-of-list {
            text-align: center;
            width: 100% !important;
            border: 1px dashed black;
            /*padding-left: 30%;*/
        }

            .end-of-list div {
                width: 100%;
                text-align: center;
            }

        .selected-appointment {
            border: 2px solid black !important;
            width: 99.6% !important;
        }

        .no-padding {
            padding: 0px !important;
        }

        .align-left div {
            text-align: left !important;
        }

        /*.lock-list-div {
        position: absolute;
        top: -15px;
        right: 20px;
    }*/

        .lock-list-div {
            position: absolute;
            float: right;
            right: 20px;
        }

        .patient-attendance-icons {
            float: left;
            margin-right: 5px;
        }

        .tooltip-icons {
            position: relative;
            top: -3px;
        }

            .tooltip-icons img {
                width: 15px;
            }

        .patient-status-item img {
            width: 16px !important;
        }

        .tooltip-icons td {
            border: none !important;
        }

        .no-template-div {
            min-height: 400px;
            background-color: white;
            text-align: center;
            color: black;
            padding-top: 55px;
            font-size: 20px;
            border: 1px solid #ccc;
        }

        .header-session {
            border-style: solid;
            border-width: 100px;
            border: 1px solid #25a0da;
            padding-top: 10px;
            padding-bottom: 10px;
            font-size: 18px;
            font-weight: 900;
            text-align: center;
        }

        .header-diary-details {
            border-style: solid;
            border-width: 100px;
            border: 1px solid #25a0da;
            height: 70px;
            margin-top: 2px;
            padding-left: 5px;
            padding-right: 5px;
            padding-top: 5px;
            padding-bottom: 25px;
            font-size: 14px;
        }

        .hide-rooms-dropdown-div {
            display: none;
        }

        .forceMetroSkin {
            color: #333;
            font-family: "Segoe UI",Arial, Helvetica, sans-serif;
            font-size: 12px;
        }

        .forceMetroSkinbold {
            color: #333;
            font-family: "Segoe UI",Arial, Helvetica, sans-serif;
            font-size: 12px;
            font-weight: bold;
        }

        .forceMetroSkinGreenbold {
            color: green !important;
            font-family: "Segoe UI",Arial, Helvetica, sans-serif;
            font-size: 12px;            
            font-weight: bold;
        }
    </style>
    <style type="text/css">
        .RadComboBox_Vista .rcbDisabled .rcbInputCell .rcbInput,
        .RadComboBoxDropDown_Vista .rcbDisabled {
            color: #333;
            font-family: "Segoe UI",Arial, Helvetica, sans-serif;
            filter: grayscale(100%) contrast(100) !important;
            opacity: 1 !important;
            /*color: Red !important; */
            font-size: 13px !important;
        }
    </style>
</head>
<body>

    <form id="form1" runat="server" autocomplete="off">
        <asp:ScriptManager ID="RadScriptManager1" runat="server" EnablePageMethods="true" ScriptMode="Release">
            <Scripts>
                <asp:ScriptReference Path="~/Scripts/jquery-3.6.3.min.js" />
                <asp:ScriptReference Path="~/Scripts/global.js" />
            </Scripts>
        </asp:ScriptManager>
        <telerik:RadWindowManager ID="RadWindowManager1" runat="server" ReloadOnShow="true">
        </telerik:RadWindowManager>
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="divOrderDetails" Skin="Metro" />
        <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="divOrderDetails" Skin="Metro" />
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />
        <div id="divOrderDetails" runat="server" visible="true" style="padding-top: 15px;">
            <telerik:RadTabStrip ID="RadTabOrders" runat="server" Orientation="HorizontalTop" Visible="true" MultiPageID="OrderDetailMultipage" SelectedIndex="0" ReorderTabsOnSelect="true" Skin="Metro" RenderMode="Lightweight" OnClientTabSelected="settabchange">
                <Tabs>
                    <telerik:RadTab Text="Order" runat="server" PageViewID="OrderDetailPageView" Skin="Metro" />
                    <telerik:RadTab Text="Questions" runat="server" PageViewID="OrderQuestionsPageView" Skin="Metro" />
                    <telerik:RadTab Text="Previous Solus Endoscopy Procedures" runat="server" PageViewID="OrderHistoryPageView" Skin="Metro" />
                </Tabs>
            </telerik:RadTabStrip>
            <telerik:RadMultiPage ID="OrderDetailMultipage" runat="server" SelectedIndex="0">
                <telerik:RadPageView ID="OrderDetailPageView" runat="server" Height="510px" Skin="Metro">
                    <fieldset runat="server" id="Fieldset1" class="forceMetroSkin">
                        <legend>Patient Information</legend>
                            <table style="width:100%;" border="0">
                                <tr>
                                    <td>
                                        <table border="0">
                                        <tr>
                                            <asp:HiddenField ID="intPatientId" runat="server" />
                                            <asp:HiddenField ID="intOperatingHospitalId" runat="server" />
                                            <td><b>Name:</b></td>
                                            <td>
                                                <b>
                                                    <asp:Label runat="server" ID="OrderDetailPatName" /></b></td>
                                            <td rowspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                            <td style="vertical-align: text-top;">Address:</td>
                                            <td style="vertical-align: text-top;">
                                                <asp:Label runat="server" ID="OrderDetailPatAddress" /></td>
                                            <td rowspan="3">
                                                <telerik:RadButton ID="btnSelectPatient" runat="server" Text="Select Patient" Skin="Metro" Visible="false">
                                                    <Icon PrimaryIconCssClass="rbSearch" />
                                                </telerik:RadButton>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Gender:</td>
                                            <td>
                                                <asp:Label runat="server" ID="OrderDetailPatGender" /></td>
                                            <td>DOB:</td>
                                            <td>
                                                <asp:Label runat="server" ID="OrderDetailPatDOB" /></td>
                                        </tr>
                                        <tr id="CountryOfOriginHealthServiceNoEditOrderCommsRow" runat="server">
                                            <td runat="server">Hospital number:</td>
                                            <td runat="server">
                                                <asp:Label runat="server" ID="OrderDetailPatHospitalNo" /></td>
                                            <td id="HealthServiceNameIdEditOrderCommsTd" runat="server">NHS number:</td>
                                            <td runat="server">
                                                <asp:Label runat="server" ID="OrderDetailPatNHSNo" /></td>
                                        </tr>
                                    </table>
                                </td>
                                <td style="vertical-align:top;text-align:right;"><telerik:RadLabel ID="lblProcedure" runat="server" CssClass="forceMetroSkinGreenbold" Visible="false"></telerik:RadLabel></td>
                            </tr>
                        </table>
                        
                    </fieldset>
                    <span class="forceMetroSkinbold">&nbsp;&nbsp;&nbsp;PROCEDURE TYPE : </span>
                    <telerik:RadComboBox ID="cboProcedureType" runat="server" AllowCustomText="true" Skin="Vista">
                        <Items>
                            <telerik:RadComboBoxItem Text="" Value="0" />
                        </Items>
                    </telerik:RadComboBox>
                    <telerik:RadLabel ID="lblProcedureType" runat="server" CssClass="forceMetroSkinbold" Visible="false"></telerik:RadLabel>
                    <fieldset runat="server" id="Fieldset2" class="forceMetroSkin">
                        <legend>Order Information</legend>
                        <table border="0">
                            <tr>
                                <td style="width:120px;">Order Number:
                                </td>
                                <td style="min-width:140px;">
                                    <telerik:RadTextBox ID="txtOrderNumber" runat="server" Skin="Metro">
                                    </telerik:RadTextBox>
                                    <telerik:RadLabel ID="lblOrderNumber" runat="server" CssClass="forceMetroSkinbold" Visible="false"></telerik:RadLabel>
                                </td>
                                <td>&nbsp;</td>
                                <td style="min-width:80px;">Order Date:</td>
                                <td><%--<telerik:RadDatePicker ID="DodDateInput" runat="server" Width="100px" Skin="Windows7" Culture="en-GB" DateInput-DateFormat="dd/MM/yyyy" DateInput-DisplayDateFormat="dd/MM/yyyy" />--%>
                                    <telerik:RadDatePicker ID="OrderDate" Width="100px" runat="server" Skin="Metro" Culture="en-GB" />
                                    <telerik:RadLabel ID="lblOrderDate" runat="server" CssClass="forceMetroSkin" Visible="false"></telerik:RadLabel>
                                    <asp:RequiredFieldValidator ID="OrderDateRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                        ControlToValidate="OrderDate" EnableClientScript="true" Display="Dynamic"
                                        ErrorMessage="Order Date is required" Text="*" ToolTip="This is a required field">
                                    </asp:RequiredFieldValidator></td>
                                <td rowspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                <td>Due Date:</td>
                                <td><telerik:RadDatePicker ID="DueDate" runat="server" Width="100px" Skin="Metro" Culture="en-GB" />
                                    <telerik:RadLabel ID="lblDueDate" runat="server" CssClass="forceMetroSkin" Visible="false"></telerik:RadLabel>
                                    <asp:RequiredFieldValidator ID="DueDateRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                        ControlToValidate="DueDate" EnableClientScript="true" Display="Dynamic"
                                        ErrorMessage="Due Date is required" Text="*" ToolTip="This is a required field">
                                    </asp:RequiredFieldValidator></td>
                            </tr>
                            <tr>
                                <td>Date Raised:</td>
                                <td><telerik:RadDatePicker ID="DateRaised" runat="server" Width="100px" Skin="Metro" Culture="en-GB" />
                                    <telerik:RadLabel ID="lblDateRaised" runat="server" CssClass="forceMetroSkin" Visible="false"></telerik:RadLabel>
                                    <asp:RequiredFieldValidator ID="DateRaisedRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                        ControlToValidate="DateRaised" EnableClientScript="true" Display="Dynamic"
                                        ErrorMessage="Date Raised is required" Text="*" ToolTip="This is a required field">
                                    </asp:RequiredFieldValidator></td>
                                <td rowspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                <td>Date Received:</td>
                                <td>
                                    <telerik:RadDatePicker ID="DateReceived" runat="server" Width="100px" Skin="Metro" Culture="en-GB" />
                                    <telerik:RadLabel ID="lblDateReceived" runat="server" CssClass="forceMetroSkin" Visible="false"></telerik:RadLabel>
                                    <asp:RequiredFieldValidator ID="DateReceivedFieldValidator" runat="server" CssClass="aspxValidator"
                                        ControlToValidate="DateReceived" EnableClientScript="true" Display="Dynamic"
                                        ErrorMessage="Date Received is required" Text="*" ToolTip="This is a required field">
                                    </asp:RequiredFieldValidator>
                                </td>
                                <td>Patient Hospital Location:</td>
                                <td><telerik:RadTextBox ID="txtLocation" runat="server" Skin="Metro">
                                    </telerik:RadTextBox>
                                    <telerik:RadLabel ID="lblLocation" runat="server" CssClass="forceMetroSkin" Visible="false"></telerik:RadLabel></td>
                            </tr>                            
                        </table>
                    </fieldset>
                    <fieldset runat="server" id="Fieldset3" class="forceMetroSkin">
                        <legend>Referral / Order Source</legend>
                        <table border="0">
                            <tr>
                                <td style="width:120px;">Order Source:</td>
                                <td style="width:80px;">
                                    <telerik:RadComboBox ID="cboOrderSourceListNo" runat="server" AllowCustomText="true" Skin="Metro">
                                        <Items>
                                            <telerik:RadComboBoxItem Text="" Value="0" />
                                        </Items>
                                    </telerik:RadComboBox>
                                    <telerik:RadLabel ID="lblOrderSourceListNo" runat="server" CssClass="forceMetroSkin" Visible="false"></telerik:RadLabel>
                                </td>
                                <td style="width:90px;">&nbsp;&nbsp;</td>
                                <td style="min-width:80px;"><telerik:RadLabel ID="lblReferrerLabel" runat="server" CssClass="forceMetroSkin" Text="Referrer:"></telerik:RadLabel></td>
                                <td>
                                    <telerik:RadComboBox ID="cboReferringConsultant" runat="server" Filter="Contains"></telerik:RadComboBox>
                                    <telerik:RadLabel ID="lblReferringConsultant" runat="server" CssClass="forceMetroSkin" Visible="false"></telerik:RadLabel>
                                </td>
                                <td rowspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                <td><telerik:RadLabel ID="lblReferrerSpecialityLabel" runat="server" CssClass="forceMetroSkin" Text="Referrer Speciality:"></telerik:RadLabel></td>
                                <td><telerik:RadComboBox ID="cboReferringConsultantSpeciality" runat="server" Filter="Contains"></telerik:RadComboBox>
                                    <telerik:RadLabel ID="lblReferringConsultantSpeciality" runat="server" CssClass="forceMetroSkin" Visible="false"></telerik:RadLabel></td>
                            </tr>
                            <tr>
                                <td>Referring Hospital:</td>
                                <td colspan="3">
                                    <telerik:RadComboBox ID="cboReferringHospital" runat="server" Filter="Contains" Width="100%"></telerik:RadComboBox>
                                    <telerik:RadLabel ID="lblReferringHospital" runat="server" CssClass="forceMetroSkin" Visible="false"></telerik:RadLabel>
                                </td>
                                <td></td>
                                <td>Priority:</td>
                                <td><telerik:RadComboBox ID="cboOrderPriority" runat="server" AllowCustomText="true" Skin="Metro">
                                        <Items>
                                            <telerik:RadComboBoxItem Text="" Value="0" />
                                        </Items>
                                    </telerik:RadComboBox>
                                    <telerik:RadLabel ID="lblOrderPriority" runat="server" CssClass="forceMetroSkin" Visible="false"></telerik:RadLabel>
                                </td>
                            </tr>
                            <tr id="trWardBed" runat="server">
                                <td>Ward:</td>
                                <td>
                                    <telerik:RadTextBox ID="txtWard" runat="server" Skin="Metro">
                                    </telerik:RadTextBox>
                                    <telerik:RadLabel ID="lblWard" runat="server" CssClass="forceMetroSkin" Visible="false"></telerik:RadLabel>
                                </td>
                                <td style="min-width:90px;"></td>
                                <td>Bed:</td>
                                <td>
                                    <telerik:RadTextBox ID="txtBed" runat="server" Skin="Metro"></telerik:RadTextBox>
                                    <telerik:RadLabel ID="lblBed" runat="server" CssClass="forceMetroSkin" Visible="false"></telerik:RadLabel>

                                </td>
                                <td></td>
                                <td></td>
                            </tr>
                        </table>
                    </fieldset>
                     <fieldset runat="server" id="Fieldset5" class="forceMetroSkin"  style="height:200px !important;overflow:auto;">
                        <legend>Clinical Notes</legend>
                         <table>
                             <tr>
                                 <td>
<telerik:RadEditor ID="txtClinicalHistory" runat="server" EnableTextareaMode="true" AllowScripts="true" EnableEmbeddedScripts="true" Height="150px" Width="930px">
                                </telerik:RadEditor>
                                <telerik:RadLabel ID="lblClinicalHistory" runat="server" CssClass="forceMetroSkin" Visible="false" Height="150px" Width="930px"></telerik:RadLabel>
                                 </td>
                             </tr>
                         </table>
                         </fieldset>
                    <fieldset runat="server" id="Fieldset4" class="forceMetroSkin">
                        <legend>Order Status</legend>
                        <table>
                            <tr>
                                <td>Order Status:</td>
                                <td>
                                    <telerik:RadComboBox ID="cboOrderStatus" runat="server" AllowCustomText="true" Skin="Metro">
                                        <Items>
                                            <telerik:RadComboBoxItem Text="" Value="0" />
                                        </Items>
                                    </telerik:RadComboBox>
                                    <telerik:RadLabel ID="lblOrderStatus" runat="server" CssClass="forceMetroSkin" Visible="false"></telerik:RadLabel>
                                </td>
                                <td>&nbsp;&nbsp;&nbsp;</td>
                                <td>Rejection Reason:</td>
                                <td><telerik:RadComboBox ID="cboRejectionReasonId" runat="server" AllowCustomText="true" Skin="Metro" Width="300">
                                        <Items>
                                            <telerik:RadComboBoxItem Text="" Value="0" />
                                        </Items>
                                    </telerik:RadComboBox>
                                    &nbsp;
                                    <label id="RejectionReasonComboError" runat="server" style="color: red;" visible="false">* Required when rejecting.</label></td>
                            </tr>
                            <tr>
                                <td>Rejection Comments: </td>
                                <td colspan="4">
                                    <telerik:RadTextBox ID="txtRejectionComments" runat="server"
                                        TextMode="MultiLine"
                                        Rows="3"
                                        Wrap="true"
                                        Text=""
                                        Resize="Both"
                                        Columns="91">
                                    </telerik:RadTextBox>

                                </td>
                                <td>
                                    <label id="RejectionCommentsError" runat="server" style="color: red;" visible="false">* Required when rejecting.</label></td>
                            </tr>
                        </table>
                    </fieldset>
                </telerik:RadPageView>
                <telerik:RadPageView ID="OrderQuestionsPageView" runat="server" Height="510px">
                    <telerik:RadGrid ID="gridQuestionsAnswers" runat="server" Skin="Metro">
                        <MasterTableView ClientDataKeyNames="QuestionId" AutoGenerateColumns="false">
                            <Columns>
                                <telerik:GridBoundColumn DataField="QuestionId" Visible="false" ReadOnly="true">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn DataField="OrderId" Visible="false" ReadOnly="true">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn DataField="Question" HeaderText="Question">
                                </telerik:GridBoundColumn>
                                <telerik:GridBoundColumn DataField="Answer" HeaderText="Answer">
                                </telerik:GridBoundColumn>
                            </Columns>
                        </MasterTableView>
                    </telerik:RadGrid>
                </telerik:RadPageView>

                <telerik:RadPageView ID="OrderHistoryPageView" runat="server" Height="510px" CssClass="forceMetroSkin">
                    <table border="0" style="width:100%;">
                        <tr>                           
                            <th>Previous Solus Endoscopy Procedures</th>
                        </tr>
                        <tr>
                            <td style="vertical-align: top;text-align:center; padding: 0px;">
                                <label id="lblPrevHistoryNoRecords" runat="server" visible="false">No Previous Procedure found.</label>
                                <fieldset style="">
                                    <table id="tblPrevHistory" runat="server" border="0" cell-spacing="10" style="padding: 5px 5px 5px 5px;">
                                        <tr>
                                            <td>
                                                <asp:Repeater ID="rptPrevProcHistory" runat="server" OnItemDataBound="rptPrevProcHistory_ItemDataBound">
                                                    <HeaderTemplate>
                                                        <table border="0" style="min-width:400px; padding:10px 10px 10px 10px;">
                                                            <tr style="background-color:#98c3eb;padding:10px 10px 10px 10px;">
                                                                <td style="text-align:left !important;font-weight:bold;color:#2b4069;">&nbsp;Procedure Date&nbsp;&nbsp;</td>
                                                                <td style="text-align:left !important;font-weight:bold;color:#2b4069;">&nbsp;Procedure Type&nbsp;&nbsp;</td>
                                                                <td style="text-align:left !important;font-weight:bold;color:#2b4069;">&nbsp;List Consultant&nbsp;&nbsp;</td>
                                                                <td style="text-align:left !important;font-weight:bold;color:#2b4069;">&nbsp;Endoscopist&nbsp;&nbsp;</td>
                                                                <td></td>
                                                            </tr>
                                                            <tbody max-height: 500px; overflow-y: scroll">
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <tr>
                                                            <td style="text-align:left;">
                                                                <asp:HiddenField ID="hdnProcedureID" runat="server" Value='<%#Eval("ProcedureId") %>' />
                                                                <asp:HiddenField ID="hdnProcLastModifiedOn" runat="server" Value='<%#Eval("LastModifiedOn", "{0:dd MM yyyy HH:mm:ss.fff}") %>' />
                                                                <asp:HiddenField ID="hdnDocSource" runat="server" Value='<%#Eval("DocumentSource") %>' />
                                                                <%#Eval("ProcedureDate") %>&nbsp;&nbsp;&nbsp;&nbsp;
                                                            </td>
                                                            <td style="text-align:left;">
                                                                &nbsp;&nbsp;<%#Eval("ProcedureType") %>&nbsp;&nbsp;
                                                            </td>
                                                            <td style="text-align:left;">&nbsp;&nbsp;<%#Eval("ListConsultant") %>&nbsp;&nbsp;</td>
                                                            <td style="text-align:left;">&nbsp;&nbsp;<%#Eval("Endoscopist") %>&nbsp;&nbsp;</td>
                                                            <td style="text-align:right;">
                                                                &nbsp;&nbsp;&nbsp;&nbsp;<asp:Button ID="btnViewProcedureReport" runat="server" data-val-id='<%#Eval("ProcedureId") %>' data-proc-last-date='<%#Eval("LastModifiedOn", "{0:dd MM yyyy HH:mm:ss.fff}") %>' data-proc-doc-source='<%#Eval("DocumentSource") %>' Text="View Details" Enabled="true" CssClass="define-button" OnClientClick="ShowPrevProcedures(this);return false;" />
                                                            </td>
                                                        </tr>
                                                    </ItemTemplate>
                                                    <FooterTemplate>
                                                        </tbody>
                                                        </table>
                                                    </FooterTemplate>
                                                </asp:Repeater>
                                            </td>
                                        </tr>
                                    </table>
                                </fieldset>
                            </td>
                        </tr>
                        <tr>
                            <td>&nbsp;</td>
                        </tr>
                        <tr>
                            <td style="text-align: center;">
                                <telerik:RadButton ID="btnUpdateHistory" runat="server" Text="Update History" Visible="false" Icon-PrimaryIconCssClass="rbSave" Skin="Default" OnClick="btnUpdateHistory_Click" />
                            </td>
                        </tr>
                    </table>
                </telerik:RadPageView>
            </telerik:RadMultiPage>
            <div id="OrderButtons" runat="server" height="78px" style="padding-top: 10px; text-align: center; position: absolute; bottom: 0; right: 35%;">
                <label id="UpdateStatusLabel" runat="server" style="color: green; font-size: medium;" visible="false"></label>
                <br />
                <span id="spanButtons">
                    <telerik:RadButton ID="btnSaveNewOrderComm" runat="server" Text="Save Order Comm" Skin="Metro" Visible="false" />
                    <telerik:RadButton ID="btnOrderReject" runat="server" Text="Reject" Skin="Metro" OnClick="btnOrderReject_Click" ValidationGroup="SlotSearch" />
                    <telerik:RadButton ID="btnOrderAddToWaitlist" runat="server" Text="Add to Waitlist" Skin="Metro" OnClick="btnOrderAddToWaitlist_Click" />
                    <telerik:RadButton ID="btnOrderPrint" runat="server" Visible="true" Text="Print" Skin="Metro" OnClientClicked="PrintOrderComms" AutoPostBack="False" />
                    <telerik:RadButton ID="btnOrderClose" runat="server" Text="Close" Skin="Metro" OnClientClicked="CloseWindow" AutoPostBack="False" />
                </span>
            </div>
        </div>
        <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
            <script type="text/javascript">
                $(window).on('load', function () {
                });


                function ShowPrevProcedures(sender) {
                    var procedureId = $(sender).attr("data-val-id");
                    var procedureMaxDate = $(sender).attr("data-proc-last-date");
                    var procedureDocSource = $(sender).attr("data-proc-doc-source");
                    //var width = "", height = "";
                    var width = 600;
                    var height = 700;

                    //alert(procedureId);
                    //var oManager = GetRadWindow().get_windowManager();
                    //oManager.open("ViewProcDocPDF.aspx?ProcedureId=" + procedureId + "&ProcedureMaxDate=" + procedureMaxDate + "&ProcedureDocSource=" + procedureDocSource, "",width,height);
                    //var own = radopen("ViewProcDocPDF.aspx?ProcedureId=" + procedureId + "&ProcedureMaxDate=" + procedureMaxDate + "&ProcedureDocSource=" + procedureDocSource,null);
                    //own.set_visibleStatusbar(false);
                    var url = "ViewProcDocPDF.aspx?ProcedureId=" + procedureId + "&ProcedureMaxDate=" + procedureMaxDate + "&ProcedureDocSource=" + procedureDocSource

                    //window.open("ViewProcDocPDF.aspx?ProcedureId=" + procedureId + "&ProcedureMaxDate=" + procedureMaxDate + "&ProcedureDocSource=" + procedureDocSource, 'winname', 'directories=0,titlebar=0,toolbar=0,location=0,status=0,menubar=0,top=350,screenY=350,left=550,scrollbars=0,resizable=1,width=600,height=800');
                    popupWindow(url, "View Report", width, height);

                    return false;
                }
                function PrintOrderComms(sender) {
                    var width = 800;
                    var height = 800;


                    var url = "PrintOrderCommPDF.aspx?OrderCommId=" + <%=intOrderId%>

                        //window.open("ViewProcDocPDF.aspx?ProcedureId=" + procedureId + "&ProcedureMaxDate=" + procedureMaxDate + "&ProcedureDocSource=" + procedureDocSource, 'winname', 'directories=0,titlebar=0,toolbar=0,location=0,status=0,menubar=0,top=350,screenY=350,left=550,scrollbars=0,resizable=1,width=600,height=800');
                        popupWindow(url, "View OrderComm Report", width, height);

                    return false;
                }
                function popupWindow(url, windowName, w, h) {
                    var win = window

                    const y = win.top.outerHeight / 2 + win.top.screenY - (h / 2);
                    const x = win.top.outerWidth / 2 + win.top.screenX - (w / 2);


                    return win.open(url, windowName, 'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no, width=' + w + ', height=' + h + ', top=' + y + ', left=' + x);
                }
                function settabchange(sender, eventArgs) {
                    var tabStrip = $find("<%=RadTabOrders.ClientID%>");
                    var selectedTab = tabStrip.get_selectedTab();
                    //alert(selectedTab.get_index());

                    var divButtons = document.getElementById('spanButtons');
                    if (selectedTab.get_index() == 0) {
                        if (divButtons.hidden != undefined) { divButtons.hidden = false; }

                    }
                    else {
                        if (divButtons.hidden != undefined) { divButtons.hidden = true; }
                    }

                    var labelStatus = document.getElementById('UpdateStatusLabel');
                    if (labelStatus != null) { labelStatus.hidden = true; }

                }
                $(document).ready(function () {

                    var tabStrip = $find("<%=RadTabOrders.ClientID%>");
                    var selectedTab = tabStrip.get_selectedTab();
                    //alert(selectedTab.get_index());

                    var divButtons = document.getElementById('spanButtons');
                    if (selectedTab.get_index() == 0) {
                        divButtons.hidden = false;
                    }
                    else {
                        divButtons.hidden = true;
                    }
                });
            </script>
        </telerik:RadCodeBlock>
    </form>
</body>
</html>
