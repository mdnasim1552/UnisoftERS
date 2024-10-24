<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="FITResult.ascx.vb" Inherits="UnisoftERS.FITResult" %>
<telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
    <style type="text/css">
        .fit-result {
            display: none;
            float: left;
        }
    </style>
    <script type="text/javascript">
        $(window).on('load', function () {
            toggleFITResultSection();
        });

        $(document).ready(function () {
            $('#<%=FITValueRadTextBox.ClientID%>').on('focusout', function () {

                if (valiadteValueEntry($(this).val())) {
                    saveFITResult();
                }
                else {
                    $find('<%=RadNotification1.ClientID%>').set_text('FIT value is in the incorrect format. <br/> The accepted formats are: <br/> &bull;### <br/> &bull;###.## <br/> &bull;<### <br/> &bull;>### <br/> &bull;<###.## <br/> &bull;>###.##');
                    $find('<%=RadNotification1.ClientID%>').show();
                }
            });
            $('#<%=FitResultKnownRadioButtonList.ClientID%> input').on('change', function () {
                toggleFITResultSection();
                saveFITResult();
            });
        });

        function toggleFITResultSection() {
            if ($('#<%=FitResultKnownRadioButtonList.ClientID%> input:checked').val() == '1') {
                $('.fit-value-section').show();
                $('.fit-not-known-section').hide();
               /* #TFS 3851*/
                <%--if ($find('<%=FITValueRadTextBox.ClientID%>') != null) {
                    $find('<%=FITValueRadTextBox.ClientID%>').set_value('');
                }--%>

                if ($find('<%=FITNotKnownRadComboBox.ClientID%>') != null) {
                    $find('<%=FITNotKnownRadComboBox.ClientID%>').set_value(0);
                    $find('<%=FITNotKnownRadComboBox.ClientID%>').set_text('');
                }
            }
            else if ($('#<%=FitResultKnownRadioButtonList.ClientID%> input:checked').val() == '0') {
                $('.fit-value-section').hide();
                $('.fit-not-known-section').show();

                if ($find('<%=FITValueRadTextBox.ClientID%>') != null) {
                    $find('<%=FITValueRadTextBox.ClientID%>').set_value('');
                }

<%--                if ($find('<%=FITNotKnownRadComboBox.ClientID%>') != null) {
                    $find('<%=FITNotKnownRadComboBox.ClientID%>').set_value(0);
                    $find('<%=FITNotKnownRadComboBox.ClientID%>').set_text('');
                }--%>
            }
            else {
                $('.fit-value-section').hide();
                $('.fit-not-known-section').hide();

                if ($find('<%=FITNotKnownRadComboBox.ClientID%>') != null) {
                    $find('<%=FITNotKnownRadComboBox.ClientID%>').set_value(0);
                    $find('<%=FITNotKnownRadComboBox.ClientID%>').set_text('');
                }

                if ($find('<%=FITValueRadTextBox.ClientID%>') != null) {
                    $find('<%=FITValueRadTextBox.ClientID%>').set_value('');
                }
            }
        }


        function saveFITResult() {
            var fitValue = $('#<%= FITValueRadTextBox.ClientID%>').val();
            var fitNotKnownId = ($find('<%=FITNotKnownRadComboBox.ClientID%>').get_value() == '') ? 0 : parseInt($find('<%=FITNotKnownRadComboBox.ClientID%>').get_value());

            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.FITValue = fitValue;
            obj.FITNotKnownId = parseInt(fitNotKnownId);
            obj.selected = (fitValue > '' || fitNotKnownId > 0);

            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/saveProcedureFIT",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    refreshSummary();
                    //check if a new item was added and add that to the list. can we rebind it from here...?
                },
                error: function (x, y, z) {
                    autoSaveSuccess = false;
                    //show a message
                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                    $find('<%=FITNotKnownRadComboBox.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();

                }
            });
        }

        function valiadteValueEntry(textEntry) {
            isValid = false;

            const regex = /^(<|>|)?([0-9]+\.?[0-9]*|\.[0-9]+)$/;

            if (textEntry != '') {
                if (regex.test(textEntry)) {
                    isValid = true;
                } else {
                    isValid = false;
                }
            }
            else {
                isValid = true;
            }

            return isValid;
        }

        function FITvalue_changed(sender, args) {
            var textBoxValue = args.get_newValue();

            if (textBoxValue.indexOf('.') !== -1) {
                var decimalSplit = textBoxValue.split('.');
                if (decimalSplit[1].length > 2) {
                    var newValue = parseFloat(textBoxValue).toFixed(2);
                    sender.set_value(newValue); // Set the textbox value with two decimal places
                    args.set_cancel(true);
                }
            }
        }

        function restrictDecimalPlaces(element) {
            var textBoxValue = element.value;

            if (textBoxValue.indexOf('.') !== -1) {
                var decimalSplit = textBoxValue.split('.');
                if (decimalSplit[1].length > 2) {
                    // Keep only two decimal places
                    var newValue = parseFloat(textBoxValue).toFixed(2);
                    element.value = newValue; // Set the textbox value with two decimal places
                }
            }
        }
    </script>
</telerik:RadScriptBlock>

<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<div class="control-sub-header">FIT Result</div>
<div class="control-content">
    <table>
        <tr>
            <td>FIT value known?</td>
            <td>
                <asp:RadioButtonList ID="FitResultKnownRadioButtonList" runat="server" AutoPostBack="false" RepeatDirection="Horizontal">
                    <asp:ListItem Value="1" Text="Yes" />
                    <asp:ListItem Value="0" Text="No" />
                </asp:RadioButtonList>
            </td>

            <td style="padding-left: 15px;">
                <div class="fit-result fit-value-section">
                    value:
                    <telerik:RadTextBox ID="FITValueRadTextBox" onkeyup="restrictDecimalPlaces(this)" runat="server" Width="90" />&nbsp;<img id="FITInfoImage" runat="server" src="../Images/info-24x24.png" width="13" height="13" /><telerik:RadToolTip ID="FITFormatToolTip" runat="server" TargetControlID="FITInfoImage" Text="The following formats are accepted: <br/> &bull;### <br/> &bull;###.## <br/> &bull;<### <br/> &bull;>### <br/> &bull;<###.## <br/> &bull;>###.##" />
                </div>
                <div class="fit-result fit-not-known-section">
                    Unknown reason:
                    <telerik:RadComboBox ID="FITNotKnownRadComboBox" Text="Formation:" runat="server" Width="200" Skin="Metro" AutoPostBack="false" AppendDataBoundItems="true" DataTextField="Description" DataValueField="UniqueId" OnClientSelectedIndexChanged="saveFITResult">
                        <Items>
                            <telerik:RadComboBoxItem Text="" Value="0" />
                        </Items>
                    </telerik:RadComboBox>
                </div>
            </td>
        </tr>
    </table>
</div>
