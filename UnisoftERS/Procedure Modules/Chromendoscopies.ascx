<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="Chromendoscopies.ascx.vb" Inherits="UnisoftERS.Chromendoscopies" %>
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;

        $(window).on('load', function () {
            //Added by rony tfs-4358
            var chromendoscopy = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_TYPE)%>);
            if (chromendoscopy == parseInt(5)) { 
                return false
            } else {
                toggleOther();
            }            
        });

        $(document).ready(function () {
            $('.chromendoscopy-additional-info-text').on('focusout', function () {
                saveProcedureChromendoscopy();
            });
        });

        function chromendoscopy_changed(sender, args) {
            toggleOther();
            saveProcedureChromendoscopy();
        }

        function toggleOther() {
            var text = $find('<%=ChromendoscopyRadComboBox.ClientID%>').get_text().toLowerCase();

            if (text.toLowerCase() == 'other') {
                $('.chromendoscopy-other-text-entry').show();
            }
            else {
                $('.chromendoscopy-other-text-entry').hide();
            }
        }

        function saveProcedureChromendoscopy() {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.chromendoscopyId = parseInt($find('<%=ChromendoscopyRadComboBox.ClientID%>').get_value());
            var text = $find('<%=ChromendoscopyRadComboBox.ClientID%>').get_text().toLowerCase();
            
            if (text.toLowerCase() == 'other') {
                obj.additionalInfo = $('#<%=OtherTextBox.ClientID%>').val();
            }
            else {
                obj.additionalInfo = '';
            }

            $.ajax({
                type: "POST",
                url: "../Procedure.aspx/saveProcedureChromendoscopy",
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
<div class="control-content" runat="server" id="ChromendoscopyUsedContent">
    <table>
        <tr>
            <td>
                <asp:Label ID="Label3" runat="server" Text="Chromendoscopy used:" />
            </td>
            <td>
                <telerik:RadComboBox ID="ChromendoscopyRadComboBox" runat="server" DataTextField="Description" DataValueField="UniqueId" Skin="Metro" Width="300" OnClientSelectedIndexChanged="chromendoscopy_changed" />
            </td>
        </tr>
        <tr class="chromendoscopy-other-text-entry" style="display: none;">
            <td>
                <asp:Label ID="Label5" runat="server" Text="Specify other:" />
            </td>
            <td>
                <telerik:RadTextBox ID="OtherTextBox" runat="server" Width="300" CssClass="chromendoscopy-additional-info-text" />
            </td>
        </tr>
    </table>
</div>
