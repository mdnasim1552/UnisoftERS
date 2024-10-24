<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="CustomDiaryAddEdit.ascx.vb" Inherits="UnisoftERS.CustomDiaryAddEdit" %>

<%@ Register Src="~/UserControls/ListTemplateSlots.ascx" TagPrefix="uc1" TagName="ListTemplateSlots" %>


<telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="CustomEditFormDiv" Skin="Metro" />

<style type="text/css">
    .list-repeat-controls {
        display: none;
    }
    /*hides hourly occurrence in recurrent rules setion*/
    .rsRecurrenceOptionList li:first-child {
        display: none;
    }

    .rsAdvRecurrenceRangePanel ul li:nth-child(2) {
        display: none;
    }

    .buttonClass {
        padding: 2px 20px;
        text-decoration: solid;
        text-decoration-color: black !important;
        border: 1px solid black;
    }

    .RadScheduler_Metro a, .RadScheduler_Metro input, .RadScheduler_Metro select, .RadScheduler_Metro textarea {
        color: black;
    }

    .new-list-table td {
        padding: 2px;
    }
</style>
<telerik:RadScriptBlock runat="server" ID="ScriptBlock1">

    <script type="text/javascript">
        var changed_ctrl;

      <%--  function proceduretype_changed(sender, args) {
            debugger;
            var proceduretypeid = parseInt(args.get_item().get_value());

            if (proceduretypeid > 0) {
                var obj = {};
                obj.procedureTypeId = proceduretypeid;
                obj.operatingHospitalId = parseInt($('#<%=OperatingHospitalIdHiddenField.ClientID%>').val());
                obj.isTraining = $('#<%=chkIsTraining.ClientID%>').is(':checked');
                obj.isNonGI = ($('#<%=rblListType.ClientID%> input:checked').val() == 0 ? true : false);
                obj.isDiagnostic = true;

                $.ajax({
                    type: "POST",
                    url: "DiarySchedule.aspx/getProcedurePoints",
                    data: JSON.stringify(obj),
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function (data) {
                        if (data.d != null) {
                            var res = JSON.parse(data.d);
                            debugger;
                            $find('<%=PointsRadNumericTextBox.ClientID%>').set_value(res.points);
                            $find('<%=SlotLengthRadNumericTextBox.ClientID%>').set_value(res.length);
                        }
                    },
                    error: function (x, y, z) {
                        console.log(x.responseJSON.Message);
                    }
                });
            }
        }--%>

        function showListTemplateWindow() {
              var oWnd = $find('<%=ListTemplateRadWindow.ClientID%>');
            oWnd.setUrl('../Products/Scheduler/Windows/AddEditListTemplate.aspx');
            oWnd.setSize(500, 550);
            oWnd.show();
        }

        function startdate_changed(sender, args) {
            var templateId = $find('<%=cbGenericTemplate.ClientID%>').get_value();
            if (templateId > 0)
                getTemplateEndTime(templateId);
            else
                $find('<%=EndTimePicker.ClientID%>').get_dateInput().set_value($find('<%=StartTimePicker.ClientID%>').get_selectedDate());

        }

        function FormatDateForURL(dateStr) {
            var day = dateStr.getDate();
            var month = dateStr.getMonth() + 1;
            var year = dateStr.getFullYear();
            var minutes = dateStr.getMinutes();
            var hours = dateStr.getHours();
            if (day < 10)
                day = "0" + day;
            if (hours < 10)
                hours = "0" + hours;
            if (month < 10)
                month = "0" + month;
            if (minutes < 10)
                minutes = "0" + minutes;
            return year + "/" + month + "/" + day + " " + hours + ":" + minutes;
        }

        function getTemplateEndTime(templateId) {
            var obj = {};
            obj.templateId = templateId;
            obj.startDateTime = $find('<%=StartTimePicker.ClientID%>').get_selectedDate();

            $.ajax({
                type: "POST",
                url: "DiarySchedule.aspx/GetTemplateEnd",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function (data) {
                    $find('<%=EndTimePicker.ClientID%>').get_dateInput().set_value(data.d);
                },
                error: function (x, y, z) {
                    console.log(x.responseJSON.Message);
                }
            });
        }

        function setEndTime(endtime) {
           
            if($find('<%=EndTimePicker.ClientID%>') != null)
                $find('<%=EndTimePicker.ClientID%>').get_dateInput().set_value(endtime);
        }


        function calculatePoints() {
            <%--var obj = {};
            obj.templateId = templateId;
            obj.startDateTime = $find('<%=StartTimePicker.ClientID%>').get_selectedDate();

            $.ajax({
                type: "POST",
                url: "DiaryPages.aspx/GetTemplateEnd",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function (data) {
                    $find('<%=EndTimePicker.ClientID%>').get_dateInput().set_value(data.d);
                },
                error: function (x, y, z) {
                    console.log(x.responseJSON.Message);
                }
            });--%>
        }

        function cbEndoscopist_changed(sender, args) {
            //check if list consultant has this selected value and set
            var lc = $find('<%=cbListConsultant.ClientID%>').findItemByValue(args.get_item().get_value());

            if (lc != null) {
                lc.select();
            }
            dropdown_changed(sender, args);
        }

        function dropdown_changed(sender, args) {
            var GITemplate = $('#<%=rblListType.ClientID%> input:checked').val();
            var templateId = $find('<%=cbGenericTemplate.ClientID%>').get_value();
            var endoId = $find('<%=cbEndoscopist.ClientID%>').get_value();
            if (GITemplate == true && templateId > 0 && endoId > 0) {
                var obj = {};
                obj.endoID = endoId
                obj.listRulesId = templateId;

                $.ajax({
                    type: "POST",
                    url: "DiarySchedule.aspx/ContainsEndoscopistProcedures",
                    data: JSON.stringify(obj),
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function (data) {
                        if (data.d == false) {
                            alert('This template has procedures that your selected endoscopist cannot perform.');
                        }
                    }
                });
            }
        }

       <%-- function showAddNewWindow(sender, args) {
            var oWnd = $find("<%= NewSlotRadWindow.ClientID%>");
            if (oWnd != null) {

                $find('<%=SlotComboBox.ClientID%>').get_items().getItem(1).select();
                $find('<%=ProcedureTypesComboBox.ClientID%>').get_items().getItem(0).select();
                $find('<%=PointsRadNumericTextBox.ClientID%>').set_value(1);

                //Mahfuz changed on 10 Oct 2021
                $find('<%=SlotLengthRadNumericTextBox.ClientID%>').set_value(15);
                $find('<%=SlotQtyRadNumericTextBox.ClientID%>').set_value(1);

                oWnd.show();

            }
        }

        function closeAddNewWindow() {
            var oWnd = $find("<%= NewSlotRadWindow.ClientID%>");
            if (oWnd != null) {
                oWnd.close();
            }
        }
--%>

        $(document).ready(function () {
            bindEvents();
            $('.repeat-pattern input').on('change', function () {
                bindEvents();
            });
        });

        //$(document).ready(function () {
        //    $('.repeat-pattern input').on('change', function () {
        //        if ($('.repeat-pattern input:checked').val() == 'd') {
        //            $('.list-repeat-controls').show();
        //            $('.repeat-frequency').text('day(s)');
        //        }
        //        else if ($('.repeat-pattern input:checked').val() == 'w') {
        //            $('.list-repeat-controls').show();
        //            $('.repeat-frequency').text('week(s)');
        //        }
        //        else if ($('.repeat-pattern input:checked').val() == 'm') {
        //            $('.list-repeat-controls').show();
        //            $('.repeat-frequency').text('month(s)');
        //        }
        //        else if ($('.repeat-pattern input').val() == 'n') {
        //            $('.list-repeat-controls').hide();
        //        }
        //    });
        //
        //
        //});

        function bindEvents() {

            if ($('.repeat-pattern input:checked').val() == 'd') {
                $('.list-repeat-controls').show();
                $('.repeat-frequency').text('day(s)');
            }
            else if ($('.repeat-pattern input:checked').val() == 'w') {
                $('.list-repeat-controls').show();
                $('.repeat-frequency').text('week(s)');
            }
            else if ($('.repeat-pattern input:checked').val() == 'm') {
                $('.list-repeat-controls').show();
                $('.repeat-frequency').text('month(s)');
            }
            else if ($('.repeat-pattern input').val() == 'n') {
                $('.list-repeat-controls').hide();
            }
        }


    </script>
</telerik:RadScriptBlock>

<telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
    <AjaxSettings>
        <%--<telerik:AjaxSetting AjaxControlID="ucListTemplateSlots">
            <UpdatedControls>
                <telerik:AjaxUpdatedControl ControlID="ucListTemplateSlots" />
            </UpdatedControls>
        </telerik:AjaxSetting>
         <telerik:AjaxSetting AjaxControlID="GenerateSlotButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="TotalPointsLabel" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>--%>
        <%--       <telerik:AjaxSetting AjaxControlID="SaveButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>--%>
        <%--<telerik:AjaxSetting AjaxControlID="RadAjaxManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="TotalPointsLabel" />
                    </UpdatedControls>
                </telerik:AjaxSetting>--%>
        <%--        <telerik:AjaxSetting AjaxControlID="SlotsRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" />
                    </UpdatedControls>
                </telerik:AjaxSetting>--%>
        <%--              <telerik:AjaxSetting AjaxControlID="GIProcedureRBL">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="GIProcedureRBL" />
                        <telerik:AjaxUpdatedControl ControlID="ProcedureTypesComboBox" />
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>--%>
        <%-- <telerik:AjaxSetting AjaxControlID="OperatingHospitalDropdown">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="OperatingHospitalDropdown" />
                        <telerik:AjaxUpdatedControl ControlID="ProcedureTypesComboBox" />
                        <telerik:AjaxUpdatedControl ControlID="TotalPointsLabel" />
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>--%>
        <%--     <telerik:AjaxSetting AjaxControlID="TrainingCheckbox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="TrainingCheckbox" UpdatePanelRenderMode="Inline" />
                        <telerik:AjaxUpdatedControl ControlID="ProcedureTypesComboBox" />
                        <telerik:AjaxUpdatedControl ControlID="TotalPointsLabel" />
                        <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>--%>
        <%--        <telerik:AjaxSetting AjaxControlID="ProcedureTypesComboBox">
            <UpdatedControls>
                <telerik:AjaxUpdatedControl ControlID="PointsRadNumericTextBox" />
                <telerik:AjaxUpdatedControl ControlID="SlotLengthRadNumericTextBox" />
                <telerik:AjaxUpdatedControl ControlID="SlotQtyRadNumericTextBox" />
                <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
            </UpdatedControls>
        </telerik:AjaxSetting>
        <telerik:AjaxSetting AjaxControlID="btnSaveAndApply">
            <UpdatedControls>
                <telerik:AjaxUpdatedControl ControlID="SlotsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                <telerik:AjaxUpdatedControl ControlID="PointsRadNumericTextBox" />
                <telerik:AjaxUpdatedControl ControlID="ProcedureTypesComboBox" />
                <telerik:AjaxUpdatedControl ControlID="SlotLengthRadNumericTextBox" />
                <telerik:AjaxUpdatedControl ControlID="SlotQtyRadNumericTextBox" />
                <telerik:AjaxUpdatedControl ControlID="SlotComboBox" />
                <telerik:AjaxUpdatedControl ControlID="TotalPointsLabel" />
                <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
            </UpdatedControls>
        </telerik:AjaxSetting>--%>
    </AjaxSettings>
</telerik:RadAjaxManager>

<telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />

<div class="rsDialog rsAdvancedEdit rsAdvancedModal" style="position: relative" id="CustomEditFormDiv">
    <asp:HiddenField ID="DiaryIdHiddenField" runat="server" />
    <asp:HiddenField ID="OperatingHospitalIdHiddenField" runat="server" />
    <div class="rsAdvTitle rsTitle">
        <div class="rsAdvInnerTitle">
            <%-- The rsAdvInnerTitle element is used as a drag handle when the form is modal. --%>
            
        </div>
        <asp:LinkButton runat="server" ID="AdvancedEditCloseButton" CssClass="rsAdvEditClose"
            CommandName="Cancel" CausesValidation="false" ToolTip='<%# Owner.Localization.AdvancedClose %>'>
            <span class="p-icon p-i-close"></span>
        </asp:LinkButton>
    </div>
    <%--  --%>
    <div class="rsAdvContentWrapper rsBody">
        <fieldset>
            <legend>Select template</legend>
            <div style="padding: 10px;">
                <div>
                    <asp:RadioButtonList ID="rblListType" runat="server" RepeatDirection="Horizontal" TextAlign="Left" Width="50%" OnSelectedIndexChanged="rblListType_SelectedIndexChanged" AutoPostBack="true">
                        <asp:ListItem Value="1" Text="GI" />
                        <asp:ListItem Value="0" Text="Non-GI" />
                    </asp:RadioButtonList>
                </div>
                <table style="width: 75%; height: 115px; margin-top: 10px;" class="new-list-table">
                    <tr>
                        <td>List name:</td>
                        <td>
                            <telerik:RadTextBox ID="ListNameRadTextBox" runat="server" />
                            &nbsp;<asp:CheckBox ID="chkIsTraining" runat="server" Text="Training" />
                        </td>
                    </tr>
                    <tr>
                        <td>List gender:</td>
                        <td>
                            <telerik:RadComboBox ID="cbListGender" runat="server" AutoPostBack="false" Filter="StartsWith" />
                        </td>
                    </tr>
                    <tr>
                        <td>Endoscopist:</td>
                        <td>
                            <telerik:RadComboBox ID="cbEndoscopist" runat="server" OnClientSelectedIndexChanged="cbEndoscopist_changed" Filter="StartsWith" />
                        </td>
                    </tr>
                    <tr>
                        <td>List consultant:</td>
                        <td>
                            <telerik:RadComboBox ID="cbListConsultant" runat="server" AutoPostBack="false" Filter="StartsWith" />
                        </td>
                    </tr>
                    <tr>
                        <td>Template:</td>
                        <td>
                            <telerik:RadComboBox ID="cbGenericTemplate" runat="server" Filter="StartsWith" OnItemDataBound="Template_ItemDataBound" AutoPostBack="true" OnSelectedIndexChanged="cbGenericTemplate_SelectedIndexChanged" />

                        </td>
                    </tr>
                    <tr>
                        <td>Start time:</td>
                        <td>
                            <table style="width: 70%;">
                                <tr>
                                    <td>
                                        <telerik:RadTimePicker runat="server" ID="StartTimePicker" CssClass="rsAdvTimePicker" Width="70px" Skin="Metro" DateInput-ShowButton="false" SelectedTime='<%# Appointment.Start.TimeOfDay %>'>
                                            <DateInput ID="DateInput3" runat="server" OnClientDateChanged="startdate_changed" />
                                            <TimeView ID="TimeView1" runat="server" Columns="2" ShowHeader="false" StartTime="06:00"
                                                EndTime="23:30" Interval="00:30" />
                                        </telerik:RadTimePicker>
                                    </td>
                                    <td>&nbsp;</td>
                                    <td>End time:</td>
                                    <td>
                                        <telerik:RadTimePicker runat="server" ID="EndTimePicker" CssClass="rsAdvTimePicker" Width="70px" Skin="Metro" DateInput-ShowButton="false" SelectedTime='<%# Appointment.Start.TimeOfDay %>' Enabled="false">
                                            <DateInput ID="DateInput1" runat="server" />
                                            <TimeView ID="TimeView2" runat="server" Columns="2" ShowHeader="false" StartTime="06:00"
                                                EndTime="23:30" Interval="00:30" />
                                        </telerik:RadTimePicker>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
                <table>
                    <tr>
                        <td style="width: 11%;">Repeat list:</td>
                        <td style="">
                            <asp:RadioButtonList ID="RepeatPatternRadioButtonList" runat="server" RepeatDirection="Horizontal" TextAlign="Left" CssClass="repeat-pattern">
                                <asp:ListItem Value="n" Selected="True">Never</asp:ListItem>
                                <asp:ListItem Value="d">Daily</asp:ListItem>
                                <asp:ListItem Value="w">Weekly</asp:ListItem>
                                <asp:ListItem Value="m">Monthly</asp:ListItem>
                            </asp:RadioButtonList>
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td>
                            <div class="list-repeat-controls">
                                &nbsp;<label>for</label>&nbsp;<telerik:RadNumericTextBox ID="RepeatCountTextBox" runat="server" Value="1" CssClass="repeat-count"
                                    IncrementSettings-InterceptMouseWheel="false"
                                    IncrementSettings-Step="1"
                                    Width="35px"
                                    MinValue="1" MaxValue="52">
                                    <NumberFormat DecimalDigits="0" />
                                </telerik:RadNumericTextBox>&nbsp;<label class="repeat-frequency">weeks</label>
                            </div>
                        </td>
                    </tr>
                </table>
                <div style="margin-top: 35px;" id="ListSlotsDiv" runat="server">
                    <uc1:ListTemplateSlots runat="server" ID="ucListTemplateSlots" />

              <%--      <div style="float: left; margin-bottom: 15px;">
                        <telerik:RadButton ID="GenerateSlotButton" runat="server" Text="Add slot" Skin="Metro" CausesValidation="true"
                            OnClientClicked="showAddNewWindow" Icon-PrimaryIconCssClass="telerikGenerate" AutoPostBack="false" Enabled="true" />
                    </div>
                    <div style="float: right; margin-right: 5px; font-weight: bold; line-height: 20px; font-size: 12px;">
                        Total points:&nbsp;<asp:Label ID="TotalPointsLabel" runat="server" Text="0" />
                    </div>
                    <div style="padding-bottom: 5px" class="gi-div">
                        <div style="float: left; padding-right: 5px; height: 240px;">
                            <telerik:RadGrid ID="SlotsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="true" Width="650" Height="240" Skin="Metro" AllowPaging="false" Style="margin-bottom: 10px;"
                                OnItemCommand="SlotsRadGrid_ItemCommand" OnItemDataBound="SlotsRadGrid_ItemDataBound">
                                <HeaderStyle Font-Bold="true" />
                                <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="LstSlotId" DataKeyNames="LstSlotId" TableLayout="Fixed">
                                    <Columns>
                                        <telerik:GridBoundColumn DataField="LstSlotId" HeaderText="" HeaderStyle-Width="0px" ItemStyle-Width="0px" />
                                        <telerik:GridTemplateColumn HeaderText="Slots" UniqueName="Slots">
                                            <ItemTemplate>
                                                <telerik:RadComboBox ID="SlotComboBox" CssClass="slot-combo-box" Width="90%" runat="server" DataSourceID="SlotStatusObjectDataSource" DataTextField="Description" DataValueField="StatusId" OnItemDataBound="SlotComboBox_ItemDataBound" SelectedValue='<%#Bind("SlotId")%>' />
                                            </ItemTemplate>
                                        </telerik:GridTemplateColumn>

                                        <telerik:GridTemplateColumn HeaderText="Procedure (reserved for)" UniqueName="Guidelines" HeaderStyle-Width="190px">
                                            <ItemTemplate>
                                                <telerik:RadComboBox ID="GuidelineComboBox" CssClass="procedure-type-combo-box" DataSourceID="GuidelineObjectDataSource" OnSelectedIndexChanged="GuidelineComboBox_SelectedIndexChanged" AutoPostBack="false" OnClientSelectedIndexChanged="proceduretype_changed" runat="server" DataTextField="SchedulerProcName" DataValueField="ProcedureTypeId" SelectedValue='<%#Eval("ProcedureTypeId")%>' />

                                            </ItemTemplate>
                                        </telerik:GridTemplateColumn>
                                        <telerik:GridTemplateColumn HeaderText="Points">
                                            <ItemTemplate>
                                                <telerik:RadNumericTextBox ID="PointsRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="0.5" Width="35px"
                                                    MinValue="0.5" MaxLength="3" MaxValue="1440" Value='<%#Convert.ToDecimal(Eval("Points")) %>' AutoPostBack="true">
                                                    <NumberFormat DecimalDigits="1" />
                                                </telerik:RadNumericTextBox>
                                            </ItemTemplate>
                                        </telerik:GridTemplateColumn>
                                        <telerik:GridTemplateColumn HeaderText="Slot length">
                                            <ItemTemplate>
                                                <telerik:RadNumericTextBox ID="SlotLengthRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false"
                                                    IncrementSettings-Step="1" Width="35px"
                                                    MinValue="1" MaxLength="3" MaxValue="1440" Value='<%#CInt(Eval("Minutes")) %>' AutoPostBack="true">
                                                    <NumberFormat DecimalDigits="0" />
                                                </telerik:RadNumericTextBox>
                                            </ItemTemplate>
                                        </telerik:GridTemplateColumn>
                                        <telerik:GridTemplateColumn HeaderText="Blocked" UniqueName="Suppresse" HeaderStyle-Width="55px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" Visible="false">
                                            <ItemTemplate>
                                                <asp:CheckBox ID="SuppressedCheckBox" runat="server" Checked='<%#Bind("Suppressed")%>' />
                                            </ItemTemplate>
                                        </telerik:GridTemplateColumn>
                                        <telerik:GridTemplateColumn HeaderText="Remove" UniqueName="Remove" HeaderStyle-Width="65px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="lnlRemoveSlot" runat="server" Text="Remove" CommandName="remove" />
                                            </ItemTemplate>
                                        </telerik:GridTemplateColumn>
                                    </Columns>
                                </MasterTableView>
                                <PagerStyle Mode="NextPrev" PagerTextFormat="Navigate Pages {4} Page {0} of {1}; Patients {2} to {3} of {5}" />
                                <ClientSettings>
                                    <Selecting AllowRowSelect="True" />
                                    <Scrolling AllowScroll="True" UseStaticHeaders="true" />
                                </ClientSettings>
                            </telerik:RadGrid>
                        </div>
                    </div>--%>
                </div>
            </div>
        </fieldset>
        <asp:Panel runat="server" ID="ButtonsPanel" CssClass="rsAdvButtonWrapper rsButtons">
            <div class="buttons" style="margin-top: 10px; padding: 10px;">
                <asp:LinkButton ID="SaveTemplateButton" runat="server" Text="Save" CssClass="buttonClass" OnClick="SaveTemplateButton_Click" />
                &nbsp;
                <asp:LinkButton runat="server" ID="CancelButton" CssClass="rsAdvEditCancel rsButton buttonClass" CommandName="Cancel"
                    CausesValidation="false">
                            <span><%= Owner.Localization.Cancel %></span>
                </asp:LinkButton>
            </div>
        </asp:Panel>
    </div>
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Position="Center" AutoCloseDelay="0" />
</div>


<telerik:RadWindowManager ID="RadWindowManager1" runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="True" Modal="True" Behavior="Close, Move" ReloadOnShow="True">
    <Windows>
           <telerik:RadWindow ID="ListTemplateRadWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="340px" Height="150px" Skin="Metro" VisibleStatusbar="false" Animation="None">
            <ContentTemplate></ContentTemplate>
        </telerik:RadWindow>
   <%--     <telerik:RadWindow ID="NewSlotRadWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" AutoSize="true" Title="Add new slot" VisibleStatusbar="false" Modal="True">
            <ContentTemplate>
                <div style="padding: 15px;">
                    <table>
                        <tr>
                            <td>Slot type</td>
                            <td>Procedure</td>
                            <td>Points</td>
                            <td>Slot length</td>
                            <td>Qty</td>
                        </tr>
                        <tr>
                            <td>
                                <telerik:RadComboBox ID="SlotComboBox" runat="server" DataSourceID="SlotStatusObjectDataSource" DataTextField="Description" DataValueField="StatusId" ZIndex="9999" />
                            </td>
                            <td>
                                <telerik:RadComboBox ID="ProcedureTypesComboBox" OnSelectedIndexChanged="ProcedureTypesComboBox_SelectedIndexChanged" DataSourceID="GuidelineObjectDataSource" AutoPostBack="false" runat="server" DataTextField="SchedulerProcName" DataValueField="ProcedureTypeId" ZIndex="99999" OnClientSelectedIndexChanged="proceduretype_changed" />
                            </td>
                            <td>
                                <telerik:RadNumericTextBox ID="PointsRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false" CssClass="slot-points"
                                    IncrementSettings-Step="0.5" Width="35px"
                                    MinValue="0.5" MaxLength="3" MaxValue="1440" Value="1">
                                    <NumberFormat DecimalDigits="1" />
                                </telerik:RadNumericTextBox></td>
                            <td>
                                <telerik:RadNumericTextBox ID="SlotLengthRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false" CssClass="slot-length"
                                    IncrementSettings-Step="1" Width="35px"
                                    MinValue="1" MaxLength="3" MaxValue="1440">
                                    <NumberFormat DecimalDigits="0" />
                                </telerik:RadNumericTextBox></td>
                            <td>

                                <telerik:RadNumericTextBox ID="SlotQtyRadNumericTextBox" runat="server" IncrementSettings-InterceptMouseWheel="false"
                                    IncrementSettings-Step="1" Width="35px"
                                    MinValue="1" MaxLength="3" MaxValue="1440" Value="1">
                                    <NumberFormat DecimalDigits="0" />
                                </telerik:RadNumericTextBox></td>
                            <td>
                                <telerik:RadButton ID="btnSaveAndApply" runat="server" Text="Add" OnClick="btnSaveAndApply_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
            </ContentTemplate>
        </telerik:RadWindow>--%>
    </Windows>
</telerik:RadWindowManager>



<asp:ObjectDataSource ID="EndoscopistsObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetEndoscopist">
    <SelectParameters>
        <asp:ControlParameter Name="isGIConsultant" ControlID="rblListType" Type="Boolean" PropertyName="SelectedValue" />
    </SelectParameters>
</asp:ObjectDataSource>

<asp:ObjectDataSource ID="SlotStatusObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetSlotStatus">
    <SelectParameters>
        <asp:Parameter Name="GI" DbType="Byte" DefaultValue="1" />
        <asp:Parameter Name="nonGI" DbType="Byte" DefaultValue="1" />
    </SelectParameters>
</asp:ObjectDataSource>

<asp:ObjectDataSource ID="GuidelineObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetGuidelines">
    <SelectParameters>
        <asp:ControlParameter ControlID="rblListType" Name="IsGI" PropertyName="SelectedValue" Type="Byte" DefaultValue="1" />
        <asp:ControlParameter ControlID="OperatingHospitalIdHiddenField" Name="operatingHospital" PropertyName="Value" />
    </SelectParameters>
</asp:ObjectDataSource>


