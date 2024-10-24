<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="AdditionalReportNotes.ascx.vb" Inherits="UnisoftERS.AdditionalReportNotes" %>
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;

        $(window).on('load', function () {
            saveInstrument(); //need to save distal attachment none entry incase the users chooses not to change it
        });

        $(document).ready(function () {
            $('.additional-notes-text-input').on('focusout', function () {
                saveAdditionalNotes();
            });

        });

        function saveAdditionalNotes() {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.additionalNotes = $find("<%= AdditionalNotesTextBox.ClientID%>").get_textBoxValue();


            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveAdditionalNotes",
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

<div class="control-section-header abnorHeader" id="CannulationLabel" runat="server">Additional Report Notes</div>
<div class="control-content">
    <table class="rptSummaryText10">
        <tr>
            <td>
                <telerik:RadTextBox ID="AdditionalNotesTextBox" CssClass="additional-notes-text-input" runat="server" Skin="Windows7" TextMode="MultiLine"
                    Width="500" Height="150" />
            </td>
        </tr>
    </table>
</div>
