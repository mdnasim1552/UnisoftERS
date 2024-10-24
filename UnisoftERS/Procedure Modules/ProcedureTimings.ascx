<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="ProcedureTimings.ascx.vb" Inherits="UnisoftERS.ProcedureTimings" %>

<telerik:RadScriptBlock runat="server">
    <style>
          /* added BY FERDOWSI TFS -4160 */
        .RadPicker .rcCalPopup, .RadPicker .rcTimePopup{
            display: none !important;  
        }
        .error-border {
            border-color: red !important;
        }
    </style>
    <script type="text/javascript">
        var upperWithdrawalTime = Number.MAX_SAFE_INTEGER;
        var lowerWithdrawalTime = Number.MAX_SAFE_INTEGER;
        $(document).ready(function () {
            $('form').on('keypress', function (e) {
                return e.keyCode !== 13;
            });
            $('#<%=ChooseStartFromImageRadButton.ClientID%>').on('click', function () {
                showTimingsImagePicker('start');
            });
            $('#<%=ChooseEndFromImageRadButton.ClientID%>').on('click', function () {
                showTimingsImagePicker('end');
            });

            $('#<%=btnStartDateTimeNow.ClientID%>').on('click', function () {
                startdatetimenow();
            });

            $('#<%=btnEndDateTimeNow.ClientID%>').on('click', function () {
                enddatetimenow();
            });

            $('#<%=ProcedureStartRadTimePicker.ClientID%>').on('focusout', function () {
                updateProcedureTimings();
            });

            $('#<%=ProcedureEndRadTimePicker.ClientID%>').on('focusout', function () {
                updateProcedureTimings();
            });
            $('#<%=ChooseWithDrawalStartFromImageRadButton.ClientID%>').on('click', function () {            
                showCeacumImagePicker('start');
            });
        });

        function showTimingsImagePicker(section) {
            var oWnd = $find('<%=ImagePickerRadWindow.ClientID%>');
            oWnd.setUrl("../Common/ImagePicker.aspx?control=timings&section=" + section);
            oWnd.setSize(500, 550);
            oWnd.show();
        }

        function resetProcedureDates() {
           <%-- var time = new Date();

            $find('<%=ProcedureStartDateRadTimeInput.ClientID%>').set_selectedDate(time);
            $find('<%=ProcedureStartRadTimePicker.ClientID%>').get_dateInput().set_textBoxValue('');
            $find('<%=ProcedureEndDateRadTimeInput.ClientID%>').set_selectedDate(time);
            $find('<%=ProcedureEndRadTimePicker.ClientID%>').get_dateInput().set_textBoxValue('');--%>
        }
        function startCaecumImageSelected(section, imageTimeStamp) {
            var time = new Date(imageTimeStamp);

            if (section == "start") {
                $find('<%=CaecumStartDateRadTimeInput.ClientID%>').set_selectedDate(time);
                $find('<%=CaecumTimeRadTimePicker.ClientID%>').get_timeView().setTime(time.getHours(),
                    time.getMinutes(),
                    time.getSeconds(),
                    time);
            }
            else if (section == 'end') {
                $find('<%=CaecumStartDateRadTimeInput.ClientID%>').set_selectedDate(time);
                $find('<%=CaecumTimeRadTimePicker.ClientID%>').get_timeView().setTime(time.getHours(),
                    time.getMinutes(),
                    time.getSeconds(),
                    time);
            }

            updateCaecumTimings();
        }

        function startTimingsImageSelected(section, imageTimeStamp) {
            var time = new Date(imageTimeStamp);

            if (section == "start") {
                $find('<%=ProcedureStartDateRadTimeInput.ClientID%>').set_selectedDate(time);
                $find('<%=ProcedureStartRadTimePicker.ClientID%>').get_timeView().setTime(time.getHours(),
                    time.getMinutes(),
                    time.getSeconds(),
                    time);
            }
            else if (section == 'end') {
                $find('<%=ProcedureEndDateRadTimeInput.ClientID%>').set_selectedDate(time);
                $find('<%=ProcedureEndRadTimePicker.ClientID%>').get_timeView().setTime(time.getHours(),
                    time.getMinutes(),
                    time.getSeconds(),
                    time);
            }

            updateProcedureTimings();
        }

        function updateProcedureTimings() {
            var startDate = $find('<%=ProcedureStartDateRadTimeInput.ClientID%>').get_selectedDate();
            var startTime = $find('<%=ProcedureStartRadTimePicker.ClientID%>').get_timeView().getTime();

            var endDate = $find('<%=ProcedureEndDateRadTimeInput.ClientID%>').get_selectedDate();
            var endTime = $find('<%=ProcedureEndRadTimePicker.ClientID%>').get_timeView().getTime();

            if (startTime != null) {
                //join controls to make datetime 
                startDate.setHours(startTime.getHours());
                startDate.setMinutes(startTime.getMinutes());
            }
            else {
                startDate = null;
            }

            if (endTime != null) {
                //join controls to make datetime 
                endDate.setHours(endTime.getHours());
                endDate.setMinutes(endTime.getMinutes());
            }
            else {
                endDate = null;
            }

            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.procedureTypeId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_TYPE)%>);
            obj.startDateTime = startDate;
            obj.endDateTime = endDate;


            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveProcedureTimings",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function (data) {
                    setRehideSummary();

                    if ($('.withdrawal-time').length > 0) {
                        var withdrawalTime = $find($('.withdrawal-time')[0].id);
                        if (data.d > 0 && withdrawalTime.get_value() == '')
                            withdrawalTime.set_value(data.d);
                    }
                },
                error: function (x, y, z) {
                    autoSaveSuccess = false;
                    //show a message
                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                    $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();
                }
            });

        }

        function startdatetimenow() {
            var currentdate = new Date();

            $find('<%=ProcedureStartDateRadTimeInput.ClientID%>').set_selectedDate(currentdate);
            var hours = currentdate.getHours();

            var timeView = $find('<%=ProcedureStartRadTimePicker.ClientID%>').get_timeView()
            if (timeView != null) {
                timeView.setTime(hours,
                    currentdate.getMinutes(),
                    currentdate.getSeconds(),
                    currentdate);
            }


            //updateProcedureTimings();
        }

        function enddatetimenow() {
            var currentdate = new Date();

            $find('<%=ProcedureEndDateRadTimeInput.ClientID%>').set_selectedDate(currentdate);
            var hours = currentdate.getHours();

            var timeView = $find('<%=ProcedureEndRadTimePicker.ClientID%>').get_timeView()
            if (timeView != null) {
                timeView.setTime(hours,
                    currentdate.getMinutes(),
                    currentdate.getSeconds(),
                    currentdate);
            }


            //updateProcedureTimings()

        }


        function startCaecumImageSelected(section, imageTimeStamp) {
            var time = new Date(imageTimeStamp);

            if (section == "start") {
                $find('<%=CaecumStartDateRadTimeInput.ClientID%>').set_selectedDate(time);
                $find('<%=CaecumTimeRadTimePicker.ClientID%>').get_timeView().setTime(time.getHours(),
                    time.getMinutes(),
                    time.getSeconds(),
                    time);
            }
            else if (section == 'end') {
                $find('<%=CaecumStartDateRadTimeInput.ClientID%>').set_selectedDate(time);
                $find('<%=CaecumTimeRadTimePicker.ClientID%>').get_timeView().setTime(time.getHours(),
                    time.getMinutes(),
                    time.getSeconds(),
                    time);
            }

            updateCaecumTimings();
        }

        function setControls(enabled) {
            $find('<%=CaecumTimeRadTimePicker.ClientID%>').set_enabled(enabled);
            $find('<%=TimeForWithdrawalMinRadNumericTextBox.ClientID%>').set_enabled(enabled);
        }

        function withdrawaltime_changed(sender, args) {
            
                <%--saveWithdrawalTime($find('<%=TimeForWithdrawalMinRadNumericTextBox.ClientID%>').get_value() );--%>
            validateProceduralTimings(sender);
        }

        function saveWithdrawalTime(mins) {
            var obj = {};
       
            obj.minutes = mins;
        
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveWithdrawalTime",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function (data) {
                    $('#<%=SaveWithdrawalTimeLinkButton.ClientID%>').hide();
                },
                error: function (x, y, z) {
                    autoSaveSuccess = false;
                    //show a message
                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');
                    $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();
                }
            });

            return false;
        }

        function showCeacumImagePicker(section) {
            var oWnd = $find('<%=ImagePickerRadWindow.ClientID%>');
            oWnd.setUrl("../Common/ImagePicker.aspx?control=caecum&section=" + section);
            oWnd.setSize(500, 550);
            oWnd.show();
        }
        function updateCaecumTimings() {
            var startDate = $find('<%=CaecumStartDateRadTimeInput.ClientID%>').get_selectedDate();
            var startTime = $find('<%=CaecumTimeRadTimePicker.ClientID%>').get_timeView().getTime();

            if (startTime != null) {
                startDate.setHours(startTime.getHours());
                startDate.setMinutes(startTime.getMinutes());
            }

            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.startDateTime = startDate;
            obj.selected = (startTime != null);

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveTimeToCaecum",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function (data) {
                    //update withdrawal time if returned
                    if (data.d != null || data.d > 0) {
                        $find('<%=TimeForWithdrawalMinRadNumericTextBox.ClientID%>').set_value(data.d)
                    }

                },
                error: function (x, y, z) {
                    //show a message
                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                    $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();

                }
            });

            return false;
        }



        function withdrawalTime_changed(sender, args) {
            
            <%--$('.cb-extent').each(function (idx, itm) {
                /*   var endoscopistId = $(this).attr('data-endoscopistid');*/

                saveUpperWithdrawalTime($find('<%=TimeForUpperWithdrawalMinRadNumericTextBox.ClientID%>').get_value());
            });--%>
            validateProceduralTimings(sender);
        } 

        function validateProceduralTimings(sender) {
            var maxValue = 120;/*$find("ProcTimings_TimeForUpperWithdrawalMinRadNumericTextBox").get_maxValue();*/
            var selectedItem = null;
            if (sender.get_id().indexOf('TimeForUpperWithdrawalMinRadNumericTextBox') > -1) selectedItem = $find('<%=TimeForUpperWithdrawalMinRadNumericTextBox.ClientID%>');
            else selectedItem = $find('<%=TimeForWithdrawalMinRadNumericTextBox.ClientID%>')
            var currentValue = selectedItem.get_value();
            if (parseInt(currentValue) > parseInt(maxValue)) {
                $find('<%=RadNotification1.ClientID%>').set_text('Maximum Time for Withdrawal is ' + maxValue);
                $find('<%=RadNotification1.ClientID%>').show();
                setTimeout(function () {
                    if (selectedItem !== undefined && selectedItem !== null) {
                        <%--var originalValue = $find('<%=TimeForUpperWithdrawalMinRadNumericTextBox.ClientID%>')._originalInitialValueAsText;--%>
                        
                        if (sender.get_id().indexOf('TimeForUpperWithdrawalMinRadNumericTextBox') > -1) {
                            /*selectedItem.set_value(upperWithdrawalTime === Number.MAX_SAFE_INTEGER ? maxValue : upperWithdrawalTime);*/
                            $('#ProcTimings_TimeForUpperWithdrawalMinRadNumericTextBox').css('border-color', 'red');
                            /*if (upperWithdrawalTime === Number.MAX_SAFE_INTEGER) saveUpperWithdrawalTime(maxValue);*/
                        }
                        else {
                            //selectedItem.set_value(lowerWithdrawalTime === Number.MAX_SAFE_INTEGER ? maxValue : lowerWithdrawalTime);
                            $('#ProcTimings_TimeForWithdrawalMinRadNumericTextBox').css('border-color', 'red');
                            //if (lowerWithdrawalTime === Number.MAX_SAFE_INTEGER) saveWithdrawalTime(maxValue);
                        }
                        
                    }
                }, 1);
            } else if (selectedItem.get_value() !== '') {
                if (sender.get_id().indexOf('TimeForUpperWithdrawalMinRadNumericTextBox') > -1) {
                    upperWithdrawalTime = selectedItem.get_value();
                    saveUpperWithdrawalTime(selectedItem.get_value());
                } else {
                    lowerWithdrawalTime = selectedItem.get_value();
                    saveWithdrawalTime($find('<%=TimeForWithdrawalMinRadNumericTextBox.ClientID%>').get_value());
                }
                
            }
        }

        function saveUpperWithdrawalTime(mins) {
            var obj = {};        
            obj.minutes = mins;
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveUpperWithdrawalTime",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function (data) {
                    setRehideSummary();
                   
                },
                error: function (x, y, z) {
                    autoSaveSuccess = false;
                    //show a message
                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                    $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();
                }
            });

            return false;
        } 
    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<div class="control-content">
    <table>
        <tr>
            <td>
                <span>Start time</span>
            </td>
            <td>
                <telerik:RadDateInput ID="ProcedureStartDateRadTimeInput" runat="server" Width="100" DisplayDateFormat="dd/MM/yyyy" OnClientDateChanged="updateProcedureTimings" CssClass="procedure-start-date" />
                <telerik:RadTimePicker ID="ProcedureStartRadTimePicker"   runat="server" Enabled="true" DateInput-OnClientDateChanged="updateProcedureTimings" Width="50px" CssClass="procedure-start-time"> <%--' WIDTH MODIFIED BY FERDOWSI TFS -4160--%>
                 
                </telerik:RadTimePicker>
            </td>
            <td>
                <telerik:RadButton ID="btnStartDateTimeNow" runat="server" Text="Now" AutoPostBack="false" />
                &nbsp;
                <telerik:RadButton ID="ChooseStartFromImageRadButton" runat="server" Text="Choose from photo" AutoPostBack="false" />
            </td>
        </tr>
        <tr>
            <td>
                <span>End time</span>
            </td>
            <td>
                <telerik:RadDateInput ID="ProcedureEndDateRadTimeInput" runat="server" Width="100" OnClientDateChanged="updateProcedureTimings"  CssClass="procedure-end-date" />
                <telerik:RadTimePicker ID="ProcedureEndRadTimePicker" runat="server" Enabled="true" DateInput-OnClientDateChanged="updateProcedureTimings" Width="50px" CssClass="procedure-end-time" />  <%--' WIDTH MODIFIED BY FERDOWSI TFS -4160--%>
            </td>
            <td>
                <telerik:RadButton ID="btnEndDateTimeNow" runat="server" Text="Now" AutoPostBack="false" />
                &nbsp;
                <telerik:RadButton ID="ChooseEndFromImageRadButton" runat="server" Text="Choose from photo" AutoPostBack="false" />
            </td>
        </tr>
    </table>
    <table id="WithdrawalUpper" runat="server" visible="false">
        <tr>
            <td>
                <asp:Label runat="server" ID="Label1" Text="Time for withdrawal" />
                <img src="../../Images/NEDJAG/JAG.png" />
          </td>
            <td>
                <telerik:RadNumericTextBox ID="TimeForUpperWithdrawalMinRadNumericTextBox" runat="server" CssClass="tb-withdrawalmins withdrawal-time"
                    IncrementSettings-InterceptMouseWheel="false"
                    IncrementSettings-Step="1"
                    Width="45px"
                    MinValue="0"
                    Culture="en-GB" DbValueFactor="1" LabelWidth="20px">
                    <ClientEvents OnValueChanged="withdrawalTime_changed" />
                    <NumberFormat DecimalDigits="0" />
                </telerik:RadNumericTextBox>
                <asp:Label runat="server" ID="Label2" Text="min" />
            </td>
            <td></td>
        </tr>
    </table>

    <table id="WithdrawalLower" runat="server" visible="false" >
                <tr id="CaecumTimingTR" class="CaecumTimingTR">
            <td> 
                <asp:Label runat="server" ID="TimetocaecumLabel_NED" Text="Withdrawal start time" />
                <img src="../../Images/NEDJAG/JAG.png" />
            </td>
            <td>
                <telerik:RadDateInput ID="CaecumStartDateRadTimeInput" runat="server" Width="100" DisplayDateFormat="dd/MM/yyyy" OnClientDateChanged="updateCaecumTimings" />
            </td>
            <td>
                <telerik:RadTimePicker ID="CaecumTimeRadTimePicker" runat="server" Enabled="true" DateInput-OnClientDateChanged="updateCaecumTimings" Width="50px" /> <%--' WIDTH MODIFIED BY FERDOWSI TFS -4160--%>
            </td>
            <td>
                <telerik:RadButton ID="ChooseWithDrawalStartFromImageRadButton" runat="server" Text="Choose from photo" AutoPostBack="false" />
            </td>
        </tr>
        <tr>
            <td> 
                <asp:Label runat="server" ID="Label6" Text="Total time of withdrawal" />
                <img src="../../Images/NEDJAG/JAG.png" />
            </td>
            <td>
                <telerik:RadNumericTextBox ID="TimeForWithdrawalMinRadNumericTextBox" runat="server" CssClass="extent-control withdrawal-time"
                    IncrementSettings-InterceptMouseWheel="false"
                    IncrementSettings-Step="1"
                    Width="45px"
                    MinValue="0" 
                    
                    Culture="en-GB" DbValueFactor="1" LabelWidth="20px">
                    <ClientEvents OnValueChanged="withdrawaltime_changed" />
                    <NumberFormat DecimalDigits="0" />
                </telerik:RadNumericTextBox>
                <asp:Label runat="server" ID="Label5" Text="min" />
            </td>
            <td>
                <asp:LinkButton ID="SaveWithdrawalTimeLinkButton" runat="server" Text="Save" Style="display: none;" OnClientClick="return saveWithdrawalTime()" />
            </td>

        </tr>
    </table>

</div>
<telerik:RadWindowManager ID="WindowManager1" runat="server" ShowContentDuringLoad="false" Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="True" Modal="True" Behavior="Close, Move">
    <Windows>
        <telerik:RadWindow ID="ImagePickerRadWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="340px" Height="150px" Skin="Metro" Title="Choose image" VisibleStatusbar="false" Animation="None">
            <ContentTemplate></ContentTemplate>
        </telerik:RadWindow>
    </Windows>
</telerik:RadWindowManager>
