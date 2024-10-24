<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="DiscomfortScore.ascx.vb" Inherits="UnisoftERS.DiscomfortScore" %>
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;

        $(window).on('load', function () {

        });

        $(document).ready(function () {
        });

        function discomfortScore_changed(sender, args) {
            var scoreId = args.get_item().get_value();

            saveDiscomfortScore(scoreId);
        }

        function saveDiscomfortScore(scoreId) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.discomfortScore = parseInt(scoreId);

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveDiscomfortScore",
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
<div class="control-content">
    <table>
        <tr>
            <td>Discomfort score
            </td>
            <td>
                <telerik:RadComboBox ID="DiscomfortScoreRadComboBox" runat="server" DataTextField="Description" DataValueField="UniqueId" Skin="Metro" Width="300" AppendDataBoundItems="true" OnClientSelectedIndexChanged="discomfortScore_changed">
                    <Items>
                        
                    </Items>
                </telerik:RadComboBox>
            </td>
        </tr>
    </table>
</div>
