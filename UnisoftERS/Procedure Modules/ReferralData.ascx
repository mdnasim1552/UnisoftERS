<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="ReferralData.ascx.vb" Inherits="UnisoftERS.ReferralData" %>

<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;
        $(window).on('load', function () {

        });

        $(document).ready(function () {
             $('#<%=DateBronchRequestedDatePicker.ClientID%>').on('focusout', function () {
                saveReferralData();
             });

             $('#<%=DateOfReferralDatePicker.ClientID%>').on('focusout', function () {
                saveReferralData();
             });

             $('#<%=DateOfScanDatePicker.ClientID%>').on('focusout', function () {
                saveReferralData();
             });

            $('#<%=LCaSuspectedBySpecialistCheckBox.ClientID%>').on('change', function () {
                saveReferralData();
            });
            $('#<%=CTScanAvailableCheckBox.ClientID%>').on('change', function () {
                saveReferralData();
            });
        });

        function saveReferralData() {
            //debugger;
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.dateBronchRequested = $find('<%=DateBronchRequestedDatePicker.ClientID%>').get_selectedDate();
            obj.dateOfReferral = $find('<%=DateOfReferralDatePicker.ClientID%>').get_selectedDate();
            obj.lcaSuspectedBySpecialist = $('#<%=LCaSuspectedBySpecialistCheckBox.ClientID%>').is(':checked');
            obj.CTScanAvailable = $('#<%=CTScanAvailableCheckBox.ClientID%>').is(':checked');;
            obj.dateOfScan = $find('<%=DateOfScanDatePicker.ClientID%>').get_selectedDate();

            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/saveReferralData",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
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
        }

    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<div class="control-section-header abnorHeader">Referral Data&nbsp;<img src="../Images/NEDJAG/Mand.png" alt="Mandatory Field" /></div>
<div class="control-content">
    <table cellpadding="3" cellspacing="3" style="margin-top: 10px;">
        <tr>
            <td>Date bronchoscopy requested
            </td>
            <td>
                <telerik:RadDatePicker ID="DateBronchRequestedDatePicker" runat="server" Width="100" ClientEvents-OnDateSelected="saveReferralData" />
            </td>
        </tr>
        <tr runat="server" id="DateOfReferall">
            <td>Date of referral
            </td>
            <td>
                <telerik:RadDatePicker ID="DateOfReferralDatePicker" runat="server" Width="100" ClientEvents-OnDateSelected="saveReferralData" />
            </td>
        </tr>
        <tr runat="server" id="blankRowAfterReferal">
            <td style="height: 20px;"></td>
        </tr>
        <tr>
            <td colspan="2">
                <asp:CheckBox ID="LCaSuspectedBySpecialistCheckBox" runat="server" Text="Lung Ca suspected by lung Ca specialist" /><br />
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <asp:CheckBox ID="CTScanAvailableCheckBox" runat="server" Text="CT scan available prior to bronchoscopy" /><br />
            </td>
        </tr>
        <tr>
            <td>Date of scan
            </td>
            <td>
                <telerik:RadDatePicker ID="DateOfScanDatePicker" runat="server" Width="100" Skin="Windows7" ClientEvents-OnDateSelected="saveReferralData" />
            </td>
        </tr>
    </table>
</div>
